terraform {
  backend "s3" {
    bucket = "mldmld1968-tfstate"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}
