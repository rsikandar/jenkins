provider "aws" {
  region = "${var.region}"
}

resource "aws_elb" "kubernetes" {
  name            = "kube-elb"
  subnets         = ["${module.vpc.public_subnet_id}"]
  security_groups = ["${aws_security_group.kube_inbound_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = ["${aws_instance.kube_node.*.id}"]
}

module "vpc" {
  source        = "github.com/rsikandar/tf_vpc?ref=v0.0.1"
  name          = "kubernetes"
  cidr          = "${var.cidr}"
  public_subnet = "${var.pubsub}"
}

# autoscalling group with launch config for nodes

resource "aws_launch_configuration" "as_conf" {
  name_prefix     = "${var.node_lc_name}"
  image_id        = "${lookup(var.node_ami, var.region)}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.kube_master_sg.id}"]
  user_data       = "${file("files/node_launch.sh")}"
  key_name        = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "node_as" {
  name                 = "node-autoscaller"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = "${var.node_as_min}"
  max_size             = "${var.node_as_max}"
  load_balancers       = ["${aws_elb.kubernetes.name}"]

  lifecycle {
    create_before_destroy = true
  }
}

# master instance

resource "aws_instance" "kube_master" {
  ami                         = "${lookup(var.master_ami, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.public_subnet_id}"
  associate_public_ip_address = false
  private_ip                  = "${var.master_instance_ips[count.index]}"

  vpc_security_group_ids = [
    "${aws_security_group.kube_master_sg.id}",
  ]

  tags {
    Name  = "kube-master-${format("%03d", count.index + 1)}"
    Owner = "${element(var.owner_tag, count.index)}"
  }

  count = "${length(var.master_instance_ips)}"
}

# node instance

resource "aws_instance" "kube_node" {
  ami                         = "${lookup(var.node_ami, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.public_subnet_id}"
  associate_public_ip_address = true
  private_ip                  = "${var.node_instance_ips[count.index]}"

  vpc_security_group_ids = [
    "${aws_security_group.kube_master_sg.id}",
  ]

  tags {
    Name  = "kube-node-${format("%03d", count.index + 1)}"
    Owner = "${element(var.owner_tag, count.index)}"
  }

  count = "${length(var.node_instance_ips)}"
}

resource "aws_security_group" "kube_inbound_sg" {
  name        = "kube_inbound"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kube_master_sg" {
  name        = "kube_master"
  description = "Allow SSH to kube master"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
