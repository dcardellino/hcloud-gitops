data "hcloud_network" "network" {
  name = "cardellinotech"
}

data "hcloud_ssh_key" "kubeone" {
  name = "cardellinotech"
}