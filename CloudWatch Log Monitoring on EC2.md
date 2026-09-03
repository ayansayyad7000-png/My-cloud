# 📜 Practical 6 — Monitor EC2 Logs with Amazon CloudWatch

> **Goal:** Install/configure the CloudWatch Agent on Ubuntu EC2 and send a Linux log file to **CloudWatch Logs**.

## Screens Used

```text
AWS Console → IAM
AWS Console → EC2
EC2 Ubuntu Terminal
AWS Console → CloudWatch → Logs
```

---

## Step 1 — Create the IAM Role

**🌐 WHERE TO GO**  
AWS Console → **IAM** → **Roles** → **Create role**

**🧭 WHAT TO DO**
1. Trusted entity → **AWS service**.
2. Use case → **EC2**.
3. Add:

```text
CloudWatchAgentServerPolicy
```

4. Name the role:

```text
EC2-CloudWatch-Agent-Role
```

5. Click **Create role**.

**📝 WHY**  
CloudWatch Agent needs permission to create/use log streams and send log events.

---

## Step 2 — Attach the IAM Role to EC2

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances** → select instance

**🧭 WHAT TO DO**
1. **Actions** → **Security** → **Modify IAM role**.
2. Select `EC2-CloudWatch-Agent-Role`.
3. Click **Update IAM role**.

**✅ CHECK**  
The role should appear in the instance details.

---

## Step 3 — Open the EC2 Terminal

**🌐 WHERE TO GO**  
EC2 → Instances → select instance → **Connect** → **EC2 Instance Connect** → **Connect**

---

## Step 4 — Check the Log File You Want to Monitor

For this lab we will use:

```text
/var/log/syslog
```

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo ls -lh /var/log/syslog
```

View recent lines:

```bash
sudo tail -n 20 /var/log/syslog
```

**✅ CHECK**  
You should see log entries.

### If `/var/log/syslog` does not exist

Install/start `rsyslog`:

```bash
sudo apt update -y
sudo apt install -y rsyslog
sudo systemctl enable --now rsyslog
```

Check again:

```bash
sudo ls -lh /var/log/syslog
```

---

## Step 5 — Download the CloudWatch Agent

**🌐 WHERE TO GO**  
EC2 terminal

```bash
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
```

**✅ CHECK**

```bash
ls -lh amazon-cloudwatch-agent.deb
```

---

## Step 6 — Install the Agent

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
```

**✅ CHECK**

```bash
ls -la /opt/aws/amazon-cloudwatch-agent/bin/
```

---

## Step 7 — Start the Configuration Wizard

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

**🧭 WHAT TO DO**  
When the wizard reaches log collection, add the log file:

```text
/var/log/syslog
```

Suggested lab values:

```text
Log file path: /var/log/syslog
Log group name: /ec2/ubuntu/syslog
Log stream name: {instance_id}
```

For options such as CollectD or StatsD that you are not using in this lab, choose **No**.

> Wizard wording can vary slightly by CloudWatch Agent version. The important idea is: select `/var/log/syslog`, choose a log group name, and complete/save the configuration.

**✅ CHECK**  
A common local configuration path is:

```text
/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

Check it:

```bash
sudo ls -lh /opt/aws/amazon-cloudwatch-agent/bin/config.json
```

---

## Step 8 — Start the CloudWatch Agent

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

### Understand the long command

```text
fetch-config → load your configuration
-m ec2      → run in EC2 mode
-s          → start the agent
-c file:... → read the local config.json
```

---

## Step 9 — Check Agent Status

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a status \
  -m ec2
```

**✅ CHECK**  
The agent should report a running status.

---

## Step 10 — Generate a Test Log Message

Instead of waiting for random system activity, create a clear test entry.

**🌐 WHERE TO GO**  
EC2 terminal

```bash
logger "AYAN-CLOUDWATCH-TEST: CloudWatch log pipeline is working"
```

Confirm it reached syslog:

```bash
sudo tail -n 30 /var/log/syslog | grep "AYAN-CLOUDWATCH-TEST"
```

**✅ CHECK**  
You should see the test message locally first.

---

## Step 11 — Open CloudWatch Logs

**🌐 WHERE TO GO**  
AWS Console → **CloudWatch** → **Logs** → **Log groups**

Direct CloudWatch entry: https://console.aws.amazon.com/cloudwatch/

**🧭 WHAT TO DO**
1. Open **Log groups**.
2. Find:

```text
/ec2/ubuntu/syslog
```

3. Open the log group.
4. Open the log stream for your EC2 instance.
5. Search for:

```text
AYAN-CLOUDWATCH-TEST
```

**✅ FINAL CHECK**  
If the same message appears in CloudWatch Logs, the EC2 → CloudWatch log pipeline is working.

---

## Step 12 — Troubleshoot if Logs Do Not Appear

Follow this order.

### A. Is the local log file receiving data?

```bash
sudo tail -n 30 /var/log/syslog
```

### B. Is the CloudWatch Agent running?

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status -m ec2
```

### C. Check the agent log

```bash
sudo tail -n 100 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

### D. Verify IAM Role

**AWS Console → EC2 → Instances → select instance → Security / Details**

Confirm the instance has a role containing:

```text
CloudWatchAgentServerPolicy
```

### E. Generate another test log

```bash
logger "AYAN-CLOUDWATCH-TEST-2: second test event"
```

Then refresh the CloudWatch log stream.

---

## 🚫 Do Not Use the Old CloudWatch Logs Agent Setup

Do not use legacy commands such as:

```bash
curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
```

```bash
sudo python3 ./awslogs-agent-setup.py
```

For this lab, use the **Amazon CloudWatch Agent**.

---

## 🧠 Easy Memory Flow

```text
IAM Role
   ↓
Attach to EC2
   ↓
Check /var/log/syslog
   ↓
Install CloudWatch Agent
   ↓
Wizard: select syslog
   ↓
Start Agent
   ↓
logger "TEST MESSAGE"
   ↓
CloudWatch → Logs → Log groups
   ↓
Find TEST MESSAGE
```

## Commands to Remember

```bash
sudo tail -n 20 /var/log/syslog
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status -m ec2
logger "AYAN-CLOUDWATCH-TEST: CloudWatch log pipeline is working"
sudo tail -n 100 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

## 🔐 Important

- Use an EC2 IAM Role, not hard-coded AWS credentials.
- Do not give unnecessary administrator access.
- Confirm the local log exists before blaming CloudWatch.
- Troubleshoot in this order: **local log → agent status → agent log → IAM → CloudWatch**.
