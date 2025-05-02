#-------------RDS---------------------
resource "aws_db_instance" "myrds" {
  identifier = "islammyrds"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  skip_final_snapshot = true
  multi_az = false
  availability_zone = "us-east-1b"
  db_subnet_group_name   = aws_db_subnet_group.myrds_subnet_group.name
  username             = var.MYSQL_USER
  password             = var.MYSQL_PASSWORD
  parameter_group_name = "default.mysql5.7"
}

#----------------subnet_group------------------
resource "aws_db_subnet_group" "myrds_subnet_group" {
  name       = "myrds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id,aws_subnet.public_subnet.id] 

  tags = {
    Name = "My RDS Subnet Group"
  }
}

