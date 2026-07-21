# Remote-state bootstrap
#
# 1. Leave this block commented while creating the S3 bucket and DynamoDB
#    table with local Terraform state.
# 2. Copy backend.hcl.example to backend.hcl and replace the placeholders.
# 3. Uncomment the block below.
# 4. Run:
#      terraform init -migrate-state -backend-config=backend.hcl
#
# Backend blocks cannot reference Terraform input variables.

# terraform {
#   backend "s3" {}
# }
