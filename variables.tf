variable "assume_role_policy" {
  type        = string
  description = "The assume role policy for the AWS IAM role.  If blank, allows ECS tasks in the account to assume the role."
  default     = ""
}

variable "cloudwatch_log_group_names" {
  type        = list(string)
  description = "List of names of CloudWatch log groups that this task execution role can write to.  Use [\"*\"] to allow all log groups."
}

variable "allow_create_log_groups" {
  type        = bool
  description = "Allow role to create CloudWatch log groups."
  default     = false
}

variable "allow_ecr" {
  type        = bool
  description = "Allow instance to pull a container image from an ECR repository."
  default     = false
}

variable "policy_document" {
  type        = string
  description = "The contents of the AWS IAM policy attached to the IAM task execution role.  If not defined, then uses a generated policy."
  default     = ""
}

variable "policy_description" {
  type        = string
  description = "The description of the AWS IAM policy attached to the IAM task execution role. Defaults to \"The policy for [NAME]\"."
  default     = ""
}

variable "policy_name" {
  type        = string
  description = "The name of the AWS IAM policy attached to the IAM task execution role.  Defaults to \"[NAME]-policy\"."
  default     = ""
}

variable "name" {
  type        = string
  description = "The name of the AWS IAM role."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the AWS IAM role."
  default     = {}
}
