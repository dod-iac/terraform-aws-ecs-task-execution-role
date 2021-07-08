// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

data "aws_region" "current" {}

module "ecs_task_execution_role" {
  source = "../../"

  allow_create_log_groups    = true
  cloudwatch_log_group_names = ["*"]
  name                       = var.test_name
  tags                       = var.tags
}
