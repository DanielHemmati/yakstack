locals {
  common_tags = {
    Name = var.name
  }

  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

resource "aws_security_group" "instance" {
  name_prefix = "${var.name}-"
  description = "Allow outbound access for Tailscale-managed EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my current IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_key_pair" "this" {
  key_name   = var.ssh_key_name
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_instance" "tailscale" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.key_name

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/scripts/install-tailscale.sh.tftpl", {
    enable_tailscale_ssh = var.enable_tailscale_ssh
    tailscale_auth_key   = var.tailscale_auth_key
    tailscale_hostname   = var.tailscale_hostname
  })

  tags = merge(local.common_tags, {
    TailscaleHostname = var.tailscale_hostname
  })
}
