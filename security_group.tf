#-------------rds_security_group----------------
resource "aws_security_group" "rds-sg" {
  name        = "rds sg"
  description = "SG for RDS"
  vpc_id      = aws_vpc.myvpc.id
}

#-------------web_security_group----------------
resource "aws_security_group" "web-sg" {
  name        = "web sg"
  description = "SG for Web Server"
  vpc_id      = aws_vpc.myvpc.id
}

#----------rule_inbound----------------------
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#----------rule_outbound----------------------
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group_rule" "rds_from_web" {
  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  security_group_id       = aws_security_group.rds-sg.id
  source_security_group_id = aws_security_group.web-sg.id
}
