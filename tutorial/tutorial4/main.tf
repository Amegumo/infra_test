data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeRegions"] # リージョン一覧を取得する
    resources = ["*"]
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = "ap-northeast-1"
  default_tags {
    tags = {
      terraform-managed = "true"
    }
  }
}

# iam role for ec2
module "describe_regions_for_ec2" {
 source     = "./modules/iam_role"
 name       = "describe-regions-for-ec2"
 identifier = "ec2.amazonaws.com"
 policy     = data.aws_iam_policy_document.allow_describe_regions.json
}

# s3 buckets
module "aws_s3_bucket" {
  source = "./modules/s3"
}

module "aws_vpc" {
  source = "./modules/vpc"
}

module "aws_alb" {
  source = "./modules/alb"
  alb_log_bucket = module.aws_s3_bucket.s3_bucket_alb_log_id
}