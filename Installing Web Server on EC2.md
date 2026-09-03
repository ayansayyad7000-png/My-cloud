# 🌐 Practical 2 — Install Apache Web Server on AWS EC2

> **Goal:** Launch an Ubuntu EC2 instance, install Apache, create a simple web page, and open it using the EC2 Public IPv4 address.

## Screens Used in This Practical

```text
AWS Console → EC2
EC2 Instance Connect Terminal
Web Browser
```

---

## Step 1 — Open Amazon EC2

**🌐 WHERE TO GO**  
AWS Management Console → search **EC2** → open **EC2**

Direct console entry: https://console.aws.amazon.com/ec2/

**🧭 WHAT TO DO**
1. In the left menu, click **Instances**.
2. Click **Launch instances**.

➡️ You should now be on the EC2 launch page.

---

## Step 2 — Configure the EC2 Instance

**🌐 WHERE TO GO**  
EC2 → **Launch an instance** page

**🧭 WHAT TO DO**

### Name
Enter a name such as:

```text
Ayan-Apache-Web-Server
```

### Operating System
Under **Application and OS Images**, select:

```text
Ubuntu Server 24.04 LTS
```

### Instance Type
For a basic lab, select an eligible small instance type available in your account.

### Key Pair
Choose an existing key pair or create one if you plan to use SSH.

**✅ CHECK**  
Do not launch yet. Configure the network rules in the next step.

---

## Step 3 — Allow SSH and HTTP in the Security Group

**🌐 WHERE TO GO**  
Same **Launch an instance** page → **Network settings**

**🧭 WHAT TO DO**
1. Keep **Allow SSH traffic** enabled if you need SSH access.
2. Enable **Allow HTTP traffic from the internet**.

Required ports:

```text
SSH   → TCP 22
HTTP  → TCP 80
```

**📝 WHAT IT DOES**  
Port 22 allows terminal access. Port 80 allows a web browser to reach Apache.

**✅ CHECK**  
Make sure an inbound rule for HTTP port 80 exists.

---

## Step 4 — Launch the Instance

**🌐 WHERE TO GO**  
Right side of the EC2 launch page

**🧭 WHAT TO DO**
1. Review the settings.
2. Click **Launch instance**.
3. Click **View all instances**.
4. Wait until **Instance state = Running**.
5. Also wait until **Status check = 2/2 checks passed** when possible.

➡️ Now connect to the server.

---

## Step 5 — Connect to the Ubuntu Terminal

**🌐 WHERE TO GO**  
EC2 → **Instances** → select your instance → **Connect**

**🧭 WHAT TO DO**
1. Select the **EC2 Instance Connect** tab.
2. Keep the username as `ubuntu`.
3. Click **Connect**.

**✅ CHECK**  
You should see a terminal similar to:

```text
ubuntu@ip-xxx-xxx-xxx-xxx:~$
```

---

## Step 6 — Update Ubuntu

**🌐 WHERE TO GO**  
EC2 Instance Connect terminal

**💻 COMMAND**

```bash
sudo apt update -y
```

**📝 WHAT IT DOES**  
Refreshes Ubuntu's package list before installing Apache.

**✅ CHECK**  
Wait until the command finishes and the terminal prompt returns.

---

## Step 7 — Install Apache Web Server

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo apt install apache2 -y
```

**📝 WHAT IT DOES**  
Downloads and installs the Apache2 web server and its required packages.

**✅ CHECK**

```bash
apache2 -v
```

You should see Apache version information.

---

## Step 8 — Start and Enable Apache

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo systemctl enable --now apache2
```

**📝 WHAT IT DOES**
- `enable` makes Apache start automatically after reboot.
- `--now` starts Apache immediately.

**✅ CHECK**

```bash
sudo systemctl status apache2 --no-pager
```

Look for:

```text
Active: active (running)
```

---

## Step 9 — Create Your Website Home Page

**🌐 WHERE TO GO**  
EC2 terminal

Use this command to create a clean example page in one step:

**💻 COMMAND**

```bash
sudo tee /var/www/html/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ayan Sayyad | AWS EC2</title>
</head>
<body>
  <h1>Welcome to Ayan Sayyad's AWS EC2 Web Server</h1>
  <p>Apache is running successfully on Ubuntu EC2.</p>
  <p>Deployed using AWS + Linux + Apache.</p>
</body>
</html>
EOF
```

**📝 WHAT IT DOES**  
Writes the complete HTML page directly to Apache's default website location:

```text
/var/www/html/index.html
```

**✅ CHECK**

```bash
cat /var/www/html/index.html
```

You should see the HTML content you just created.

---

## Step 10 — Test Apache Inside the EC2 Server

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
curl http://localhost
```

**📝 WHAT IT DOES**  
Requests the website from inside the EC2 server itself.

**✅ CHECK**  
You should see your HTML content in the terminal.

If this works, Apache is running correctly inside EC2.

---

## Step 11 — Find the Public IPv4 Address

**🌐 WHERE TO GO**  
AWS Console → EC2 → **Instances** → select your instance

**🧭 WHAT TO DO**
1. Look at the **Details** tab.
2. Find **Public IPv4 address**.
3. Copy it.

Example:

```text
13.XXX.XXX.XXX
```

---

## Step 12 — Open the Website in Your Browser

**🌐 WHERE TO GO**  
Chrome / Edge / Firefox

Enter:

```text
http://YOUR-PUBLIC-IP
```

Example format:

```text
http://13.XXX.XXX.XXX
```

**✅ FINAL CHECK**  
Your page should display:

```text
Welcome to Ayan Sayyad's AWS EC2 Web Server
```

---

## If the Website Does Not Open

Check these in order:

### 1. Apache status

```bash
sudo systemctl status apache2 --no-pager
```

### 2. Test locally

```bash
curl http://localhost
```

### 3. Check Security Group

**AWS Console → EC2 → Instances → select instance → Security → Security groups → Inbound rules**

Confirm:

```text
Type: HTTP
Protocol: TCP
Port: 80
```

### 4. Confirm you are using the Public IPv4 address

Do not use the private IP from your own computer.

---

## Step 13 — Clean Up

**🌐 WHERE TO GO**  
AWS Console → EC2 → Instances

If this is only a temporary practical:

1. Select the instance.
2. Click **Instance state**.
3. Choose **Stop instance** if you will use it again.
4. Choose **Terminate instance** only if you no longer need it.

---

## 🧠 Commands to Remember

```bash
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl enable --now apache2
sudo systemctl status apache2 --no-pager
curl http://localhost
```

## Easy Memory Flow

```text
EC2 Console
   ↓
Launch Ubuntu
   ↓
Allow HTTP :80
   ↓
Connect Terminal
   ↓
Install Apache
   ↓
Create index.html
   ↓
Check Apache
   ↓
Public IPv4
   ↓
Open Website
```
