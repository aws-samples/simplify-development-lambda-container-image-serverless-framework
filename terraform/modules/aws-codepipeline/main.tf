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

resource "aws_codebuild_project" "container_code_build_project" {
  name          = var.lambda_container_code_build_project_name
  description   = "CodeBuild project for deploying a container."
  build_timeout = "5"
  service_role  = var.code_build_pipeline_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    environment_variable {
      name  = "BucketName"
      value = var.s3_bucket_name
    }

    environment_variable {
      name  = "CFNTemplatesPath"
      value = "templates"
    }

    environment_variable {
      name  = "AppPath"
      value = "java"
    }
    environment_variable {
      name  = "ACCOUNTID"
      value = var.account_id
    }

    environment_variable {
      name  = "CODEPIPELINEPATH"
      value = "codepipeline"
    }

    environment_variable {
      name  = "ECRNAME"
      value = var.ecr_url
    }

    environment_variable {
      name  = "BRANCHNAME"
      value = "main"
    }

    environment_variable {
      name  = "ECRREPONAME"
      value = var.ecr_repository_name
    }

    environment_variable {
      name  = "LAMBDAPATH"
      value = "lambda"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec = yamlencode({
      version = "0.2"

      phases = {
        build = {
          commands = [
            "ls",
            "IMAGEVERISON=$(<codepipeline/version.txt)",
            "sh codepipeline/version.sh",
            "echo $IMAGEVERISON",
            "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECRNAME",
            "docker build $AppPath/ -t $ECRREPONAME",
            "docker tag $ECRREPONAME:latest $ACCOUNTID.dkr.ecr.us-east-1.amazonaws.com/$ECRREPONAME:$IMAGEVERISON",
            "docker push $ECRNAME:$IMAGEVERISON",
            "npm install -g serverless",
            "sls deploy"
          ]
        }
      }
    })
  }
  }

resource "aws_codepipeline" "codepipeline" {
  name     = var.pipeline_name
  role_arn = var.code_pipeline_service_role_arn

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.code_commit_repo_name
        BranchName       = "main"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "BuildAndDeployLambdaContainerImage"

    action {
      name             = "BuildAndDeployApp"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.container_code_build_project.id
      }
    }
  }
}
