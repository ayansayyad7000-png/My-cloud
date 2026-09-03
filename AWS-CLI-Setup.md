# AWS CLI Setup on Ubuntu — Ayan Sayyad

## Check your Python installation

```bash
python3 --version
```

## Install Python

```bash
sudo apt update
sudo apt install python3 -y
```

## Install AWS CLI

> AWS CLI v2 ko ab `pip` aur `get-pip.py` se install karne ki zarurat nahi hai.

Download AWS CLI v2:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

Install unzip:

```bash
sudo apt install unzip -y
```

Extract AWS CLI:

```bash
unzip awscliv2.zip
```

Install AWS CLI:

```bash
sudo ./aws/install
```

## Test the AWS CLI Installation

```bash
aws --version
```

You can also check:

```bash
aws help
```

## Configure AWS CLI

```bash
aws configure
```

Enter the required details:

```text
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]:
Default output format [None]:
```

Example:

```text
AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_KEY
Default region name: ap-south-1
Default output format: json
```

## Accessing S3 Buckets

List all S3 buckets:

```bash
aws s3 ls
```

Access a specific S3 bucket:

```bash
aws s3 ls s3://your-bucket-name
```

## Locate the AWS Credentials

Go to the home directory:

```bash
cd ~
```

List files:

```bash
ls -la
```

Go to the AWS configuration directory:

```bash
cd ~/.aws
```

List AWS configuration files:

```bash
ls -la
```

You may see:

```text
config
credentials
```

View credentials:

```bash
cat credentials
```

Edit credentials:

```bash
nano credentials
```

> **Important:** Never upload the `credentials` file, AWS Access Key, or Secret Key to GitHub.

## Delete AWS Credentials

Delete the credentials file:

```bash
rm ~/.aws/credentials
```

If you want to remove the complete AWS configuration:

```bash
rm -rf ~/.aws
```

## Terminate the EC2 Instance

After completing the practical, terminate the **Ayan Sayyad's EC2 instance** from the AWS Management Console if it is no longer required.

> **Warning:** Make sure the EC2 instance is no longer needed before terminating it.
