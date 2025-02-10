module "s3_bucket_v1" {
  source      = "./modules/s3_bucket"
  bucket_name = "demo-sirvan-v1"
}


module "s3_bucket_v2" {
  source      = "./modules/s3_bucket"
  bucket_name = "demo-sirvan-v2"
}
module "lifecycle_v2" {
  source      = "./modules/lifecycle"
  bucket_name = module.s3_bucket_v2.s3_bucket_name  # Now this reference works!
}
