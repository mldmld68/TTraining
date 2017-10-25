data "terraform_remote_state" "network" {
  backend = "s3" 
config {
    bucket = "mldmld1968-tfstate"
    key = "vpc/terraform.tfstate"
    region = "${var.region}"
   }  
}
