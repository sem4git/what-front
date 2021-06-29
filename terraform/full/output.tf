output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}
output "what_front_loadbalancer_url" {
  value = aws_elb.what_front.dns_name
}