output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}
output "what_front_loadbalancer_url" {
  value = aws_elb.what_front.dns_name
}
output "zones" {
  value = data.aws_availability_zones.available.names
}
output "region" {
  value = var.region
}
output "our_vpc" {
  value = data.aws_vpc.what_vpc.id
}
output "our_sub_pub_a" {
  value = data.aws_subnet.what_pub_subnet_a.cidr_block
}
output "our_sub_pub_b" {
  value = data.aws_subnet.what_pub_subnet_b.cidr_block
}
output "our_sub_priv_a" {
  value = data.aws_subnet.what_private_subnet_a.cidr_block
}
output "our_sub_priv_b" {
  value = data.aws_subnet.what_private_subnet_b.cidr_block
}
