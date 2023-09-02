locals {
  cluster_name       = "ctech-k8s-"
  kubeapi_endpoint   = var.disable_kubeapi_loadbalancer ? hcloud_server_network.control_plane[0].ip : hcloud_load_balancer.load_balancer[0].ipv4
  loadbalancer_count = var.disable_kubeapi_loadbalancer ? 0 : 1
  image              = var.image == "" ? var.image_references[var.os].image_name : var.image
  worker_os          = var.worker_os == "" ? var.image_references[var.os].worker_os : var.worker_os
  ssh_username       = var.ssh_username == "" ? var.image_references[var.os].ssh_username : var.ssh_username

  cluster_autoscaler_min_replicas = var.cluster_autoscaler_min_replicas > 0 ? var.cluster_autoscaler_min_replicas : var.initial_machinedeployment_replicas
  cluster_autoscaler_max_replicas = var.cluster_autoscaler_max_replicas > 0 ? var.cluster_autoscaler_max_replicas : var.initial_machinedeployment_replicas
}