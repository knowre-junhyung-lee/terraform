resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.web.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.web.bucket_regional_domain_name}"
    origin_path = ""
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "test"
  default_root_object = "index.html"

  aliases = ["www.junhyung.knowre.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.web.bucket_regional_domain_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:799844212623:certificate/0f49dbdb-8311-45c5-b4b9-5625e222b3a9" # aws_acm_certificate.cert.arn
    ssl_support_method = "sni-only"
  }

    custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
  }

}

resource "aws_route53_record" "www" {
  zone_id = "Z0117738I196EQRYPI0H"
  name    = "www.junhyung.knowre.com"
  type    = "A"

  alias {
    name                   = replace(aws_cloudfront_distribution.s3_distribution.domain_name, "/[.]$/", "")
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = true
  }

  depends_on = [aws_cloudfront_distribution.s3_distribution]
}
