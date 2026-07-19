data "aws_vpc" "default_vpc" {
  default = true
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ec2_managed_prefix_list" "instance_connect" {
  name = "com.amazonaws.${data.aws_region.current.region}.ec2-instance-connect"
}

# INFO: There is a diff between aws_subnet and aws_subnet(s)
data "aws_subnet" "default_vpc_az" {
  vpc_id            = data.aws_vpc.default_vpc.id
  availability_zone = var.availability_zone
  default_for_az    = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  # TODO: check and see other virtualization types as well
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # INFO: if someone changes the name, this filter can save us
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# --------------------------------------------------
# Security group
# --------------------------------------------------

resource "aws_security_group" "instance_connect" {
  name_prefix = "ec2-instance-connect-"
  description = "Allow access through EC2 insatnce connect"
  vpc_id      = data.aws_vpc.default_vpc.id

  tags = {
    Name = "ec2-instance-connect"
  }
}

resource "aws_vpc_security_group_ingress_rule" "instance_connect_ssh" {
  security_group_id = aws_security_group.instance_connect.id

  description    = "SSH from the EC2 instance connect service"
  prefix_list_id = data.aws_ec2_managed_prefix_list.instance_connect.id

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "ssh_from_my_ip" {
  security_group_id = aws_security_group.instance_connect.id

  description = "Directh SSH from my computer"
  cidr_ipv4   = local.my_ip_cidr

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.instance_connect.id

  description = "Allow all outbound traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id                   = data.aws_subnet.default_vpc_az.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.instance_connect.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "tf-ec2-instance-connect"
  }

  # Ensure the outbound rule exists before the instnaec start
  depends_on = [
    aws_vpc_security_group_egress_rule.allow_all_outbound
  ]
}

# --------------------------------------------------
# EC2 instnace connect IAM permissions
# --------------------------------------------------


locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"

  caller_arn = data.aws_caller_identity.current.arn

  caller_is_iam_user = strcontains(
    local.caller_arn, ":user/"
  )

  current_iam_user_name = element(
    reverse(split("/", local.caller_arn)),
    0
  )
}

data "aws_iam_policy_document" "instance_connect" {
  statement {
    sid    = "SendTemporarySSHKey"
    effect = "Allow"
    actions = [
      "ec2-instance-connect:SendSSHPublicKey"
    ]
    resources = [
      aws_instance.ec2_instance.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:osuser"
      values   = ["ubuntu"]
    }
  }

  statement {
    sid    = "DescribeEC2Instance"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstance"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "instance_connect" {
  name        = "EC2InstanceConnectUbuntu"
  description = "Allow EC2 instance connect to the ubuntu instance"

  policy = data.aws_iam_policy_document.instance_connect.json
}

resource "aws_iam_user_policy_attachment" "instance_connect" {
  user       = local.current_iam_user_name
  policy_arn = aws_iam_policy.instance_connect.arn

  lifecycle {
    precondition {
      condition = local.caller_is_iam_user

      error_message = <<-EOT
          Terraform is not running as a direct IAM user.

          Current caller:
          ${local.caller_arn}

          aws_iam_user_policy_attachment requires an IAM user.
          If you aer using AWS SSO or an assumed role, attach the policy
          to that IAM role with aws_iam_role_policy_attachment instead.
      EOT
    }
  }
}

