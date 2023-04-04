provider "aws" {
  profile = var.aws_profile
  region  = "ap-northeast-1"
  default_tags {
    tags = {
      terraform-managed = "true"
    }
  }
}

resource "aws_instance" "example" {
  ami = "ami-0c3fd0f5d33134a76"
  instance_type = "t3.micro"

  tags = {
    Name = "example"
  }

  user_data = <<EOF
    #!bin/bash
    yum install -u httpd
    systemctl start httpd.service
  EOF
}