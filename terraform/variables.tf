variable "cluster_name" {
  description = "prefix for cloud resources"
  type        = string
  default     = "ctec-k8s"
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$", var.cluster_name))
    error_message = "Value of cluster_name should be lowercase and can only contain alphanumeric characters and hyphens(-)."
  }
}

variable "apiserver_alternative_names" {
  description = "subject alternative names for the API Server signing cert."
  default     = []
  type        = list(string)
}

variable "os" {
  description = "Operating System to use in image filtering and MachineDeployment"

  # valid choices are:
  # * ubuntu
  # * centos
  # * rockylinux
  default = "ubuntu"
  type    = string
}

variable "worker_os" {
  description = "OS to run on worker machines"

  # valid choices are:
  # * ubuntu
  # * centos
  # * rockylinux
  default = ""
  type    = string
}

variable "ssh_username" {
  description = "SSH user, used only in output"
  default     = ""
  type        = string
}

variable "ssh_hosts_keys" {
  default     = null
  description = "A list of SSH hosts public keys to verify"
  type        = list(string)
}

variable "bastion_host_key" {
  description = "Bastion SSH host public key"
  default     = null
  type        = string
}

variable "disable_kubeapi_loadbalancer" {
  type        = bool
  default     = false
  description = "E2E tests specific variable to disable usage of any loadbalancer in front of kubeapi-server"
}

# Provider specific settings

variable "image_references" {
  description = "map with images"
  type = map(object({
    image_name   = string
    ssh_username = string
    worker_os    = string
  }))
  default = {
    ubuntu = {
      image_name   = "ubuntu-22.04"
      ssh_username = "root"
      worker_os    = "ubuntu"
    }

    centos = {
      image_name   = "centos-7"
      ssh_username = "root"
      worker_os    = "centos"
    }

    rockylinux = {
      image_name   = "rocky-8"
      ssh_username = "root"
      worker_os    = "rockylinux"
    }
  }
}

variable "control_plane_type" {
  default = "cx21"
  type    = string
}

variable "control_plane_replicas" {
  default     = 3
  type        = number
  description = "DEPRECATED: use control_plane_vm_count instead"

  validation {
    condition     = var.control_plane_replicas == 3
    error_message = "control_plane_replicas is DEPRECATED, please use control_plane_vm_count instead"
  }
}

variable "control_plane_vm_count" {
  default     = 3
  type        = number
  description = "Number of control plane nodes in the cluster"
}

variable "worker_type" {
  default = "cx21"
  type    = string
}

variable "initial_machinedeployment_replicas" {
  description = "Number of replicas per MachineDeployment"
  default     = 0
  type        = number
}

variable "cluster_autoscaler_min_replicas" {
  default     = 0
  description = "minimum number of replicas per MachineDeployment (requires cluster-autoscaler)"
  type        = number
}

variable "cluster_autoscaler_max_replicas" {
  default     = 0
  description = "maximum number of replicas per MachineDeployment (requires cluster-autoscaler)"
  type        = number
}

variable "lb_type" {
  default = "lb11"
  type    = string
}

variable "location" {
  default = "nbg1"
}

variable "datacenters" {
  default = ["nbg1", "hel1", "fsn1"]
  type    = list(string)
}

variable "image" {
  default = ""
  type    = string
}

variable "ip_range" {
  default     = "192.168.0.0/16"
  description = "ip range to use for private network"
  type        = string
}

variable "network_zone" {
  default     = "eu-central"
  description = "network zone to use for private network"
  type        = string
}

variable "user_data" {
  default = null
  type    = string
}