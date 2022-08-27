<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates an IAM role for use as an ECS task execution role.

```hcl
module "ecs_task_execution_role" {
  source = "dod-iac/ecs-task-execution-role/aws"

  allow_create_log_groups    = true
  cloudwatch_log_group_names = ["*"]
  name = format("app-%s-task-execution-role-%s", var.application, var.environment)

  tags  = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```
Creates an IAM role for use as an ECS task execution role that writes to a specific list of encrypted CloudWatch log groups.

```hcl
module "cloudwatch_kms_key" {
  source = "dod-iac/cloudwatch-kms-key/aws"

  name = format("alias/app-%s-cloudwatch-logs-%s", var.application, var.environment)

  tags  = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name              = format("/aws/ecs/app-%s-%s", var.application, var.environment)
  retention_in_days = 1 # expire logs after 1 day
  kms_key_id        = module.cloudwatch_kms_key.aws_kms_key_arn

  tags  = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}

module "ecs_task_execution_role" {
  source = "dod-iac/ecs-task-execution-role/aws"

  cloudwatch_log_group_names = [module.cloudwatch_log_group.name]
  name = format("app-%s-task-execution-role-%s", var.application, var.environment)

  tags  = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Testing

Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  The go test command can be executed directly, too.

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0, < 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_create_log_groups"></a> [allow\_create\_log\_groups](#input\_allow\_create\_log\_groups) | Allow role to create CloudWatch log groups. | `bool` | `false` | no |
| <a name="input_allow_ecr"></a> [allow\_ecr](#input\_allow\_ecr) | Allow instance to pull a container image from an ECR repository. | `bool` | `false` | no |
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | The assume role policy for the AWS IAM role.  If blank, allows ECS tasks in the account to assume the role. | `string` | `""` | no |
| <a name="input_cloudwatch_log_group_names"></a> [cloudwatch\_log\_group\_names](#input\_cloudwatch\_log\_group\_names) | List of names of CloudWatch log groups that this task execution role can write to.  Use ["*"] to allow all log groups. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the AWS IAM role. | `string` | n/a | yes |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | The description of the AWS IAM policy attached to the IAM task execution role. Defaults to "The policy for [NAME]". | `string` | `""` | no |
| <a name="input_policy_document"></a> [policy\_document](#input\_policy\_document) | The contents of the AWS IAM policy attached to the IAM task execution role.  If not defined, then uses a generated policy. | `string` | `""` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | The name of the AWS IAM policy attached to the IAM task execution role.  Defaults to "[NAME]-policy". | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the AWS IAM role. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the AWS IAM Role. |
| <a name="output_name"></a> [name](#output\_name) | The name of the AWS IAM Role. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
