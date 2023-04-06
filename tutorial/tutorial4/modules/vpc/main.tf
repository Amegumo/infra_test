resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true   # 名前解決 on
  enable_dns_hostnames = true # VPC内のリソースにパブリックDNSホスト名を自動的に割り当てる許可

  tags = {
    Name = "example"
  }
}

# public subnet
resource "aws_subnet" "public_0" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true # パブリックIPアドレスの割り当て
  # map_customer_owned_ip_on_launch = true 
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.public_subnet}_a"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true # パブリックIPアドレスの割り当て
  # map_customer_owned_ip_on_launch = true 
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.public_subnet}_c"
  }
}
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-public_route_table"
  }
}

# ここの関連付けを忘れた場合、デフォルトルートテーブルが適用される。
# デフォルトルートテーブルの適用はアンチパターン
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.example.id #*
  destination_cidr_block = "0.0.0.0/0"

}
resource "aws_route_table_association" "public_0" {
  subnet_id = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# private subnet
resource "aws_subnet" "private_0" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.65.0/24" # 上記のpublic subnet と被らないようにする
  map_public_ip_on_launch = false # パブリックIPアドレスは割り当てない
  availability_zone = "ap-northeast-1a"
  
  tags = {
    Name = "${var.private_subnet}_a"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.66.0/24" # 上記のpublic subnet と被らないようにする
  map_public_ip_on_launch = false # パブリックIPアドレスは割り当てない
  availability_zone = "ap-northeast-1c"
  
  tags = {
    Name = "${var.private_subnet}_c"
  }
}

resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "${var.route_table}_0"
  }
}
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "${var.route_table}_1"
  }
}

# そもそも private なので、routeの作成は不要
resource "aws_route_table_association" "private_0" {
  subnet_id = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}
resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

# To use nat_gateway
resource "aws_eip" "nat_gateway_0"{
  vpc = true
  depends_on = [aws_internet_gateway.example]

  tags = {
    Name = "${var.eip}_0"
  }
}
resource "aws_eip" "nat_gateway_1"{
  vpc = true
  depends_on = [aws_internet_gateway.example]

  tags = {
    Name = "${var.eip}_1"
  }
}

# private subnet を 外部インターネットから接続できるようにするもの
# subnet_idで指定するのはpublic idを指定する様子(どうして？)
resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id = aws_subnet.public_0.id
  depends_on = [aws_internet_gateway.example]

  tags = {
    Name = "${var.nat_gateway}_0"
  }
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.public_1.id
  depends_on = [aws_internet_gateway.example]

  tags = {
    Name = "${var.nat_gateway}_1"
  }
}

# ルートを定義
resource "aws_route" "private_0" {
  route_table_id = aws_route_table.private_0.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_0.id #* publicの時のgatewayとは別にnat_gatewayを選択している
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1" {
  route_table_id = aws_route_table.private_1.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_1.id #* publicの時のgatewayとは別にnat_gatewayを選択している
  destination_cidr_block = "0.0.0.0/0"
}
/**
  EIPやNAT gatewayは暗黙的にインターネットゲートウェイに依存している
  depends_onは明示的にインターネットゲートウェイを作成後にリソースを作成するという指示を出している。
**/