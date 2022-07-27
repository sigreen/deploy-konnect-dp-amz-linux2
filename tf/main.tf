terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  profile = "saml"
  region  = "us-west-2"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                 = "simongreen-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "simongreen-dp-sg" {
  name   = "simongreen-dp-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "simongreen-dp-sg"
  }
}


resource "aws_instance" "app_server_dp1" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  associate_public_ip_address = true
  subnet_id = "${element(module.vpc.public_subnets,0)}"
  instance_type               = "t2.micro"
  key_name                    = "simon-green-uswest2"
  vpc_security_group_ids = [aws_security_group.simongreen-dp-sg.id]

  # Create ansible dir remotely
  provisioner "remote-exec" {
    inline=[
      "mkdir /home/ec2-user/ansible"
    ]
  }

  # copy ansible & konnect certs
  provisioner "file" {
    source="../ansible/"
    destination="/home/ec2-user/ansible"
  }

  # run ansible playbook
  provisioner "remote-exec" {
    inline=[
      "sudo amazon-linux-extras install ansible2 -y",
      "ansible-playbook ~/ansible/kongdp.yaml"
    ]
  }

  connection {
    type     = "ssh"
    host     = self.public_ip
    user="${var.INSTANCE_USERNAME}"
    private_key="${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }

  tags = {
    Name = "SimonGreen_DP1_AmznLinux2"
  }
}

resource "aws_instance" "app_server_dp2" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  associate_public_ip_address = true
  subnet_id = "${element(module.vpc.public_subnets,0)}"
  instance_type               = "t2.micro"
  key_name                    = "simon-green-uswest2"
  vpc_security_group_ids = [aws_security_group.simongreen-dp-sg.id]

  # Create ansible dir remotely
  provisioner "remote-exec" {
    inline=[
      "mkdir /home/ec2-user/ansible"
    ]
  }

  # copy ansible & konnect certs
  provisioner "file" {
    source="../ansible/"
    destination="/home/ec2-user/ansible"
  }

  # run ansible playbook
  provisioner "remote-exec" {
    inline=[
      "sudo amazon-linux-extras install ansible2 -y",
      "ansible-playbook ~/ansible/kongdp.yaml"
    ]
  }

  connection {
    type     = "ssh"
    host     = self.public_ip
    user="${var.INSTANCE_USERNAME}"
    private_key="${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }


  tags = {
    Name = "SimonGreen_DP2_AmznLinux2"
  }
}

output "arn_dp1" {
  description = "ARN of the server"
  value = aws_instance.app_server_dp1.arn

}

output "arn_dp2" {
  description = "ARN of the server"
  value = aws_instance.app_server_dp2.arn

}

output "server_name_dp1" {
  description = "Name (id) of the server"
  value = aws_instance.app_server_dp1.id
}

output "server_name_dp2" {
  description = "Name (id) of the server"
  value = aws_instance.app_server_dp2.id
}

output "public_ip_dp1" {
  description = "Public IP of the server"
  value = aws_instance.app_server_dp1.public_ip
}

output "public_ip_dp2" {
  description = "Public IP of the server"
  value = aws_instance.app_server_dp2.public_ip
}

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners = ["amazon"]

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}