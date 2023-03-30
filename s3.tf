resource "aws_s3_bucket" "terrabucket" {
  bucket = "afish-terrabucket"
}
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.terrabucket.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "v_terrabucket" {
  bucket = aws_s3_bucket.terrabucket.id
  versioning_configuration {
    status = "Enabled"
  }

}
#s3 policy
data "aws_iam_policy_document" "terrabucket" {
  statement {
    sid = "Public View"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.terrabucket.arn, "${aws_s3_bucket.terrabucket.arn}/*"
    ]
  }
}
#policy attach
resource "aws_s3_bucket_policy" "terrabucket" {
  bucket = aws_s3_bucket.terrabucket.id
  policy = data.aws_iam_policy_document.terrabucket.json
}