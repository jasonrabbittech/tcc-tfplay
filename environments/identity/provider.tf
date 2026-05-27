terraform {
  required_version = ">= 1.5.0"

  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">= 1.81.0"
    }
  }

  backend "cos" {
    region = "ap-hongkong"
    bucket = "tfstate-tcctfplay-identity-1426280973"
    prefix = "terraform/identity"
  }
}

provider "tencentcloud" {
  region = var.region
}
