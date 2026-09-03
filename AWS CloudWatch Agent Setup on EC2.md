# 📊 Practical 5 — AWS CloudWatch Agent Setup on EC2

> **Goal:** Give an EC2 instance permission to publish monitoring data, install the Amazon CloudWatch Agent, configure it, start it, and verify that it is running.

## Screens Used

```text
AWS Console → IAM
AWS Console → EC2
EC2 Ubuntu Terminal
AWS Console → CloudWatch
```

---

## Step 1 — Create a CloudWatch IAM Role

**🌐 WHERE TO GO**  
AWS Console → search **IAM** → **Roles** → **Create role**

**🧭 WHAT TO DO**
1. Trusted entity type → **AWS service**.
2. Use case → **EC2**.
3. Click **Next**.
4. Search for and select:

```text
CloudWatchAgentServerPolicy
```

5. Continue to role details.
6. Give the role a name such as:

```text
EC2-CloudWatch-Agent-Role
```

7. Click **Create role**.

**📝 WHY**  
This role allows the CloudWatch Agent running on EC2 to send metrics and logs to CloudWatch without storing AWS Access Keys on the server.

---

## Step 2 — Attach the Role to Your EC2 Instance

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances** → select your Ubuntu instance

**🧭 WHAT TO DO**
1. Click **Actions**.
2. Open **Security**.
3. Click **Modify IAM role**.
4. Select:

```text
EC2-CloudWatch-Agent-Role
```

5. Click **Update IAM role**.

**✅ CHECK**  
The instance details should now show the IAM role.

---

## Step 3 — Connect to the EC2 Terminal

**🌐 WHERE TO GO**  
EC2 → Instances → select instance → **Connect** → **EC2 Instance Connect** → **Connect**

**✅ CHECK**

```text
ubuntu@ip-xxx-xxx-xxx-xxx:~$
```

---

## Step 4 — Update Ubuntu

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo apt update -y
```

**📝 WHAT IT DOES**  
Refreshes package information before installing software.

---

## Step 5 — Download the CloudWatch Agent Package

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
```

**📝 WHAT IT DOES**  
Downloads the latest Amazon CloudWatch Agent `.deb` package for 64-bit Ubuntu.

**✅ CHECK**

```bash
ls -lh amazon-cloudwatch-agent.deb
```

---

## Step 6 — Install the CloudWatch Agent

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
```

**📝 WHAT IT DOES**  
Installs the CloudWatch Agent package on Ubuntu.

**✅ CHECK**

```bash
ls -la /opt/aws/amazon-cloudwatch-agent/bin/
```

You should see CloudWatch Agent binaries in this directory.

---

## Step 7 — Verify the EC2 IAM Identity

**🌐 WHERE TO GO**  
EC2 terminal

If AWS CLI is already installed, run:

```bash
aws sts get-caller-identity
```

**✅ CHECK**  
The output should show an assumed role ARN related to the IAM role attached to EC2.

> If AWS CLI is not installed, you can continue with the CloudWatch Agent setup; this command is only an extra IAM verification step.

---

## Step 8 — Open the CloudWatch Configuration Wizard

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

**📝 WHAT IT DOES**  
Starts an interactive wizard that asks which metrics/logs the agent should collect.

### Beginner guidance

For a basic EC2 monitoring lab:

```text
Operating system: Linux
Environment: EC2
CollectD: No (unless you installed/configured it)
StatsD: No (unless your lab specifically uses it)
```

Choose the CPU/memory metrics required by your practical. The exact wizard questions can vary slightly by agent version.

**✅ CHECK**  
Complete the wizard and save the configuration.

A common local configuration path is:

```text
/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

Check whether it exists:

```bash
sudo ls -lh /opt/aws/amazon-cloudwatch-agent/bin/config.json
```

---

## Step 9 — Start the CloudWatch Agent with the Configuration

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

### Read this long command easily

```text
-a fetch-config  → load the configuration
-m ec2           → agent is running on EC2
-s               → start the agent
-c file:...       → use this local config.json file
```

**✅ CHECK**  
The command should report that the configuration was processed and the agent was started.

---

## Step 10 — Check CloudWatch Agent Status

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a status \
  -m ec2
```

**✅ CHECK**  
Look for a running status in the returned information.

---

## Step 11 — Check the Agent Log if Something Is Wrong

**🌐 WHERE TO GO**  
EC2 terminal

Show the latest log lines:

```bash
sudo tail -n 50 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

Watch the log live:

```bash
sudo tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

Press:

```text
Ctrl + C
```

to stop live viewing.

---

## Step 12 — Open CloudWatch in AWS Console

**🌐 WHERE TO GO**  
AWS Console → search **CloudWatch** → open **CloudWatch**

Direct entry: https://console.aws.amazon.com/cloudwatch/

**🧭 WHAT TO DO**
1. In the left menu, open **Metrics**.
2. Click **All metrics**.
3. Look for the namespace created by the agent, commonly:

```text
CWAgent
```

4. Open the metric categories and select your EC2 instance/metric.

**✅ CHECK**  
A graph should appear once CloudWatch receives data from the agent.

---

## Step 13 — Optional CPU Test

If you need visible CPU activity for a monitoring lab:

**🌐 WHERE TO GO**  
EC2 terminal

Install `stress`:

```bash
sudo apt install -y stress
```

Run a short 2-minute test:

```bash
stress --cpu 1 --timeout 120
```

**📝 WHAT IT DOES**  
Creates CPU load for 120 seconds and then stops automatically.

Return to:

**CloudWatch → Metrics → All metrics**

and observe the relevant CPU graph.

---

## 🧠 Easy Memory Flow

```text
IAM: Create CloudWatch role
        ↓
EC2: Attach role
        ↓
Terminal: Download agent
        ↓
Terminal: Install agent
        ↓
Wizard: Create config.json
        ↓
amazon-cloudwatch-agent-ctl: START
        ↓
amazon-cloudwatch-agent-ctl: STATUS
        ↓
CloudWatch Console: CHECK METRICS
```

## Commands to Remember

```bash
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status -m ec2
```

## 🔐 Important

- Use `CloudWatchAgentServerPolicy` rather than unnecessary administrator-level access.
- Use an IAM Role instead of storing Access Keys on EC2.
- If metrics do not appear, check IAM role, agent status, configuration and agent logs in that order.
