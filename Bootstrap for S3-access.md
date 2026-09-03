# ⚙️ Practical 3 — EC2 Bootstrap / User Data with S3 + Apache

> **Goal:** Launch an EC2 instance that automatically installs Apache and AWS CLI, copies website files from S3, and starts the website during the first boot.

## Understand the Idea First

Normally you would connect to EC2 and type commands manually. With **User Data**, AWS runs a startup script for you.

```text
Launch EC2
   ↓
User Data script starts automatically
   ↓
Install Apache + AWS CLI
   ↓
Copy website from S3
   ↓
Start Apache
   ↓
Open website in browser
```

---

## Step 1 — Prepare an S3 Bucket with Website Files

**🌐 WHERE TO GO**  
AWS Console → search **S3** → **S3** → **Create bucket**

Direct entry: https://s3.console.aws.amazon.com/s3/

**🧭 WHAT TO DO**
1. Create a bucket with a globally unique name.
2. Open the bucket.
3. Click **Upload**.
4. Upload at least an `index.html` file.

Example file:

```html
<h1>Ayan Sayyad - AWS Bootstrap Website</h1>
<p>This page was copied automatically from Amazon S3.</p>
```

**✅ CHECK**  
Your S3 bucket should contain:

```text
index.html
```

Write down your bucket name. You will use it inside the User Data script.

---

## Step 2 — Create an IAM Role for EC2 to Read S3

**🌐 WHERE TO GO**  
AWS Console → search **IAM** → **Roles** → **Create role**

**🧭 WHAT TO DO**
1. Trusted entity type → **AWS service**.
2. Use case → **EC2**.
3. Add an S3 permission that allows reading from your lab bucket.
4. Give the role a clear name such as:

```text
EC2-S3-Read-Role
```

5. Click **Create role**.

**📝 WHY THIS IS NEEDED**  
The bootstrap script uses `aws s3 cp`. The EC2 instance needs permission to read the bucket without hard-coding Access Keys.

---

## Step 3 — Start Creating the EC2 Instance

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances** → **Launch instances**

**🧭 WHAT TO DO**
1. Name: `Ayan-Bootstrap-EC2`
2. AMI: **Ubuntu Server 24.04 LTS**
3. Select an appropriate small instance type for the lab.
4. Select/create a key pair if required.

Do not launch yet.

---

## Step 4 — Configure Network Access

**🌐 WHERE TO GO**  
Same EC2 launch page → **Network settings**

**🧭 WHAT TO DO**
Enable:

```text
SSH  → Port 22
HTTP → Port 80
```

HTTP port 80 is required so the Apache website can open in your browser.

---

## Step 5 — Attach the IAM Role

**🌐 WHERE TO GO**  
Same launch page → **Advanced details**

**🧭 WHAT TO DO**  
Find **IAM instance profile** and select the role created in Step 2.

Example:

```text
EC2-S3-Read-Role
```

**✅ CHECK**  
The correct IAM role should be visible before you launch the instance.

---

## Step 6 — Open the User Data Box

**🌐 WHERE TO GO**  
Same **Advanced details** section → scroll to **User data**

**🧭 WHAT TO DO**  
Paste the complete script from Step 7 into the User Data text box.

---

## Step 7 — Paste the Bootstrap Script

> Replace `YOUR-BUCKET-NAME` with the S3 bucket you created in Step 1.

**💻 USER DATA SCRIPT**

```bash
#!/bin/bash

# Stop if an important command fails and print commands in the boot log
set -eux

# 1) Refresh Ubuntu package information
apt update -y

# 2) Install Apache and tools required for AWS CLI v2
apt install -y apache2 unzip curl

# 3) Download AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"

# 4) Extract AWS CLI installer
cd /tmp
unzip -q awscliv2.zip

# 5) Install AWS CLI v2
./aws/install

# 6) Copy all website files from S3 into Apache web root
aws s3 cp s3://YOUR-BUCKET-NAME/ /var/www/html/ --recursive

# 7) Enable Apache so it starts after reboot
systemctl enable apache2

# 8) Start/restart Apache now
systemctl restart apache2

# 9) Save a simple completion marker for troubleshooting
printf 'Bootstrap completed successfully\n' > /var/tmp/bootstrap-complete.txt
```

### What this script does

| Part | Purpose |
|---|---|
| `apt update` | Refresh Ubuntu package information |
| `apt install` | Install Apache, curl and unzip |
| `curl ... awscliv2.zip` | Download AWS CLI v2 |
| `unzip` | Extract the installer |
| `./aws/install` | Install AWS CLI |
| `aws s3 cp ... --recursive` | Copy all website files from S3 |
| `systemctl enable` | Start Apache automatically after reboot |
| `systemctl restart` | Start Apache immediately |
| completion file | Gives you an easy way to confirm the script finished |

---

## Step 8 — Launch the EC2 Instance

**🌐 WHERE TO GO**  
Right side of the EC2 launch page

**🧭 WHAT TO DO**
1. Click **Launch instance**.
2. Click **View all instances**.
3. Wait for **Running** status.
4. Give User Data a little time to finish during the first boot.

---

## Step 9 — Check Whether User Data Finished

**🌐 WHERE TO GO**  
EC2 → Instances → select instance → **Connect** → **EC2 Instance Connect** → **Connect**

Check the completion marker:

```bash
cat /var/tmp/bootstrap-complete.txt
```

Expected output:

```text
Bootstrap completed successfully
```

Check AWS CLI:

```bash
aws --version
```

Check Apache:

```bash
sudo systemctl status apache2 --no-pager
```

---

## Step 10 — Check the Copied Website Files

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
ls -lah /var/www/html/
```

You should see the files that came from S3.

Check the homepage:

```bash
cat /var/www/html/index.html
```

---

## Step 11 — Open the Website

**🌐 WHERE TO GO**  
AWS Console → EC2 → Instances → select instance → copy **Public IPv4 address**

Then open Chrome / Edge / Firefox and enter:

```text
http://YOUR-PUBLIC-IP
```

**✅ FINAL CHECK**  
The `index.html` uploaded to S3 should appear in your browser.

---

## If Bootstrap Does Not Work

### Check the cloud-init/User Data log

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo tail -n 100 /var/log/cloud-init-output.log
```

For live viewing:

```bash
sudo tail -f /var/log/cloud-init-output.log
```

Press `Ctrl + C` to stop live viewing.

### Test the IAM role

```bash
aws sts get-caller-identity
```

### Test S3 access

```bash
aws s3 ls s3://YOUR-BUCKET-NAME/
```

### Check Apache

```bash
sudo systemctl status apache2 --no-pager
curl http://localhost
```

---

## 🧠 Easy Memory Flow

```text
S3: Upload website
        ↓
IAM: Give EC2 permission
        ↓
EC2: Launch Ubuntu
        ↓
Advanced details: Paste User Data
        ↓
Launch instance
        ↓
Script installs everything automatically
        ↓
Browser: http://PUBLIC-IP
```

## 🔐 Important

- Never put AWS Access Keys inside User Data.
- Use an IAM Role attached to EC2.
- Replace `YOUR-BUCKET-NAME` before launching.
- Make sure HTTP port 80 is open.
- User Data runs automatically during the initial boot; use the cloud-init log when troubleshooting.
