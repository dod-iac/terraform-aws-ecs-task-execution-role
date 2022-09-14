/**
 * ## Usage
 *
 * Creates an IAM role for use as an ECS task execution role.
 *
 * ```hcl
 * module "ecs_task_execution_role" {
 *   source = "dod-iac/ecs-task-execution-role/aws"
 *
 *   allow_create_log_groups    = true
 *   cloudwatch_log_group_names = ["*"]
 *   name = format("app-%s-task-execution-role-%s", var.application, var.environment)
 *
 *   tags  = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 * Creates an IAM role for use as an ECS task execution role that writes to a specific list of encrypted CloudWatch log groups.
 *
 * ```hcl
 * module "cloudwatch_kms_key" {
 *   source = "dod-iac/cloudwatch-kms-key/aws"
 *
 *   name = format("alias/app-%s-cloudwatch-logs-%s", var.application, var.environment)
 *
 *   tags  = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 *
 * resource "aws_cloudwatch_log_group" "main" {
 *   name              = format("/aws/ecs/app-%s-%s", var.application, var.environment)
 *   retention_in_days = 1 # expire logs after 1 day
 *   kms_key_id        = module.cloudwatch_kms_key.aws_kms_key_arn
 *
 *   tags  = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 *
 * module "ecs_task_execution_role" {
 *   source = "dod-iac/ecs-task-execution-role/aws"
 *
 *   cloudwatch_log_group_names = [module.cloudwatch_log_group.name]
 *   name = format("app-%s-task-execution-role-%s", var.application, var.environment)
 *
 *   tags  = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Testing
 *
 * Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  The go test command can be executed directly, too.
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

#
# IAM
#

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "main" {
  name               = var.name
  assume_role_policy = length(var.assume_role_policy) > 0 ? var.assume_role_policy : data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "main" {
  dynamic "statement" {
    for_each = var.allow_create_log_groups ? [true] : []
    content {
      sid = "CreateCloudWatchLogGroups"
      actions = [
        "logs:CreateLogGroup"
      ]
      effect = "Allow"
      resources = formatlist(
        format(
          "arn:%s:logs:*:*:log-group:%%s/*",
          data.aws_partition.current.partition
        ),
        var.cloudwatch_log_group_names
      )
    }
  }
  statement {
    sid = "CreateCloudWatchLogStreamsAndPutLogEvents"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = formatlist(
      format(
        "arn:%s:logs:%s:%s:log-group:%%s:log-stream:*",
        data.aws_partition.current.partition,
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id,
      ),
      var.cloudwatch_log_group_names
    )
  }
  dynamic "statement" {
    for_each = var.allow_ecr ? [true] : []
    content {
      sid = "GetContainerImage"
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
      ]
      effect    = "Allow"
      resources = ["*"]
    }
  }
}

resource "aws_iam_policy" "main" {
  name        = length(var.policy_name) > 0 ? var.policy_name : format("%s-policy", var.name)
  description = length(var.policy_description) > 0 ? var.policy_description : format("The policy for %s.", var.name)
  policy      = length(var.policy_document) > 0 ? var.policy_document : data.aws_iam_policy_document.main.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}
