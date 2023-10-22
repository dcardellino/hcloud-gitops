data "hcloud_network" "network" {
  name = "cardellinotech"
}

data "hcloud_ssh_key" "kubeone" {
  name = "cardellinotech"
}

data "hcloud_server" "bastion" {
  name = "ctec-nat-gateway-01"
}
