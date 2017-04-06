provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source        = "github.com/rsikandar/tf_vpc?ref=v0.0.1"
  name          = "Jenkins"
  cidr          = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
}


resource "aws_instance" "jenkins_master" {
  ami                         = "${lookup(var.ami, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.public_subnet_id}"
  associate_public_ip_address = true
  private_ip                  = "${var.instance_ips[count.index]}"
  user_data                   = "${file("files/jenkins_install.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.jenkins_host_sg.id}",
  ]

  tags {
    Name  = "Jenkins-${format("%03d", count.index + 1)}"
    Owner = "${element(var.owner_tag, count.index)}"
  }

  count = "${length(var.instance_ips)}"
}

resource "aws_elb" "jenkins" {
  name            = "jenkins-elb"
  subnets         = ["${module.vpc.public_subnet_id}"]
  security_groups = ["${aws_security_group.jenkins_inbound_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = ["${aws_instance.jenkins_master.*.id}"]
}

resource "aws_security_group" "jenkins_inbound_sg" {
  name        = "jenkins_inbound"
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

resource "aws_security_group" "jenkins_host_sg" {
  name        = "jenkins_host"
  description = "Allow SSH & HTTP to jenkins hosts"
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
