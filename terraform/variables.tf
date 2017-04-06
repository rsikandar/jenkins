variable "region" {
  description = "AWS REGION"
}

variable "key_name" {
  description = "ssh key to use"
  default     = "terraform-ray"
}

variable "ami" {
  type        = "map"
  description = "Map for amis"
  default     = {}
}

variable "instance_type" {
  description = "the type of instance"
}

variable "instance_ips" {
  description = "Ip list for instances."
  default     = ["10.0.1.20"]
}

variable "owner_tag" {
  default = ["infra"]
}

variable "pub_key" {
  description = "pubic key"
}
