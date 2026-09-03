#!/bin/bash

# ============================================================
# EC2 Bootstrap Script - Apache Web Server
# Author: Ayan Sayyad
# Platform: Ubuntu EC2
#
# Use this script in:
# AWS Console -> EC2 -> Launch instance -> Advanced details
# -> User data
# ============================================================

# Stop the script when an important command fails.
set -e

# Step 1: Refresh Ubuntu package information.
apt update -y

# Step 2: Install Apache Web Server.
apt install -y apache2

# Step 3: Create a simple home page so we can verify the server.
cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ayan Sayyad | AWS EC2</title>
</head>
<body>
  <h1>Ayan Sayyad - AWS EC2 Bootstrap</h1>
  <p>Apache was installed automatically using EC2 User Data.</p>
</body>
</html>
EOF

# Step 4: Enable Apache so it starts automatically after reboot.
systemctl enable apache2

# Step 5: Start/restart Apache immediately.
systemctl restart apache2

# Step 6: Save a completion file for easy troubleshooting.
printf 'EC2 bootstrap completed successfully\n' > /var/tmp/bootstrap-complete.txt

# After the instance starts, verify with:
# cat /var/tmp/bootstrap-complete.txt
# systemctl status apache2 --no-pager
# curl http://localhost
#
# Then open in your browser:
# http://EC2-PUBLIC-IP
