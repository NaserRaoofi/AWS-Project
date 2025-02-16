provider "aws" {
  region = "us-east-1" # Change this to your preferred AWS region
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "sirwan-test-v1" 
}

resource "local_file" "example" {
  filename = "sample.txt"
  content  = "Hello, this is a test file for sirwan joooon choni chon?!"
}

resource "aws_s3_object" "example" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "sample.txt"
  source = "sample.txt"
  etag   = filemd5("sample.txt")
  acl    = "private"

  metadata = {
    owner   = "Sirwan"
    project = "AWS-Tutorial"
    preferred= "amozeshe aws" 
  }
}


