
# =========================
# Auto Scaling Group - Availability & Scalability Layer
# =========================
resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-asg"

  min_size         = 1
  max_size         = 5
  desired_capacity = 2

  vpc_zone_identifier = values(aws_subnet.public)[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  # "ELB" so instances failing the ALB health check (e.g. nginx down)
  # are replaced, not just pulled out of rotation. Grace period covers
  # the boot time of userdata.sh (dnf update + installs).
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-instance"
    propagate_at_launch = true
  }

  # Once the stack is up, desired_capacity belongs to the scaling policies,
  # not to Terraform. Without this, an apply run while the ASG sits at 3
  # would reset it to 2 and undo the scale out CloudWatch had just ordered.
  # min_size and max_size stay managed here - those are the boundaries.
  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
