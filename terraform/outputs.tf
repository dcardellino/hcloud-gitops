output "kubeone_api" {
  description = "kube-apiserver LB endpoint"

  value = {
    endpoint                    = local.kubeapi_endpoint
    apiserver_alternative_names = var.apiserver_alternative_names
  }
}

output "ssh_commands" {
  #  value = formatlist("ssh -J ${local.ssh_username}@%s", hcloud_server_network.control_plane[*].ip)
  value = formatlist("ssh -J ${local.ssh_username}@%s ${local.ssh_username}@%s", data.hcloud_server.bastion.ipv4_address, hcloud_server_network.control_plane[*].ip)
}

output "kubeone_hosts" {
  description = "Control plane endpoints to SSH to"

  value = {
    control_plane = {
      hostnames        = hcloud_server.control_plane[*].name
      cluster_name     = var.cluster_name
      cloud_provider   = "hetzner"
      private_address  = hcloud_server_network.control_plane[*].ip
      network_id       = data.hcloud_network.network.name
      ssh_agent_socket = "env:SSH_AUTH_SOCK"
      ssh_port         = 22
      ssh_user         = local.ssh_username
      ssh_hosts_keys   = var.ssh_hosts_keys
      bastion_host_key = var.bastion_host_key
      untaint          = true
    }
  }
}

