
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    var.private_route_table_id
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowBucketListing"
        Effect = "Allow"

        Principal = "*"

        Action = [
          "s3:ListBucket"
        ]

        Resource = [
          var.application_bucket_arn
        ]
      },
      {
        Sid    = "AllowBucketObjects"
        Effect = "Allow"

        Principal = "*"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = [
          "${var.application_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-s3-gateway-endpoint"
  }
}
