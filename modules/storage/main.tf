resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.project_name}-${var.service_name}-bucket-${var.env}"
  force_destroy = false

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.project_name}-${var.service_name}-bucket-policy-${var.env}"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.bucket.arn}/*"]
      },
    ]
  })
}
