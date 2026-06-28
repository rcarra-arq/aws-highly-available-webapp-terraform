#!/bin/bash

dnf update -y
dnf install -y nginx amazon-cloudwatch-agent

systemctl enable nginx
systemctl start nginx

# -------------------------
# Web content
# -------------------------
echo "<h1>Terraform AWS HA WebApp</h1>" > /usr/share/nginx/html/index.html
echo "ok" > /usr/share/nginx/html/health

# -------------------------
# Enable CloudWatch Agent config
# -------------------------
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${project_name}/system",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/${project_name}/nginx-access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/${project_name}/nginx-error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# -------------------------
# Start CloudWatch Agent
# -------------------------
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
-s
