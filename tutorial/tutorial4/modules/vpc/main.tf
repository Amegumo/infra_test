resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true   # 名前解決 on
  enable_dns_hostnames = true # VPC内のリソースにパブリックDNSホスト名を自動的に割り当てる許可

  tags = {
    Name = "example"
  }
}

# public subnet
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true # パブリックIPアドレスの割り当て
  # map_customer_owned_ip_on_launch = true 
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "example-public_subnet"
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
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# private subnet
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.64.0/24" # 上記のpublic subnet と被らないようにする
  map_public_ip_on_launch = false # パブリックIPアドレスは割り当てない
  availability_zone = "ap-northeast-1a"
  
  tags = {
    Name = "example-private_subnet"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-private_route_table"
  }
}

# そもそも private なので、routeの作成は不要
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# To use nat_gateway
resource "aws_eip" "nat_gateway"{
  vpc = true
  depends_on = [aws_internet_gateway.example]

  tags = {
    Name = "example-nat_gateway"
  }
}

# private subnet を 外部インターネットから接続できるようにするもの
# subnet_idで指定するのはpublic idを指定する様子(どうして？)
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public.id
  depends_on = [aws_internet_gateway.example]

  tags = {
    Name = "example-nat_gateway"
  }
}

# ルートを定義
resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  nat_gateway_id = aws_nat_gateway.example.id #* publicの時のgatewayとは別にnat_gatewayを選択している
  destination_cidr_block = "0.0.0.0/0"
}

/**
  EIPやNAT gatewayは暗黙的にインターネットゲートウェイに依存している
  depends_onは明示的にインターネットゲートウェイを作成後にリソースを作成するという指示を出している。
**/