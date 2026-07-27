locals {
  my_ip  = "${chomp(data.http.my_ip.response_body)}/32"
  all_ip = "0.0.0.0/0"
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access to instance"
  description = "Allow ssh access to instance"

  tags = {
    Name = "Allow-ssh-access"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress_access" {
  security_group_id = aws_security_group.ssh_access.id
  description       = "SSH from my public ip address"

  cidr_ipv4   = local.my_ip
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ssh_access.id
  description       = "SSH from my public ip address"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "nginx_http_access" {
  name        = "nginx_http_access"
  description = "allow_http_access_instance"

  tags = {
    Name = "allow_http_access_instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ingress_nginx" {
  security_group_id = aws_security_group.nginx_http_access.id
  description       = "Allow HTTP traffic to nginx"

  cidr_ipv4   = local.all_ip
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_http_outbound_nginx" {
  security_group_id = aws_security_group.nginx_http_access.id
  description       = "Allow HTTP outbound traffic"

  cidr_ipv4   = local.all_ip
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_https_outbound_nginx" {
  security_group_id = aws_security_group.nginx_http_access.id
  description       = "Allow HTTPS outbound traffic"

  cidr_ipv4   = local.all_ip
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}


resource "aws_key_pair" "this" {
  key_name   = "terraform-ec2-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "nginx_instance" {
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = data.aws_subnet.default.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.ssh_access.id,
    aws_security_group.nginx_http_access.id
  ]

  tags = {
    Name = "nginx_instance"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/hosts.ini"

  content = <<-EOT
    # Application servers
    [app]
    nginx_instance ansible_host=${aws_instance.nginx_instance.public_ip}

    [app:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=${var.ssh_public_key_path}
    ansible_python_interpreter=/usr/bin/python3.12
  EOT
}


