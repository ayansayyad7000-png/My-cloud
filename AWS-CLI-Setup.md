# 🧰 Practical 1 — AWS CLI Setup on Ubuntu EC2

> **Goal:** Install AWS CLI v2 on an Ubuntu EC2 instance, verify the installation, and test AWS access safely.

## Before You Start

You will use two places:

- 🌐 **AWS Management Console** — https://console.aws.amazon.com/
- 💻 **EC2 Ubuntu Terminal** — opened using EC2 Instance Connect or SSH

---

## Step 1 — Open Your EC2 Instance

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances** → **Instances**

**🧭 WHAT TO DO**
1. Select your Ubuntu EC2 instance.
2. Make sure **Instance state = Running**.
3. Click **Connect**.
4. Choose **EC2 Instance Connect**.
5. Click **Connect** again.

**✅ CHECK**  
A browser terminal should open and you should see a prompt similar to:

```text
ubuntu@ip-xxx-xxx-xxx-xxx:~$
```

➡️ Keep this terminal open for the next steps.

---

## Step 2 — Update Ubuntu Package Information

**🌐 WHERE TO GO**  
EC2 Ubuntu Terminal

**💻 COMMAND**

```bash
sudo apt update -y
```

**📝 WHAT IT DOES**  
Downloads the latest package information from Ubuntu repositories. This does not upgrade everything; it refreshes the package list.

**✅ CHECK**  
The command should finish and return to the terminal prompt without a fatal error.

---

## Step 3 — Install Required Tools

**🌐 WHERE TO GO**  
EC2 Ubuntu Terminal

**💻 COMMAND**

```bash
sudo apt install -y curl unzip
```

**📝 WHAT IT DOES**
- `curl` downloads the AWS CLI installer.
- `unzip` extracts the downloaded ZIP file.
- `-y` automatically confirms the installation prompt.

**✅ CHECK**

```bash
curl --version
unzip -v
```

If both commands show version information, continue.

---

## Step 4 — Download AWS CLI v2

**🌐 WHERE TO GO**  
EC2 Ubuntu Terminal

**💻 COMMAND**

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

**📝 WHAT IT DOES**  
Downloads the official AWS CLI v2 Linux installer and saves it as `awscliv2.zip`.

**✅ CHECK**

```bash
ls -lh awscliv2.zip
```

You should see the ZIP file in the current folder.

---

## Step 5 — Extract the Installer

**🌐 WHERE TO GO**  
EC2 Ubuntu Terminal

**💻 COMMAND**

```bash
unzip -q awscliv2.zip
```

**📝 WHAT IT DOES**  
Extracts the installer into a folder named `aws`.

**✅ CHECK**

```bash
ls -la
```

Look for:

```text
aws/
awscliv2.zip
```

---

## Step 6 — Install AWS CLI v2

**🌐 WHERE TO GO**  
EC2 Ubuntu Terminal

**💻 COMMAND**

```bash
sudo ./aws/install
```

**📝 WHAT IT DOES**  
Runs the AWS CLI installer with administrator permission.

**✅ CHECK**

```bash
aws --version
```

Expected format:

```text
aws-cli/2.x.x Python/... Linux/...
```

---

## Step 7 — Attach an IAM Role to EC2 (Recommended)

> On EC2, an IAM Role is safer than saving long-term Access Keys on the server.

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances** → select your instance

**🧭 WHAT TO DO**
1. Click **Actions**.
2. Open **Security**.
3. Click **Modify IAM role**.
4. Select a role that has the AWS permissions required for your practical.
5. Click **Update IAM role**.

If you do not already have a role:

**AWS Console → IAM → Roles → Create role → AWS service → EC2**

Attach only the permissions required for your lab.

**✅ CHECK**  
Return to the EC2 terminal and run:

```bash
aws sts get-caller-identity
```

If access is working, AWS returns your Account, ARN and UserId/role information.

---

## Step 8 — Test Basic AWS CLI Commands

**🌐 WHERE TO GO**  
EC2 Ubuntu Terminal

Check your configured/default region:

```bash
aws configure get region
```

List S3 buckets that your IAM permissions allow you to see:

```bash
aws s3 ls
```

List one specific bucket:

```bash
aws s3 ls s3://YOUR-BUCKET-NAME
```

**📝 WHAT IT DOES**  
These commands confirm that AWS CLI is installed and able to communicate with AWS services.

**✅ CHECK**  
You should receive a result from AWS instead of `command not found`.

---

## Step 9 — Optional: Configure AWS CLI on a Local Computer

> Use this only when you intentionally need a named CLI configuration on your own trusted machine. For an EC2 instance, prefer the IAM Role method from Step 7.

**🌐 WHERE TO GO**  
Your local Terminal / PowerShell / Command Prompt

**💻 COMMAND**

```bash
aws configure
```

AWS may ask for:

```text
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]: ap-south-1
Default output format [None]: json
```

**🔐 SECURITY**  
Never paste Access Keys into GitHub, screenshots, assignments or public chats.

---

## Step 10 — Know Where AWS CLI Stores Local Configuration

**🌐 WHERE TO GO**  
Terminal on the machine where you used `aws configure`

Go to the AWS configuration directory:

```bash
cd ~/.aws
```

List files:

```bash
ls -la
```

Typical files are:

```text
config
credentials
```

**⚠️ IMPORTANT**  
The `credentials` file is sensitive. Do not upload or commit it.

---

## Step 11 — Clean Up After the Practical

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances**

**🧭 WHAT TO DO**
1. Select the test EC2 instance.
2. If you need it later, choose **Instance state → Stop instance**.
3. If the lab is completely finished and the instance is no longer needed, choose **Instance state → Terminate instance**.

**✅ FINAL CHECK**

You should now understand this sequence:

```text
AWS Console
   ↓
EC2 Instance
   ↓
Ubuntu Terminal
   ↓
Install AWS CLI
   ↓
Attach IAM Role
   ↓
aws sts get-caller-identity
   ↓
Run AWS CLI commands
```

---

## 🧠 Commands to Remember

```bash
sudo apt update -y
sudo apt install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
aws --version
aws sts get-caller-identity
aws s3 ls
```

## 🔐 Security Reminder

- Prefer IAM Roles on EC2.
- Never commit `.aws/credentials`.
- Never publish Access Key IDs or Secret Access Keys.
