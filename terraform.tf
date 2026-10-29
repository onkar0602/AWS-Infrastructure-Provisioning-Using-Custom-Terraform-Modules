
terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "terraform-aws-exam-state-f84f7133"
    key            = "terraform-aws-exam/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-aws-exam-locks"
    use_lockfile   = true
  }
}
