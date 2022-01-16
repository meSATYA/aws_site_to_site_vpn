variable "AWS_REGION" {
  default = "us-east-1"
}
variable "AMIS" {
  type = map(string)
  default = {
    us-east-1    = "ami-08e4e35cccc6189f4"
    us-east-2    = "ami-0a2306ef347189603"
    eu-central-1 = "ami-024ae25a9e4aec250"
  }
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}

variable "VPC_CIDR" {
  default = "10.0.0.0/16"
}
