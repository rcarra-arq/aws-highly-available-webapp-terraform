# =========================
# Compute Layer - EC2 Instances
# =========================
# =========================
# AMI (Amazon Linux 2023)
# =========================
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

# =========================
# IAM Role (for EC2)
# =========================
#resource "aws_iam_role" "ec2_role" {
#  name = "${var.project_name}-ec2-role"
#
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Action = "sts:AssumeRole"
#        Effect = "Allow"
#        Principal = {
#          Service = "ec2.amazonaws.com"
#        }
#      }
#    ]
#  })
#}
#
#
#resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
#  role       = aws_iam_role.ec2_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#}
# AIM is not allowed in AWS ACADEMY LAB SANDBOX, SO I REMOVED THIS TEMPORARILY

# =========================
# Instance Profile
# =========================
#resource "aws_iam_instance_profile" "ec2_profile" {
#  name = "${var.project_name}-ec2-profile"
#  role = aws_iam_role.ec2_role.name
#}


# =========================
# Launch Template
# =========================
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  # iam_instance_profile {
  #   name = aws_iam_instance_profile.ec2_profile.name
  # }

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    project_name = var.project_name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-ec2"
    }
  }
}


# =========================
# Output (debug)
# =========================
output "launch_template_id" {
  value = aws_launch_template.app.id
}
