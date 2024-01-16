output "lambda_arn" {
  value = local.is_production ? null : module.lambda_cdn_basic_auth[0].lambda_function_arn
}

