terraform {
  backend "s3" {
    bucket = "terraformstate2110"
    key    = "terraform/backend"
    region = "eu-north-1"
  }
}
