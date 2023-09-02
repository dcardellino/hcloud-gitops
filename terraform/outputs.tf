output "kubeone_api" {
  description = "kube-apiserver LB endpoint"

  value = {
    endpoint                    = local.kubeapi_endpoint
    apiserver_alternative_names = var.apiserver_alternative_names
  }
}

output "ssh_commands" {
  value = formatlist("ssh ${local.ssh_username}@%s", hcloud_server.control_plane[*].ipv4_address)
}

output "kubeone_hosts" {
  description = "Control plane endpoints to SSH to"

  value = {
    control_plane = {
      hostnames        = hcloud_server.control_plane[*].name
      cluster_name     = var.cluster_name
      cloud_provider   = "hetzner"
      private_address  = hcloud_server_network.control_plane[*].ip
      public_address   = hcloud_server.control_plane[*].ipv4_address
      network_id       = hcloud_network.network.id
      ssh_agent_socket = "env:SSH_AUTH_SOCK"
      ssh_port         = 22
      ssh_user         = local.ssh_username
      ssh_hosts_keys   = var.ssh_hosts_keys
      bastion_host_key = var.bastion_host_key
      untaint          = true
    }
  }
}