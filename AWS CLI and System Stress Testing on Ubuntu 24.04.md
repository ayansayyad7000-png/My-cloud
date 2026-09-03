# 🔥 Practical 8 — AWS CLI + CPU, RAM and System Stress Testing on Ubuntu 24.04

> **Goal:** Install useful monitoring/stress tools, generate controlled system load on EC2, watch Linux resource usage, and observe the effect in AWS CloudWatch.

## ⚠️ Important Before You Run Stress Tests

Stress tools intentionally consume CPU, memory or disk resources.

For normal labs:

```text
Use short tests
Use controlled values
Watch the instance while testing
Stop the test when finished
```

Do not leave an unlimited stress process running unnecessarily.

---

## Step 1 — Open the EC2 Instance

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances** → select your Ubuntu instance

**🧭 WHAT TO DO**
1. Make sure the instance is **Running**.
2. Click **Connect**.
3. Choose **EC2 Instance Connect**.
4. Click **Connect**.

---

## Step 2 — Check the Server Before Testing

**🌐 WHERE TO GO**  
EC2 terminal

Check CPU count:

```bash
nproc
```

Check CPU/system details:

```bash
lscpu
```

Check memory:

```bash
free -h
```

Check disk space:

```bash
df -h
```

**📝 WHY**  
Always know the size of your instance before deciding how much load to generate.

---

## Step 3 — Update Ubuntu and Install Basic Tools

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo apt update -y
```

Install AWS CLI download tools and basic stress tool:

```bash
sudo apt install -y curl unzip stress
```

---

## Step 4 — Install AWS CLI v2

Download:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

Extract:

```bash
unzip -q awscliv2.zip
```

Install:

```bash
sudo ./aws/install
```

Check:

```bash
aws --version
```

If an IAM role is attached, you can also check:

```bash
aws sts get-caller-identity
```

---

## Step 5 — Open CloudWatch Before Generating Load

**🌐 WHERE TO GO**  
AWS Console → **CloudWatch** → **Metrics** → **All metrics** → **EC2** → **Per-Instance Metrics**

Direct entry: https://console.aws.amazon.com/cloudwatch/

**🧭 WHAT TO DO**
1. Find your EC2 `InstanceId`.
2. Select:

```text
CPUUtilization
```

3. Keep this page open so you can compare the graph before and after the stress test.

---

## Step 6 — Run a Simple CPU Test for 2 Minutes

**🌐 WHERE TO GO**  
EC2 terminal

Use one CPU worker:

```bash
stress --cpu 1 --timeout 120
```

**📝 COMMAND BREAKDOWN**

```text
--cpu 1      → one CPU worker
--timeout 120 → stop automatically after 120 seconds
```

**✅ CHECK**  
The command stops by itself after about 2 minutes.

---

## Step 7 — Use All CPU Cores for a Short Test

> Only run this when you intentionally want a stronger CPU graph.

```bash
stress --cpu "$(nproc)" --timeout 120
```

**📝 WHAT IT DOES**  
`$(nproc)` automatically returns the number of available CPU cores, so `stress` starts one worker per core.

**✅ CHECK**  
The test stops automatically after 120 seconds.

---

## Step 8 — Monitor CPU While Stress Is Running

Open a second EC2 terminal if possible.

Run:

```bash
top
```

Or use:

```bash
uptime
```

**🧭 WHAT TO LOOK FOR**
- CPU usage increases.
- Load average increases.
- `stress` appears in the process list.

Press:

```text
q
```

to exit `top`.

---

## Step 9 — Check CloudWatch CPU Graph

**🌐 WHERE TO GO**  
CloudWatch → Metrics → All metrics → EC2 → Per-Instance Metrics → `CPUUtilization`

**🧭 WHAT TO DO**
1. Refresh the graph.
2. Use a recent time range.
3. Look for a CPU spike during your stress test.

**✅ CHECK**  
You should see higher CPU utilization compared with the idle period.

---

## Step 10 — Install Advanced Monitoring and Stress Tools

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo apt update -y
sudo apt install -y stress-ng sysstat iotop iftop
```

Check:

```bash
stress-ng --version
```

### Tools installed

```text
stress-ng → advanced CPU/RAM/I/O load generator
sysstat   → provides iostat and other system statistics
iotop     → shows disk I/O by process
iftop     → shows network traffic
```

---

## Step 11 — Run a Controlled Mixed System Test

This is a bigger command, so read the explanation before running it.

**💻 COMMAND**

```bash
stress-ng \
  --cpu 1 \
  --cpu-load 50 \
  --vm 1 \
  --vm-bytes 256M \
  --io 1 \
  --timeout 300s \
  --metrics-brief
```

### Command breakdown

```text
--cpu 1         → one CPU stress worker
--cpu-load 50   → target about 50% CPU load for that worker
--vm 1          → one memory worker
--vm-bytes 256M → use about 256 MB RAM
--io 1          → one I/O worker
--timeout 300s  → stop automatically after 5 minutes
--metrics-brief → print a short result summary
```

> If your EC2 instance has very little available RAM, change `256M` to `128M`.

**✅ CHECK**  
The command should stop automatically after 5 minutes and print a metrics summary.

---

## Step 12 — Run the Mixed Test in the Background

If you need to keep the test running while you use the same terminal for other commands:

```bash
nohup stress-ng \
  --cpu 1 \
  --cpu-load 50 \
  --vm 1 \
  --vm-bytes 256M \
  --io 1 \
  --timeout 300s \
  --metrics-brief \
  > /tmp/stress-ng.out 2>&1 & echo $! > /tmp/stress.pid
```

### What the final part means

```text
> /tmp/stress-ng.out 2>&1 → save normal + error output to a file
&                         → run in background
echo $!                   → get the new background process ID
> /tmp/stress.pid         → save that PID so it is easy to stop later
```

**✅ CHECK**

```bash
cat /tmp/stress.pid
```

Then:

```bash
ps -p "$(cat /tmp/stress.pid)" -o pid,cmd
```

---

## Step 13 — Monitor Different Resources

### CPU and processes

```bash
top
```

### Memory

```bash
free -h
```

Live memory refresh every 2 seconds:

```bash
watch -n 2 free -h
```

### CPU and disk statistics

```bash
iostat -xz 2
```

### Disk I/O by process

```bash
sudo iotop
```

### Network traffic

```bash
sudo iftop
```

Use `Ctrl + C` to stop continuous monitoring commands when needed.

---

## Step 14 — View the Background Stress Output

**🌐 WHERE TO GO**  
EC2 terminal

```bash
cat /tmp/stress-ng.out
```

For live output:

```bash
tail -f /tmp/stress-ng.out
```

Press `Ctrl + C` to exit live viewing.

---

## Step 15 — Stop the Background Test Early if Needed

Check PID:

```bash
cat /tmp/stress.pid
```

Stop normally:

```bash
kill "$(cat /tmp/stress.pid)"
```

Verify:

```bash
ps -p "$(cat /tmp/stress.pid)" -o pid,cmd
```

If the process is gone, the command may return no process row.

Only if a process refuses to stop and you understand the impact, force stop it:

```bash
kill -9 "$(cat /tmp/stress.pid)"
```

---

## Step 16 — Final CloudWatch Check

**🌐 WHERE TO GO**  
AWS Console → CloudWatch → Metrics

Check:

```text
AWS/EC2 → CPUUtilization
```

If you previously configured the CloudWatch Agent, you can also check additional `CWAgent` metrics such as memory.

Compare:

```text
Before test → idle values
During test → higher resource usage
After test  → values return toward normal
```

---

## 🧠 Easy Memory Flow

```text
Check instance size
       ↓
Open CloudWatch graph
       ↓
Run SHORT stress test
       ↓
Monitor with top/free/iostat
       ↓
Check CloudWatch spike
       ↓
Run advanced stress-ng if needed
       ↓
STOP / verify process
```

## Commands to Remember

```bash
nproc
free -h
stress --cpu 1 --timeout 120
stress --cpu "$(nproc)" --timeout 120
stress-ng --cpu 1 --cpu-load 50 --vm 1 --vm-bytes 256M --io 1 --timeout 300s --metrics-brief
top
iostat -xz 2
```

## ⚠️ Safety Reminder

- Prefer tests with a finite `--timeout`.
- Use smaller RAM values on smaller instances.
- Do not leave stress tests running after the lab.
- Stop or terminate unused EC2 resources to avoid unnecessary charges.
