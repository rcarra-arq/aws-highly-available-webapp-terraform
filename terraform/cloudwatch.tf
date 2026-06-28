resource "aws_cloudwatch_log_group" "system" {
  name              = "/aws/ec2/${var.project_name}/system"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "nginx_access" {
  name              = "/aws/ec2/${var.project_name}/nginx-access"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  name              = "/aws/ec2/${var.project_name}/nginx-error"
  retention_in_days = 7
}
