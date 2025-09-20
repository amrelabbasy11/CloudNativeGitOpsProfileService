terraform {
  backend "s3" {
    bucket = "terraformstate2110"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}
