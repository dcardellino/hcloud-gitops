locals {
  cluster_name       = "ctech-k8s-"
  kubeapi_endpoint   = var.disable_kubeapi_loadbalancer ? hcloud_server_network.control_plane[0].ip : hcloud_load_balancer_network.load_balancer[0].ip
  loadbalancer_count = var.disable_kubeapi_loadbalancer ? 0 : 1
  image              = var.image == "" ? var.image_references[var.os].image_name : var.image
  ssh_username       = var.ssh_username == "" ? var.image_references[var.os].ssh_username : var.ssh_username
}

