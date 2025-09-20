terraform {
  backend "s3" {
    bucket = "terraformstate2110"
    key    = "terraform/eks/terraform.tfstate"
    region = "eu-north-1"
  }
}

##
