provider "aws" {
  region                   = "us-east-2"
  shared_credentials_files = ["C:/Users/Usuario/.aws/credentials"]
  profile                  = "terraform"

  default_tags {
    tags = {
      Environment = "lab"
      Project     = "terraform-day7"
    }
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "buckets3-lab7-terraform"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

terraform {
  backend "s3" {
    bucket                   = "buckets3-lab7-terraform"
    key                      = "environments/production/terraform.tfstate"
    region                   = "us-east-2"
    shared_credentials_files = ["C:/Users/Usuario/.aws/credentials"]
    profile                  = "terraform"

    encrypt      = true
    use_lockfile = true
  }
}