output "public_subnet" {
  value = [aws_subnet.public_0.arn, aws_subnet.public_1.arn]
}
output "private_subnet" {
  value = [aws_subnet.private_0.arn, aws_subnet.private_1.arn]
}

output "eip" {
  value = [aws_eip.nat_gateway_0.address, aws_eip.nat_gateway_1.address]
}

output "nat_gateway" {
  value = [aws_nat_gateway.nat_gateway_0.allocation_id, aws_nat_gateway.nat_gateway_1.allocation_id]
}

output "route_table_private" {
  value = [aws_route_table.private_0.vpc_id, aws_route_table.private_1.vpc_id]
}