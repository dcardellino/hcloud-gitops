terraform {
  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    endpoint                    = "s3.us-west-002.backblazeb2.com"
    region                      = "us-west-004"
    bucket                      = "cardellino-tech-terraform-state"
    key                         = "kubernetes.tfstate"
  }
}