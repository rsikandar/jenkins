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

variable "node_ami" {
  type        = "map"
  description = "Map for amis"
  default     = {}
}

variable "master_instance_type" {
  description = "the type of instance"
}

variable "node_instance_type" {
  description = "the type of instance"
}

variable "master_instance_ips" {
  description = "Ip list for instances."
  default     = ["10.0.1.20"]
}

variable "node_instance_ips" {
  description = "Ip list for instances."
  default     = ["10.0.0.21", "10.0.0.22"]
}

variable "owner_tag" {
  default = ["infra"]
}

variable "pub_key" {
  description = "pubic key"
}

variable "pubsub" {
  description = "VPC public subnet"
  default     = "10.0.1.0/24"
}

variable "cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "node_as_max" {
  description = "node_as_max"
}

variable "node_as_min" {
  description = "node_as_min"
}

variable "node_lc_name" {
  description = "node launch config name"
  default     = "node-lc"
}
variable "asg_desired" {
  description = "Desired number of instance in ASG"
}
