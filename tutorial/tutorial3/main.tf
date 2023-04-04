data "aws_ami" "recent_amazon_linux2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "state"
    values = ["available"]
  }
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }
}

# セキュリティグループ
resource "aws_security_group" "example_ec2" {
  name = "example-ec2"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbaund 全てのプロトコル
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  #ami = "ami-0c3fd0f5d33134a76"
  ami = data.aws_ami.recent_amazon_linux2.image_id
  instance_type = var.example_instance_type
  # セキュリティグループを紐付け
  vpc_security_group_ids = [aws_security_group.example_ec2.id]
  tags = {
    Name = "example"
  }

  user_data = file("./user_data.sh")
}