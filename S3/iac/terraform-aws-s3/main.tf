module "s3_bucket_v1" {
  source      = "./modules/s3_bucket"
  bucket_name = "demo-sirvan-v1"
}

module "s3_bucket_v2" {
  source      = "./modules/s3_bucket"
  bucket_name = "demo-sirvan-v2"
}

module "iam_s3_v1" {
  source      = "./modules/iam"
  bucket_name = module.s3_bucket_v1.s3_bucket_name
  kms_key_arn = module.s3_bucket_v1.kms_key_arn  
}

module "iam_s3_v2" {
  source      = "./modules/iam"
  bucket_name = module.s3_bucket_v2.s3_bucket_name
  kms_key_arn = module.s3_bucket_v2.kms_key_arn  
}

module "lifecycle_v1" {
  source      = "./modules/lifecycle"
  bucket_name = module.s3_bucket_v1.s3_bucket_name
}

module "lifecycle_v2" {
  source      = "./modules/lifecycle"
  bucket_name = module.s3_bucket_v2.s3_bucket_name
}

module "monitoring_v1" {
  source      = "./modules/monitoring"
  bucket_name = module.s3_bucket_v1.s3_bucket_name
  alert_email = "your-email@example.com"
}

module "monitoring_v2" {
  source      = "./modules/monitoring"
  bucket_name = module.s3_bucket_v2.s3_bucket_name
  alert_email = "your-email@example.com"
}
