
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Register the locally generated public SSH key with AWS.
resource "aws_key_pair" "exam" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand("~/.ssh/terraform-exam-key.pub"))

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Custom VPC and networking module.
module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "${var.aws_region}a"
}

# Globally unique application bucket.
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  bucket_name  = "${var.project_name}-app-${random_id.bucket_suffix.hex}"
}

# IAM role for the private EC2 instance.
resource "aws_iam_role" "private_ec2" {
  name = "${var.project_name}-private-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-private-ec2-role"
  }
}

# Allow the private instance to access only the application bucket.
resource "aws_iam_role_policy" "private_s3_access" {
  name = "${var.project_name}-s3-access"
  role = aws_iam_role.private_ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = [
          module.s3.bucket_arn
        ]
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = [
          "${module.s3.bucket_arn}/*"
        ]
      }
    ]
  })
}

# Allow Session Manager access without opening SSH to the internet.
resource "aws_iam_role_policy_attachment" "private_ssm" {
  role       = aws_iam_role.private_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "private_ec2" {
  name = "${var.project_name}-private-ec2-profile"
  role = aws_iam_role.private_ec2.name
}

# Public web server and private EC2 module.
module "ec2" {
  source = "./modules/ec2"

  project_name                  = var.project_name
  vpc_id                        = module.vpc.vpc_id
  public_subnet_id              = module.vpc.public_subnet_id
  private_subnet_id             = module.vpc.private_subnet_id
  instance_type                 = var.instance_type
  key_name                      = aws_key_pair.exam.key_name
  ssh_allowed_cidr              = var.ssh_allowed_cidr
  private_instance_profile_name = aws_iam_instance_profile.private_ec2.name
  application_bucket_arn        = module.s3.bucket_arn
}

# S3 Gateway endpoint associated with the private route table.
module "vpc_endpoint" {
  source = "./modules/vpc-endpoint"

  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  private_route_table_id = module.vpc.private_route_table_id
  application_bucket_arn = module.s3.bucket_arn
}
