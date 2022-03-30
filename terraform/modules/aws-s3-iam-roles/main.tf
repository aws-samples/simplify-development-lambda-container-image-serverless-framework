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

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# FIX BUCKET NAME
resource "aws_s3_bucket" "demoBucket" {
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "demo_bucket" {
  bucket                  = aws_s3_bucket.demoBucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_ssm_parameter" "demo_s3_bucket_ssm_param" {
  name        = "demo-pipeline-s3-bucket-name"
  description = "Demo Pipeline S3 Bucket name"
  type        = "String"
  overwrite   = true
  value       = aws_s3_bucket.demoBucket.id
}

resource "aws_codecommit_repository" "demo_repo_lambda" {
  repository_name = "DemoRepoLambda"
  description     = "This is the sample app repository"
}

resource "aws_ecr_repository" "ecr" {
  name = var.ecr_repository_name
}

resource "aws_ssm_parameter" "demo_ecr_param" {
  name        = "demo-ecr-uri"
  description = "Demo ECR URI"
  type        = "String"
  overwrite   = true
  value       = aws_ecr_repository.ecr.repository_url
}

resource "aws_iam_policy" "ecr_policy" {
  name        = var.ecr_policy_name
  path        = "/"
  description = "My ECR policy"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "cloudformation:ValidateTemplate",
          "lambda:Get*",
          "lambda:List*",
          "s3:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "cloudformation_policy" {
  name        = var.cloudformation_policy_name
  path        = "/"
  description = "CloudFormation policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeChangeSet",
          "cloudformation:GetTemplateSummary",
          "cloudformation:DescribeStackEvents",
          "cloudformation:CreateChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:UpdateStack",
          "cloudformation:ListStackResources"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:cloudformation:us-east-1:${local.account_id}:*",
          "arn:aws:cloudformation:us-east-1:${local.account_id}:transform/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "sam_pipeline_policy" {
  name        = var.sam_pipeline_policy_name
  path        = "/"
  description = "CloudFormation policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:GetFunction",
          "lambda:CreateFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:ListVersionsByFunction",
          "lambda:PublishVersion",
          "lambda:DeleteFunction",
          "lambda:DeleteAlias",
          "lambda:CreateAlias",
          "lambda:AddPermission",
          "lambda:UpdateFunctionCode",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:GET",
          "apigateway:PATCH",
          "apigateway:DELETE"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:lambda:us-east-1:${local.account_id}:function:${var.container_image_app_name}",
          "arn:aws:lambda:us-east-1:${local.account_id}:function:${var.container_image_app_name}:*",
          "arn:aws:apigateway:us-east-1::/restapis/*",
          "arn:aws:apigateway:us-east-1::/restapis",
          "arn:aws:apigateway:us-east-1::/*/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "pipeline_artifacts_s3_bucket_objects_policy" {
  name        = var.pipeline_s3_bucket_objects_policy_name
  path        = "/"
  description = "CodePipeline S3 Artifacts policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject*",
          "s3:PutObject*",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.demoBucket.arn}",
          "${aws_s3_bucket.demoBucket.arn}/*",
          "arn:aws:logs:us-east-1:${local.account_id}:*/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ecr_permissions_policy" {
  name        = var.ecr_permissions_policy_name
  path        = "/"
  description = "ECR policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:DescribeRegistry",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:us-east-1:${local.account_id}:repository/*"
      },
    ]
  })
}

resource "aws_iam_policy" "code_pipeline_base_policy" {
  name        = var.code_pipeline_base_policy_name
  path        = "/"
  description = "CodeCommit policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codepipeline:List*",
          "codepipeline:Get*",
          "codepipeline:List*",
          "codepipeline:StartPipelineExecution",
          "codepipeline:StopPipelineExecution",
          "codepipeline:RetryStageExecution",
          "codepipeline:UpdatePipeline",
          "codepipeline:CreatePipeline",
          "codepipeline:DeletePipeline",
          "codepipeline:TagResource",
          "codepipeline:UntagResource",
          "codepipeline:EnableStageTransition",
          "codepipeline:DisableStageTransition",
          "codepipeline:PollForJobs",
          "codepipeline:PutActionRevision",
          "codepipeline:PutApprovalResult",
          "codepipeline:PutJobFailureResult",
          "codepipeline:PutJobSuccessResult",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:GitPull",
          "codecommit:GitPush",
          "codecommit:GetRepository"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codebuild:us-east-1:${local.account_id}:*/*",
          "arn:aws:codepipeline:us-east-1:${local.account_id}:*/*",
          aws_codecommit_repository.demo_repo_lambda.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role" "lambda_build_role" {
  name        = "lambda_build_role"
  description = "This role will build and deploy lambda functions from CodePipeline."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["lambda.amazonaws.com", "codepipeline.amazonaws.com", "codebuild.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_role" "code_pipeline_service_role" {
  name        = "code_pipeline_service_role"
  description = "This role will build and deploy lambda functions from CodePipeline."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["codepipeline.amazonaws.com", "codebuild.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_role" "code_build_pipeline_role" {
  name = "code_build_pipeline_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "codepipeline.amazonaws.com",
            "codebuild.amazonaws.com",
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role" "lambda_execution_role" {
  name        = "lambda_execution_role"
  description = "This role will enable Lambda functions to execute."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "cloud_watch_events_policy" {
  name        = "cloud_watch_events_policy"
  path        = "/"
  description = "CloudWatch Events policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codepipeline:StartPipelineExecution"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codepipeline:us-east-1:${local.account_id}:${var.code_pipeline_name}"
        ]
      },
    ]
  })
}

resource "aws_iam_role" "pipeline_cloudwatch_events_role" {
  name        = "pipeline_cloudwatch_events_role"
  description = "This role will triggle the pipeline whenever there is commit to specified branch."
  managed_policy_arns = [
    aws_iam_policy.cloud_watch_events_policy.arn
  ]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_cloudwatch_event_rule" "pipeline_event_rule" {
  name          = "pipeline-event-trigger"
  description   = "Capture each AWS Console Sign In"
  event_pattern = <<EOF
  {
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "source": [
    "aws.codecommit"
  ],
  "resources": [
    "${aws_codecommit_repository.demo_repo_lambda.arn}"
  ],
  "detail": {
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "main"
    ],
    "event": [
      "referenceCreated",
      "referenceUpdated"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "pipeline_target" {
  target_id = "codepipeline"
  rule      = aws_cloudwatch_event_rule.pipeline_event_rule.name
  arn       = "arn:aws:codepipeline:us-east-1:${local.account_id}:${var.code_pipeline_name}"
  role_arn  = aws_iam_role.pipeline_cloudwatch_events_role.arn
}


resource "aws_iam_policy" "iam_pass_role_policy" {
  name        = var.iam_pass_role_policy_name
  path        = "/"
  description = "My ECR policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:PassRole",
          "iam:GetRole"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codebuild:us-east-1:${local.account_id}:lambda-deploy-project/*",
          "arn:aws:codebuild:us-east-1:${local.account_id}:container-code-build-project/*",
          "${aws_iam_role.lambda_execution_role.arn}"
        ]
      },
    ]
  })
}

resource "aws_ssm_parameter" "demo_lambda_role_ssm_param" {
  name        = "demo-pipeline-lambda-role-arn"
  description = "Demo Pipeline Lambda role ARN"
  type        = "String"
  overwrite   = true
  value       = aws_iam_role.lambda_execution_role.arn
}

resource "aws_iam_policy" "ssm_parameter_policy" {
  depends_on = [
    aws_ssm_parameter.demo_ecr_param,
    aws_ssm_parameter.demo_s3_bucket_ssm_param,
    aws_ssm_parameter.demo_lambda_role_ssm_param
  ]
  name        = var.ssm_parameter_policy_name
  path        = "/"
  description = "CodePipeline SSM parameter policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_ssm_parameter.demo_ecr_param.arn}",
          "${aws_ssm_parameter.demo_s3_bucket_ssm_param.arn}",
          "${aws_ssm_parameter.demo_lambda_role_ssm_param.arn}"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_build_role_attachment" {
  depends_on = [
    aws_iam_policy.iam_pass_role_policy,
    aws_iam_policy.cloud_watch_events_policy,
    aws_iam_policy.code_pipeline_base_policy,
    aws_iam_policy.ecr_permissions_policy,
    aws_iam_policy.pipeline_artifacts_s3_bucket_objects_policy,
    aws_iam_policy.sam_pipeline_policy,
    aws_iam_policy.cloudformation_policy,
    aws_iam_policy.ecr_policy,
    aws_iam_policy.ssm_parameter_policy
  ]
  for_each = toset([
    "arn:aws:iam::${local.account_id}:policy/${var.code_pipeline_base_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.iam_pass_role_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_permissions_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.sam_pipeline_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.pipeline_s3_bucket_objects_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.cloudformation_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_policy_name}"
  ])
  role       = aws_iam_role.lambda_build_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "code_build_pipeline_role_attachment" {
  depends_on = [
    aws_iam_policy.iam_pass_role_policy,
    aws_iam_policy.cloud_watch_events_policy,
    aws_iam_policy.code_pipeline_base_policy,
    aws_iam_policy.ecr_permissions_policy,
    aws_iam_policy.pipeline_artifacts_s3_bucket_objects_policy,
    aws_iam_policy.sam_pipeline_policy,
    aws_iam_policy.cloudformation_policy,
    aws_iam_policy.ecr_policy,
    aws_iam_policy.ssm_parameter_policy
  ]
  for_each = toset([
    "arn:aws:iam::${local.account_id}:policy/${var.code_pipeline_base_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.iam_pass_role_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_permissions_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.sam_pipeline_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.pipeline_s3_bucket_objects_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.cloudformation_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ssm_parameter_policy_name}"
  ])
  role       = aws_iam_role.code_build_pipeline_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "attach_lambda_execution_role_attachment" {
  depends_on = [
    aws_iam_policy.iam_pass_role_policy,
    aws_iam_policy.cloud_watch_events_policy,
    aws_iam_policy.code_pipeline_base_policy,
    aws_iam_policy.ecr_permissions_policy,
    aws_iam_policy.pipeline_artifacts_s3_bucket_objects_policy,
    aws_iam_policy.sam_pipeline_policy,
    aws_iam_policy.cloudformation_policy,
    aws_iam_policy.ecr_policy,
    aws_iam_policy.ssm_parameter_policy
  ]
  for_each = toset([
    "arn:aws:iam::${local.account_id}:policy/${var.pipeline_s3_bucket_objects_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.iam_pass_role_policy_name}"
  ])
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "code_pipeline_service_role_attachment" {
  depends_on = [
    aws_iam_policy.iam_pass_role_policy,
    aws_iam_policy.cloud_watch_events_policy,
    aws_iam_policy.code_pipeline_base_policy,
    aws_iam_policy.ecr_permissions_policy,
    aws_iam_policy.pipeline_artifacts_s3_bucket_objects_policy,
    aws_iam_policy.sam_pipeline_policy,
    aws_iam_policy.cloudformation_policy,
    aws_iam_policy.ecr_policy,
    aws_iam_policy.ssm_parameter_policy
  ]
  for_each = toset([
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_permissions_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.pipeline_s3_bucket_objects_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.cloudformation_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.iam_pass_role_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.code_pipeline_base_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_policy_name}"
  ])
  role       = aws_iam_role.code_pipeline_service_role.name
  policy_arn = each.value
}
