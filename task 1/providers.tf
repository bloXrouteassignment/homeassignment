provider "aws" {
  region = var.region
}

# specify remote state source in S3
terraform {
  backend "s3" {
    bucket         =  "bloxroute-state"
    key            = "terraform.tfstate"  
    region         = "us-east-1"  
  }
}
