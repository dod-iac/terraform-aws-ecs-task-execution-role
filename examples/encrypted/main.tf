// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

data "aws_region" "current" {}

module "cloudwatch_kms_key" {
  #source  = "dod-iac/cloudwatch-kms-key/aws"
  #version = "1.0.1"
  source = "github.com/dod-iac/terraform-aws-cloudwatch-kms-key?ref=update_4_0"

  name = format("alias/%s", var.test_name)
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "main" {
  name              = format("/aws/ecs/%s", var.test_name)
  retention_in_days = 1 # expire logs after 1 day
  kms_key_id        = module.cloudwatch_kms_key.aws_kms_key_arn

  tags = var.tags
}

module "ecs_task_execution_role" {
  source = "../../"

  cloudwatch_log_group_names = [aws_cloudwatch_log_group.main.name]
  name                       = var.test_name
  tags                       = var.tags
}
