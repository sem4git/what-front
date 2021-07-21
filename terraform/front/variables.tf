# variable "subnet_id" {}

variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-2"
}
variable "instance_type" {
  description = "The type of EC2 Instances to run"
  type        = string
  default     = "t2.micro"
}


