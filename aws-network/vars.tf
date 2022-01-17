variable "AWS_REGION" {
  default = "eu-central-1"
}
variable "AMIS" {
  type = map(string)
  default = {
    us-east-1    = "ami-08e4e35cccc6189f4"
    us-east-2    = "ami-0a2306ef347189603"
    eu-central-1 = "ami-05cafdf7c9f772ad2"
  }
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykeyaws"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "mykeyaws.pub"
}

variable "VPC_CIDR" {
  default = "172.0.0.0/16"
}
