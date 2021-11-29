variable "bucket_name" {
    type = string
    default = "junhyung-test-web"
 }

resource "aws_s3_bucket" "web" {
  bucket = "${var.bucket_name}"
  acl    = "public-read"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[{
        "Sid":"PublicReadForGetBucketObjects",
        "Effect":"Allow",
          "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.bucket_name}/*"]
    }   
  ]
}
EOF

    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
    }

  versioning {
    enabled = true
  }

  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
