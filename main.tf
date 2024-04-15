provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_security_group" "allow_web" {
  name = "allow_web_traffic_unique"
}

resource "aws_instance" "web" {
  ami           = "ami-080e1f13689e07408"
  instance_type = var.instance_type
  key_name      = "keyforlab6"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update
              sudo apt-get install -y docker-ce
              sudo usermod -aG docker ubuntu
              sudo systemctl start docker
              sudo systemctl enable docker
              docker pull nb1333/lab4-5:latest
              docker run -d -p 80:3000 nb1333/lab4-5:latest
              docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 60
              EOF

  tags = {
    Name = "lab6Instance"
  }

  vpc_security_group_ids = [data.aws_security_group.allow_web.id]
}
