resource "aws_s3_bucket" "b" {
  bucket = "afish-bucket-terraform"

  tags = {
    Name        = "afish-terrabucket"
    Environment = "terratest"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}