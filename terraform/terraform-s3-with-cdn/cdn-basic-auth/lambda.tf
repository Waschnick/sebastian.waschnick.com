module "lambda_cdn_basic_auth" {
  count = local.non_production_count

  source         = "terraform-aws-modules/lambda/aws"
  lambda_at_edge = true

  function_name = "QRCodeMonkey_CDN_BasicAuth"
  description   = "Triggered when viewer accesses qrcode monkey dev website"

  source_path = "../lambda/cdn-basic-auth/src"
  handler     = "index.handler"
  runtime     = "nodejs12.x"

  cloudwatch_logs_retention_in_days = 7
}