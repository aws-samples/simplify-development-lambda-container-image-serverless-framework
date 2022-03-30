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

variable "ecr_policy_name" {
  description = "ECR policy name"
  type        = string
  default     = "ecr_policy"
}

variable "cloudformation_policy_name" {
  description = "CloudFormation policy name"
  type        = string
  default     = "cloudformation_policy"
}

variable "sam_pipeline_policy_name" {
  description = "SAM Pipeline policy name"
  type        = string
  default     = "sam_pipeline_policy"
}

variable "pipeline_s3_bucket_objects_policy_name" {
  description = "Pipeline S3 Bucket policy name"
  type        = string
  default     = "pipeline_artifacts_s3_bucket_policy"
}

variable "ecr_permissions_policy_name" {
  description = "ECR permissions name"
  type        = string
  default     = "ecr_permissions_policy"
}

variable "code_pipeline_base_policy_name" {
  description = "CodePipeline base policy name"
  type        = string
  default     = "code_pipeline_base_policy"
}

variable "iam_pass_role_policy_name" {
  description = "IAM Pass role policy name"
  type        = string
  default     = "iam_pass_role_policy"
}

variable "ssm_parameter_policy_name" {
  description = "SSM parameter policy name"
  type        = string
  default     = "ssm_parameter_policy"
}

variable "container_image_app_name" {
  description = "Lambda function name"
  type        = string
  default     = "container_image_demo_dev_app"
}