terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # === סעיף הבונוס: Remote State ב-S3 ===
  # כדי להשתמש בבונוס הזה, צריך קודם ליצור Bucket ב-AWS ואז להוריד את ההערות מהבלוק הבא:
  # backend "s3" {
  #   bucket = "my-devops-project-terraform-state-bucket"
  #   key    = "infra/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = "us-east-1" # בחרנו באזור צפון אמריקה, אתה יכול לשנות לכל אזור אחר
}