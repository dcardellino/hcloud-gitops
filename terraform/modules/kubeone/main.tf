locals {
  kubeapi_endpoint   = var.disable_kubeapi_loadbalancer ? hcloud_server_network.control_plane[0].ip : hcloud_load_balancer.load_balancer[0].ipv4
  loadbalancer_count = var.disable_kubeapi_loadbalancer ? 0 : 1
  image              = var.image == "" ? var.image_references[var.os].image_name : var.image
  worker_os          = var.worker_os == "" ? var.image_references[var.os].worker_os : var.worker_os
  ssh_username       = var.ssh_username == "" ? var.image_references[var.os].ssh_username : var.ssh_username

  cluster_autoscaler_min_replicas = var.cluster_autoscaler_min_replicas > 0 ? var.cluster_autoscaler_min_replicas : var.initial_machinedeployment_replicas
  cluster_autoscaler_max_replicas = var.cluster_autoscaler_max_replicas > 0 ? var.cluster_autoscaler_max_replicas : var.initial_machinedeployment_replicas
}

resource "hcloud_network" "network" {
  name     = var.cluster_name
  ip_range = var.ip_range
}

resource "hcloud_firewall" "cluster" {
  name = "${var.cluster_name}-fw"

  labels = {
    "kubeone_cluster_name" = var.cluster_name
  }

  apply_to {
    label_selector = "kubeone_cluster_name=${var.cluster_name}"
  }

  rule {
    description = "allow ICMP"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "allow all TCP inside cluster"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips = [
      var.ip_range,
    ]
  }

  rule {
    description = "allow all UDP inside cluster"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips = [
      var.ip_range,
    ]
  }

  rule {
    description = "allow SSH from any"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "allow NodePorts from any"
    direction   = "in"
    protocol    = "tcp"
    port        = "30000-32767"
    source_ips = [
      "0.0.0.0/0",
    ]
  }
}

resource "hcloud_network_subnet" "kubeone" {
  network_id   = hcloud_network.network.id
  type         = "server"
  network_zone = var.network_zone
  ip_range     = var.ip_range
}

resource "hcloud_server_network" "control_plane" {
  count     = var.control_plane_vm_count
  server_id = element(hcloud_server.control_plane[*].id, count.index)
  subnet_id = hcloud_network_subnet.kubeone.id
}

resource "hcloud_placement_group" "control_plane" {
  name = var.cluster_name
  type = "spread"

  labels = {
    "kubeone_cluster_name" = var.cluster_name
  }
}

resource "hcloud_server" "control_plane" {
  count              = var.control_plane_vm_count
  name               = "${var.cluster_name}-control-plane-${count.index + 1}"
  server_type        = var.control_plane_type
  image              = local.image
  location           = var.datacenters[count.index]
  placement_group_id = hcloud_placement_group.control_plane.id
  user_data          = var.user_data

  ssh_keys = [
    hcloud_ssh_key.kubeone.id,
  ]

  labels = {
    "kubeone_cluster_name" = var.cluster_name
    "role"                 = "api"
  }
}

resource "hcloud_load_balancer_network" "load_balancer" {
  count = local.loadbalancer_count

  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  subnet_id        = hcloud_network_subnet.kubeone.id
}

resource "hcloud_load_balancer" "load_balancer" {
  count = local.loadbalancer_count

  name               = "${var.cluster_name}-lb"
  load_balancer_type = var.lb_type
  location           = var.location

  labels = {
    "kubeone_cluster_name" = var.cluster_name
    "role"                 = "lb"
  }
}

resource "hcloud_load_balancer_target" "load_balancer_target" {
  count = local.loadbalancer_count

  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  label_selector   = "kubeone_cluster_name=${var.cluster_name},role=api"
  use_private_ip   = true
  depends_on = [
    hcloud_server_network.control_plane,
    hcloud_load_balancer_network.load_balancer
  ]
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
  count = local.loadbalancer_count

  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}
