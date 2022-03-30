# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

variable "pipeline_name" {
  description = "CodePipeline Name"
  type        = string
  default     = "lambda-container-pipeline"
}

variable "lambda_container_code_build_project_name" {
  description = "CodeBuild Project Name"
  type        = string
  default     = "lambda-container-code-build-project"
}

variable "ecr_url" {
  description = "ECR URL"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR Repository Name"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "code_commit_repo_name" {
  description = "CodeCommit repository name"
  type        = string
}

variable "code_build_pipeline_role_arn" {
  description = "CodeBuild pipeline ARN"
  type        = string
}

variable "code_pipeline_service_role_arn" {
  description = "CodePipeline service role ARN"
  type        = string
}

variable "account_id" {
  description = "Account ID"
  type        = string
}
