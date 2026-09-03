# AWS CLI Setup on Ubuntu — Ayan Sayyad

## Simple Step-by-Step Guide

Follow these steps **in order**. Run one command at a time and check that it works before moving to the next step.

---

## Step 1 — Check Python

First check whether Python 3 is already installed:

```bash
python3 --version
```

If Python is not installed, install it:

```bash
sudo apt update
sudo apt install python3 -y
```

---

## Step 2 — Download AWS CLI v2

Download the official AWS CLI v2 installer:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

---

## Step 3 — Install unzip

The downloaded file is a ZIP file, so install `unzip`:

```bash
sudo apt install unzip -y
```

---

## Step 4 — Extract AWS CLI

Extract the ZIP file:

```bash
unzip awscliv2.zip
```

---

## Step 5 — Install AWS CLI

Run the AWS installer:

```bash
sudo ./aws/install
```

---

## Step 6 — Check the Installation

Check the installed AWS CLI version:

```bash
aws --version
```

You can also open AWS CLI help:

```bash
aws help
```

---

## Step 7 — Configure AWS CLI

Run:

```bash
aws configure
```

Enter the required details when asked:

```text
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]:
Default output format [None]:
```

Example format:

```text
AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_KEY
Default region name: ap-south-1
Default output format: json
```

> For EC2 practicals, an IAM Role is safer than storing long-term access keys on the server.

---

## Step 8 — Test S3 Access

List S3 buckets:

```bash
aws s3 ls
```

Access a specific S3 bucket:

```bash
aws s3 ls s3://your-bucket-name
```

---

## Step 9 — Locate AWS Configuration Files

Go to the home directory:

```bash
cd ~
```

List files:

```bash
ls -la
```

Open the AWS configuration directory:

```bash
cd ~/.aws
```

List the files:

```bash
ls -la
```

You may see:

```text
config
credentials
```

To view credentials on your own private EC2 terminal:

```bash
cat credentials
```

To edit credentials:

```bash
nano credentials
```

> **Important:** Never copy, screenshot or upload the `credentials` file, AWS Access Key or Secret Key to GitHub.

---

## Step 10 — Remove AWS Credentials When Needed

Delete only the credentials file:

```bash
rm ~/.aws/credentials
```

Or remove the complete AWS configuration directory:

```bash
rm -rf ~/.aws
```

---

## Step 11 — Finish the Practical

After completing the practical, terminate the EC2 instance from the AWS Management Console if it is no longer required.

> **Warning:** Make sure the EC2 instance and its data are no longer needed before terminating it.
