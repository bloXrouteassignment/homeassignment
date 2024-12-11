variable "region" { default = "us-east-1" }
variable "instance_type" { default = "t2.micro" }
variable "subnets" {
    type = list(string)
    default = ["subnet-00dfaf60680b6c65b", "subnet-08d74a130897a0e63"]
}
variable "vpc_id" { default = "vpc-016472d37a5027fcf"}
variable "os_type" { default = "ubuntu-focal-20.04-amd64-server"}
