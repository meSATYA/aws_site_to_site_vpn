output "openswan_instance_public_ip" {
  description = "openswan instance public ip address"
  value = aws_instance.openswan_instance.public_ip
}

output "customer_instance_public_ip" {
  description = "customer instance public ip address"
  value = aws_instance.customer_instance.public_ip
}


