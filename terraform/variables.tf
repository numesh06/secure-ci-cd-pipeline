variable "aws_account_id" {
  default = "590183674500"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-0f1b89114329c0572", "subnet-08cceb41040e89308"]
}

variable "security_group_ids" {
  type    = list(string)
  default = ["sg-033154dd00c5b3830"]
}
variable "vpc_id" {
  default = "vpc-03d96fd503e373709"
}

