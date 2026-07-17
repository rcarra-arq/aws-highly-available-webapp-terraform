
# =========================
# Auto Scaling Group - High Availability Layer
# =========================
resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-asg"

  min_size         = 1
  max_size         = 2
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
}
