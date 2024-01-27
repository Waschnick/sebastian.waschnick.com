resource "aws_cloudfront_function" "root-to-index-cf-function" {
  name    = "test"
  runtime = "cloudfront-js-1.0"
  comment = "my function"
  publish = true
  code    = file("${path.module}/function.js")
}
