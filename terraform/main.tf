terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60.0"
    }
  }
}

output "aws-s3-iam-roles-s3-bucket-output" {
  value = module.aws-s3-iam-roles.s3_bucket_name
}

module "aws-s3-iam-roles" {
  source = "./modules/aws-s3-iam-roles"
}

module "aws-codepipeline" {
  source                         = "./modules/aws-codepipeline"
  ecr_url                        = module.aws-s3-iam-roles.ecr_url
  ecr_repository_name            = module.aws-s3-iam-roles.ecr_repository_name
  s3_bucket_name                 = module.aws-s3-iam-roles.s3_bucket_name
  code_commit_repo_name          = module.aws-s3-iam-roles.code_commit_repo_name
  code_build_pipeline_role_arn   = module.aws-s3-iam-roles.code_build_pipeline_role_arn
  code_pipeline_service_role_arn = module.aws-s3-iam-roles.code_pipeline_service_role_arn
  account_id                     = module.aws-s3-iam-roles.account_id
}
