# ☁️ AWS Cloud Practicals

**Name:** Ayan Sayyad  
**Technology:** Amazon Web Services (AWS)  
**Platform:** Ubuntu 24.04 EC2

## About

This repository contains my AWS cloud practicals and hands-on experiments using **AWS EC2, S3, AWS CLI, CloudWatch, EBS, Apache, Linux and Bash**.

Each practical is written in **simple step-by-step format**. Follow the steps in order and run the commands one by one.

---

## ✅ How to Use This Repository

1. Open the practical you want to perform.
2. Read **Step 1** first and complete it.
3. Run the command shown under that step.
4. Check the output before going to the next step.
5. Continue with **Step 2, Step 3, Step 4...** in order.
6. Read the **Important / Security Notes** at the end of the practical.

> Commands are kept separately inside code blocks so they are easy to copy and run.

---

## 📚 Practicals Covered

### Practical 1 — AWS CLI Setup
Install AWS CLI v2 on Ubuntu, verify it and use basic S3 commands.

### Practical 2 — EC2 Web Server
Launch Ubuntu EC2, install Apache and open the website using the EC2 public IP.

### Practical 3 — EC2 Bootstrap / User Data
Use a bootstrap script to automatically install Apache and AWS CLI when EC2 starts.

### Practical 4 — S3 Access from EC2
Give EC2 permission using an IAM role and transfer files between EC2 and S3.

### Practical 5 — CloudWatch Agent Setup
Install and configure the CloudWatch Agent on EC2.

### Practical 6 — CloudWatch Log Monitoring
Send Ubuntu log files from EC2 to CloudWatch Logs.

### Practical 7 — CloudWatch RAM Monitoring
Monitor EC2 memory usage using the CloudWatch Agent.

### Practical 8 — CPU and System Stress Testing
Generate CPU/system load and observe monitoring metrics.

### Practical 9 — EBS Volume Setup and Mounting
Create, attach, format, mount and unmount an EBS volume.

### Practical 10 — Uploading Data to Amazon S3
Upload and download dataset files using AWS CLI for a simple data-pipeline flow.

---

## 🛠️ Technologies Used

- AWS EC2
- Amazon S3
- AWS CLI v2
- Amazon CloudWatch
- Amazon EBS
- Apache2
- Ubuntu 24.04
- Linux
- Bash

---

## 🔐 Important Security Note

AWS Access Keys, Secret Keys, passwords, private keys and other sensitive credentials are **not included** in this repository.

For EC2 access to AWS services, use **IAM Roles** whenever possible instead of storing access keys on the server.

Also terminate EC2 instances and remove unused AWS resources after completing a practical to avoid unnecessary charges.

---

## 👨‍💻 Author

**Ayan Sayyad**  
B.Tech Information Technology
