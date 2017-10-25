# -------------- Bucket S3 to store tfstate files ----------------------------------------------------------------------------------
resource "aws_s3_bucket" "vpc-mld" {
  bucket = "mldmld1968-tfstate"
  acl    = "private"

  tags {
    Name        = "vpc-mld"
    Environment = "Dev"
  }
}

