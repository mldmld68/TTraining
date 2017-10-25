output "vpc_id" {
  value = "${aws_vpc.vpc-mld.id}"
}

output "subnet_a_id" {
  value = "${aws_subnet.front-a.id}"
}

output "subnet_b_id" {
  value = "${aws_subnet.front-b.id}"
}
