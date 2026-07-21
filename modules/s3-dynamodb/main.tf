
// S3 bucket     = stores terraform.tfstate , S3 encryption protects the state file.
// DynamoDB      = locks terraform.tfstate. ,  DynamoDB locking prevents two applies at the same time.

resource "aws_s3_bucket" "remote_backed" {
  bucket = var.bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_versioning" "remote_backed_versioning" {
  bucket = aws_s3_bucket.remote_backed.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_backed_encryption" {
  bucket = aws_s3_bucket.remote_backed.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}



resource "aws_dynamodb_table" "terraform_locks" {
  name             = var.dynamodb_table
  hash_key         = "LockID"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "LockID"
    type = "S"
  }
}



/*Example data stored:

LockID
eks-prod/terraform.tfstate
vpc-prod/terraform.tfstate

*/

