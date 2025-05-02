resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/terraform-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "web" {
  ami                         = "ami-0e449927258d45bc4"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web-sg.id]
  associate_public_ip_address = true

provisioner "remote-exec" {
  inline = [
    "set -ex",
    "echo 'export MYSQL_PASSWORD=${var.MYSQL_PASSWORD}' | sudo tee /etc/profile.d/env-vars.sh",
    "echo 'export MYSQL_DB=${var.MYSQL_DB}' | sudo tee -a /etc/profile.d/env-vars.sh",
    "echo 'export MYSQL_USER=${var.MYSQL_USER}' | sudo tee -a /etc/profile.d/env-vars.sh",
    "echo 'export MYSQL_HOST=${aws_db_instance.myrds.address}' | sudo tee -a /etc/profile.d/env-vars.sh",
    "sudo chmod +x /etc/profile.d/env-vars.sh",
    "source /etc/profile.d/env-vars.sh",

    "sudo yum -y update",
    "sudo yum -y install git mariadb105 gcc-c++ make",
    "curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -",
    "sudo yum install -y nodejs",

    "if [ ! -d getting-started-app ]; then git clone https://github.com/docker/getting-started-app.git; fi",

    "sed -i \"s/app.listen(3000.*/app.listen(3000, '0.0.0.0', () => console.log('Listening on port 3000'));/\" getting-started-app/src/index.js",

    "echo 'Waiting for RDS to be ready...'",
    "sleep 60",

    "mysql -h ${aws_db_instance.myrds.address} -P 3306 -u ${var.MYSQL_USER} -p${var.MYSQL_PASSWORD} -e 'CREATE DATABASE IF NOT EXISTS ${var.MYSQL_DB};' || true",

    "cd getting-started-app",
    "sudo npm install -g yarn",
    "yarn install --production",
    "nohup node src/index.js > ~/app.log 2>&1 &"
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.example.private_key_pem
    host        = self.public_ip
  }
}



  depends_on = [aws_db_instance.myrds]
}

#----------------- eip output -------------------
output "ec2_public_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP of the EC2 instance"
}
