### 外部公開しないバケットの作成
resource "aws_s3_bucket" "private" {
  bucket = "private-pragmatic-terraform-by-hamada"
  force_destroy = true
}

# versioning は別リソースとして定義される。
resource "aws_s3_bucket_versioning" "private_versioning" {
  bucket = aws_s3_bucket.private.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# source https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration#apply_server_side_encryption_by_default
resource "aws_s3_bucket_server_side_encryption_configuration" "private_encryption" {
  bucket = aws_s3_bucket.private.id

  rule{
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id 

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

### 公開するバケットの設定
resource "aws_s3_bucket" "public" {
  bucket = "public-pragmatic-terraform-by-hamada"
  force_destroy = true
}


resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.public.id
  acl    =  "public-read"

  tag = {
    Name = "example-acl"
  }
}
# source https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration
resource "aws_s3_bucket_cors_configuration" "public_cors" {
  bucket = aws_s3_bucket.public.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    # allowed_origins = ["https://s3-website-test.hashicorp.com"]
    allowed_origins = ["https://example.com"]
    # expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

### ログバケット
resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-pragmatic-terraform-by-hamada"
  force_destroy = true
}

# ログバケットのライフサイクル設定
resource "aws_s3_bucket_lifecycle_configuration" "alb_lifecycle" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id = "rule-1"
    expiration {
      days = "180"
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "alg_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

### ログバケットのバケットポリシー
data "aws_iam_policy_document" "alb_log"{
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.alb_log.arn}",
      "${aws_s3_bucket.alb_log.arn}/*"
    ]
    # ここの数値をコードに埋めたくないので、なんとか分離できないか考える。
    principals {
      type = "AWS"
      identifiers = ["712499223494"]
    }
  }
}