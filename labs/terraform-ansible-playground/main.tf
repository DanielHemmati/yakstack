data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "ansible-ec2-playground-sg"
  description = "Allow SSH from my public ip"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my public IP"
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-ec2-playground-sg"
  }
}

resource "aws_key_pair" "this" {
  key_name   = "terraform-ec2-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = {
    Name = "ansible-ec2-playground"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/hosts.ini"

  content = <<EOF
  [ec2]
  ${aws_instance.ubuntu.public_ip}

  [ec2:vars]
  ansible_user=ubuntu
  ansible_ssh_private_key_file=~/.ssh/terraform-ec2
  ansible_python_interpreter=/usr/bin/python3.12
  EOF
}

