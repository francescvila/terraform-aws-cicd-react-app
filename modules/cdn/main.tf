# Cloudfront

locals {
  origin_id = "${var.project_name}-${var.service_name}-cdn-${var.env}"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = var.target_domain_name
    origin_id   = local.origin_id

    connection_attempts = 1
    connection_timeout  = 10

    origin_shield {
      enabled              = true
      origin_shield_region = var.region
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  # attach the WAF when an Id is given
  #   web_acl_id = length(var.waf_id) == 0 ? null : var.waf_id

  comment             = "${var.project_name} ${var.service_name} ${var.env} cloudFront distribution"
  default_root_object = "index.html"

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "${var.service_name}-${var.app_name}-${var.env}-logs.s3.amazonaws.com"
  #     prefix          = "${var.service_name}-${var.app_name}-${var.env}"
  #   }

  #aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    target_origin_id = local.origin_id
    compress         = true
    # cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    # # allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["Origin", "Accept-Language"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 120
    max_ttl     = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      #    restriction_type = "whitelist"
      #    locations        = ["US", "CA", "GB", "DE"]
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_caching_min_ttl = "0"
    error_code            = "403"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = "0"
    error_code            = "404"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  tags = var.tags

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
