variable "aws_region" {
  description = "Aws region in which to create resources"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Aavailability zone containing the default subnet"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

