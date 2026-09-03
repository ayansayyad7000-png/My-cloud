# 🧠 Practical 7 — Monitor EC2 RAM with CloudWatch Agent

> **Goal:** Configure the CloudWatch Agent to collect EC2 memory usage and view the `mem_used_percent` metric in AWS CloudWatch.

## Why This Practical Is Needed

EC2 sends several basic metrics to CloudWatch automatically, but **RAM/memory utilization is not a standard EC2 metric**. The CloudWatch Agent running inside Ubuntu can collect it.

```text
Ubuntu RAM
   ↓
CloudWatch Agent
   ↓
CWAgent Namespace
   ↓
mem_used_percent
   ↓
CloudWatch Graph
```

---

## Step 1 — Create the CloudWatch IAM Role

**🌐 WHERE TO GO**  
AWS Console → **IAM** → **Roles** → **Create role**

**🧭 WHAT TO DO**
1. Trusted entity → **AWS service**.
2. Use case → **EC2**.
3. Add permission:

```text
CloudWatchAgentServerPolicy
```

4. Name the role:

```text
EC2-CloudWatch-Agent-Role
```

5. Click **Create role**.

---

## Step 2 — Attach the Role to EC2

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances** → select instance

**🧭 WHAT TO DO**
1. **Actions** → **Security** → **Modify IAM role**.
2. Select `EC2-CloudWatch-Agent-Role`.
3. Click **Update IAM role**.

**✅ CHECK**  
Confirm the role appears in the instance details.

---

## Step 3 — Connect to Ubuntu EC2

**🌐 WHERE TO GO**  
EC2 → Instances → select instance → **Connect** → **EC2 Instance Connect** → **Connect**

---

## Step 4 — Check Current Memory Before Monitoring

**🌐 WHERE TO GO**  
EC2 terminal

```bash
free -h
```

**📝 WHAT IT SHOWS**  
Displays total, used, free and available RAM inside Ubuntu.

For a live system view, you can also run:

```bash
top
```

Press `q` to exit `top`.

---

## Step 5 — Download the CloudWatch Agent

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo apt update -y
```

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

## Step 7 — Configure RAM Collection

**🌐 WHERE TO GO**  
EC2 terminal

Start the wizard:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

**🧭 WHAT TO DO**  
Use the wizard to create an EC2/Linux configuration and enable memory metrics.

The important metric for this practical is:

```text
mem_used_percent
```

For optional services you are not using, such as CollectD or StatsD, choose **No**.

> Wizard wording can vary slightly. The objective is to save a configuration that includes memory collection.

**✅ CHECK**

A common configuration path is:

```text
/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

Check it exists:

```bash
sudo ls -lh /opt/aws/amazon-cloudwatch-agent/bin/config.json
```

Search the config for memory settings:

```bash
sudo grep -n "mem" /opt/aws/amazon-cloudwatch-agent/bin/config.json
```

---

## Step 8 — Start the Agent

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

### Read the command

```text
fetch-config → load config.json
-m ec2      → EC2 mode
-s          → start agent
-c file:... → location of your config
```

---

## Step 9 — Verify Agent Status

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a status \
  -m ec2
```

**✅ CHECK**  
The agent should show a running status.

---

## Step 10 — Open RAM Metrics in CloudWatch

**🌐 WHERE TO GO**  
AWS Console → **CloudWatch** → **Metrics** → **All metrics**

Direct entry: https://console.aws.amazon.com/cloudwatch/

**🧭 WHAT TO DO**
1. Open **All metrics**.
2. Find the namespace:

```text
CWAgent
```

3. Open the dimension group that contains your EC2 instance.
4. Find/select:

```text
mem_used_percent
```

5. A graph should appear.

**✅ CHECK**  
You should now see memory utilization as a percentage.

---

## Step 11 — Generate a Small RAM Load for Testing

> Use a controlled test. Do not allocate most of the RAM on a small EC2 instance.

**🌐 WHERE TO GO**  
EC2 terminal

Install `stress`:

```bash
sudo apt install -y stress
```

Check free memory first:

```bash
free -h
```

Run a short memory test using 256 MB for 2 minutes:

```bash
stress --vm 1 --vm-bytes 256M --vm-keep --timeout 120
```

### Understand the command

```text
--vm 1          → start one memory worker
--vm-bytes 256M → allocate about 256 MB
--vm-keep       → keep touching the allocated memory
--timeout 120   → stop automatically after 120 seconds
```

> If your instance has very little available memory, use a smaller value such as `128M`.

---

## Step 12 — Watch RAM During the Test

Open a second EC2 terminal if possible and run:

```bash
free -h
```

For live updates every 2 seconds:

```bash
watch -n 2 free -h
```

Press:

```text
Ctrl + C
```

to stop `watch`.

---

## Step 13 — Check the CloudWatch Graph Again

**🌐 WHERE TO GO**  
CloudWatch → **Metrics** → **All metrics** → **CWAgent** → `mem_used_percent`

**🧭 WHAT TO DO**
1. Refresh the graph.
2. Select an appropriate recent time range.
3. Compare the graph before and during the stress test.

**✅ FINAL CHECK**  
You should see memory usage increase while the test was running and reduce afterward.

---

## Step 14 — Troubleshoot Missing RAM Metrics

### A. Check agent status

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status -m ec2
```

### B. Confirm memory exists in config

```bash
sudo grep -n "mem" /opt/aws/amazon-cloudwatch-agent/bin/config.json
```

### C. Check agent log

```bash
sudo tail -n 100 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

### D. Check IAM role

AWS Console → EC2 → Instances → select instance → confirm `CloudWatchAgentServerPolicy` is available through the attached role.

### E. Check the correct CloudWatch namespace

Look under:

```text
CloudWatch → Metrics → All metrics → CWAgent
```

not only the standard `AWS/EC2` namespace.

---

## 🧠 Easy Memory Flow

```text
IAM CloudWatch Role
       ↓
Attach to EC2
       ↓
Install Agent
       ↓
Wizard: enable memory
       ↓
Start Agent
       ↓
CloudWatch → CWAgent
       ↓
mem_used_percent
       ↓
Run small RAM stress test
       ↓
Watch graph change
```

## Commands to Remember

```bash
free -h
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status -m ec2
stress --vm 1 --vm-bytes 256M --vm-keep --timeout 120
watch -n 2 free -h
```

## ⚠️ Important

- RAM metrics come from `CWAgent`, not standard EC2 metrics.
- Use small, controlled memory loads on low-memory instances.
- Stop unnecessary tests and AWS resources after the lab.
- Do not use old CloudWatch monitoring scripts for a new setup.
