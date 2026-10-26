#!/bin/bash
set -eux
REGION=ap-northeast-1

get() {
  aws ssm get-parameter --name "/blog/$1" --with-decryption \
    --query Parameter.Value --output text --region $REGION
}

mkdir -p /opt/blog
aws s3 cp s3://hwi-blog-artifacts-073072374949/blog /opt/blog/blog --region $REGION
chmod +x /opt/blog/blog

cat > /etc/blog.env <<EOF
PORT=8080
AWS_REGION=$REGION
DB_DSN=$(get DB_DSN)
ADMIN_USER=$(get ADMIN_USER)
ADMIN_PASS=$(get ADMIN_PASS)
S3_BUCKET=$(get S3_BUCKET)
EOF
chmod 600 /etc/blog.env

cat > /etc/systemd/system/blog.service <<'EOF'
[Unit]
Description=Hwi's Developer Diary
After=network-online.target
Wants=network-online.target

[Service]
User=ec2-user
WorkingDirectory=/opt/blog
EnvironmentFile=/etc/blog.env
ExecStart=/opt/blog/blog
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now blog
