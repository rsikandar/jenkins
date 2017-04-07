variable "region" {
  description = "AWS REGION"
}

variable "key_name" {
  description = "ssh key to use"
  default     = "terraform-ray"
}

variable "master_ami" {
  type        = "map"
  description = "Map for amis"
  default     = {}
}

variable "slave_ami" {
  type        = "map"
  description = "Map for amis"
  default     = {}
}

variable "instance_type" {
  description = "the type of instance"
}

variable "master_instance_ips" {
  description = "Ip list for instances."
  default     = ["10.0.1.20"]
}

variable "slave_instance_ips" {
  description = "Ip list for instances."
  default     = ["10.0.1.23", "10.0.1.24"]
}

variable "owner_tag" {
  default = ["infra"]
}

variable "pub_key" {
  description = "pubic key"
}
