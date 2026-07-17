# Standard tags applied to every taggable resource via default_tags,
# and merged manually where the provider cannot inject them (resources
# launched indirectly, like EC2 instances created from the launch
# template). Consistent tags are what make Cost Explorer able to answer
# "how much does THIS project cost?".
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
