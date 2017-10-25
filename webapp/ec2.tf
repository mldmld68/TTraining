# -- We need to "adopt" the VPC default security group to allow members of the cluster to communicate 
resource "aws_default_security_group" "sg-default-mld-vpc" {
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------- internet access security groups ------------------------------------------------------------
resource "aws_security_group" "sg_http-s" {
  name        = "sg_https[s]"
  description = "allow http[s] inbound traffic"
  vpc_id      = "${data.terraform_remote_state.network.vpc_id}"

  tags {
    Name = "sg_https[s]"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------- ssh access security group -------------------------------------------------------------------
resource "aws_security_group" "sg_ssh" {
  name        = "sg_ssh"
  description = "allow ssh traffic"
  vpc_id      = "${data.terraform_remote_state.network.vpc_id}"

  tags {
    Name = "sg_https[s]"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------- Building the JumpBox ----------------------------------------------------------------------------------------------------------
data "aws_ami" "LatestUbuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Using template file to be able, if necessary to set variable in user_data
data "template_file" "user_data_webserver" {
  template = "${file("${path.module}/webserver.tpl")}"

  vars {
    username = "M.L.D"
  }
}

#resource "aws_key_pair" "webmldkey" {
#  key_name   = "webmldkey"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMyM83sYohLOZe8rK813zCyMNgAmp8q0wuqaApvy2raHFC+mTQtTe0oqXbRTQEx7Cud9TfPHWNIVa7a53nftWc6inNpGgl9g9ihL6lnhfxnR7U69GGKeLKoRbLJEXLr+9CywZbh+kwKzrttQ3sQgGOBe184IkF5HXymf2gi+onsNWZ+zeLXpho3bknnlgHH7xT6a61I3lEVkjahRrs2elK6SmmfYk5vkuvqI51Xhw3BtIM3nLhFEf1YKuJvhECG9tcwh+mgKGYFooGCG/FcR9zlVRiBjKU7RuRG52TJHEGhwVR76QQaShE9T3YfYlwnqfNQDXNwEd+lVmlWuPafHkB"
#}

resource "aws_instance" "WebServer" {
  ami           = "${data.aws_ami.LatestUbuntu.id}"
  instance_type = "t2.micro"
  key_name      = "webmldkey"
  subnet_id     = "${data.terraform_remote_state.network.subnet_a_id}" 
  user_data     = "${data.template_file.user_data_webserver.rendered}"
  count         = "1"

  vpc_security_group_ids = [
    "${aws_security_group.sg_ssh.id}","${aws_security_group.sg_http-s.id}"
  ]

  associate_public_ip_address = true

  tags {
    Name = "WebServer MLD"
  }

  root_block_device {
    volume_size           = "8"
    delete_on_termination = "true"
  }
}

output "publicIP" {
  value = "${aws_instance.WebServer.public_ip}"
}
