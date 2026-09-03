# 💾 Practical 9 — Create, Attach and Mount an Amazon EBS Volume

> **Goal:** Create a new EBS volume, attach it to Ubuntu EC2, identify the correct disk, create a filesystem, mount it, store a test file, and safely unmount it.

## ⚠️ Read This Before Starting

The command `mkfs` creates a filesystem and can destroy existing data if you run it on the wrong disk.

**Never copy a device name blindly.** Always identify the new disk using `lsblk` on your own EC2 instance.

---

## Step 1 — Check the EC2 Availability Zone

**🌐 WHERE TO GO**  
AWS Console → **EC2** → **Instances** → select your instance

**🧭 WHAT TO DO**  
In the instance details, find:

```text
Availability Zone
```

Example:

```text
ap-south-1a
```

Write it down.

**📝 WHY**  
The new EBS volume must normally be in the same Availability Zone as the EC2 instance you want to attach it to.

---

## Step 2 — Open the EBS Volumes Page

**🌐 WHERE TO GO**  
AWS Console → **EC2** → left menu → **Elastic Block Store** → **Volumes**

Direct EC2 entry: https://console.aws.amazon.com/ec2/

**🧭 WHAT TO DO**  
Click **Create volume**.

---

## Step 3 — Create the EBS Volume

**🌐 WHERE TO GO**  
EC2 → Elastic Block Store → Volumes → **Create volume**

**🧭 WHAT TO DO**
1. Volume type → choose the type required for your lab, commonly `gp3`.
2. Size → choose a small test size appropriate for your practical.
3. Availability Zone → select the **same AZ as your EC2 instance**.
4. Add a Name tag if you want:

```text
Ayan-Lab-EBS
```

5. Click **Create volume**.

**✅ CHECK**  
Wait until the volume state shows:

```text
Available
```

---

## Step 4 — Attach the Volume to EC2

**🌐 WHERE TO GO**  
EC2 → Elastic Block Store → **Volumes**

**🧭 WHAT TO DO**
1. Select the new EBS volume.
2. Click **Actions**.
3. Click **Attach volume**.
4. Select your EC2 instance.
5. Click **Attach volume**.

**✅ CHECK**  
The volume state should change to **In-use**.

---

## Step 5 — Connect to the Ubuntu EC2 Terminal

**🌐 WHERE TO GO**  
EC2 → Instances → select instance → **Connect** → **EC2 Instance Connect** → **Connect**

---

## Step 6 — Identify the New Disk

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
lsblk
```

For more filesystem information:

```bash
lsblk -f
```

Example only:

```text
NAME        FSTYPE FSVER LABEL UUID                                 MOUNTPOINTS
nvme0n1
└─nvme0n1p1 ext4   1.0         ...                                  /
nvme1n1
```

In this example:

```text
nvme0n1  → operating-system/root disk
nvme1n1  → newly attached empty EBS volume
```

**⚠️ IMPORTANT**  
Your new disk might have a different name. Use the disk that appeared after attaching the new EBS volume.

➡️ In the commands below, replace `/dev/nvme1n1` with your actual new device if it is different.

---

## Step 7 — Check Whether the Disk Already Contains a Filesystem

**🌐 WHERE TO GO**  
EC2 terminal

Example command:

```bash
sudo file -s /dev/nvme1n1
```

Also check:

```bash
sudo blkid /dev/nvme1n1
```

### New empty volume may show

```text
/dev/nvme1n1: data
```

### Existing formatted volume may show something like

```text
Linux rev 1.0 ext4 filesystem data
```

**🚨 STOP CONDITION**  
If the volume already contains a filesystem or important data, do **not** run `mkfs` unless you intentionally want to erase/reformat it.

---

## Step 8 — Create an ext4 Filesystem on a NEW Empty Volume

> Do this only after Step 7 confirms that the new lab volume is empty.

**🌐 WHERE TO GO**  
EC2 terminal

**💻 COMMAND**

```bash
sudo mkfs -t ext4 /dev/nvme1n1
```

**📝 WHAT IT DOES**  
Formats the selected EBS disk using the Linux `ext4` filesystem.

**✅ CHECK**

```bash
lsblk -f
```

The new disk should now show `ext4` under `FSTYPE`.

---

## Step 9 — Create a Mount Directory

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo mkdir -p /fileserver
```

**📝 WHAT IT DOES**  
Creates the folder where Linux will expose the EBS volume.

---

## Step 10 — Mount the EBS Volume

**🌐 WHERE TO GO**  
EC2 terminal

```bash
sudo mount /dev/nvme1n1 /fileserver
```

**✅ CHECK**

```bash
df -hT /fileserver
```

You should see the EBS device mounted on:

```text
/fileserver
```

Also check:

```bash
lsblk -f
```

---

## Step 11 — Give the Ubuntu User Access to the Lab Folder

For a simple lab, change ownership of the mounted directory:

```bash
sudo chown -R ubuntu:ubuntu /fileserver
```

**📝 WHAT IT DOES**  
Allows the normal `ubuntu` user to create files there without using `sudo` every time.

---

## Step 12 — Create and Verify Test Data

**🌐 WHERE TO GO**  
EC2 terminal

Create a file:

```bash
cat > /fileserver/ebs-test.txt <<'EOF'
Ayan Sayyad - EBS Practical
This file is stored on the attached Amazon EBS volume.
EOF
```

Check it:

```bash
cat /fileserver/ebs-test.txt
```

Check directory contents:

```bash
ls -lah /fileserver
```

**✅ CHECK**  
You should see `ebs-test.txt`.

---

## Step 13 — Optional: Make the Mount Persistent After Reboot

> This step is useful when you want the volume to mount automatically after EC2 restarts.

Get the UUID:

```bash
sudo blkid /dev/nvme1n1
```

Example output contains:

```text
UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Back up `/etc/fstab` first:

```bash
sudo cp /etc/fstab /etc/fstab.backup
```

Then edit:

```bash
sudo nano /etc/fstab
```

Add a line using your real UUID:

```text
UUID=YOUR-REAL-UUID  /fileserver  ext4  defaults,nofail  0  2
```

Before rebooting, test the file:

```bash
sudo mount -a
```

**✅ CHECK**  
If `sudo mount -a` returns without an error, your `fstab` entry is more likely to be valid.

---

## Step 14 — Safely Unmount the Volume

First make sure your terminal is not currently inside `/fileserver`:

```bash
cd ~
```

Then unmount:

```bash
sudo umount /fileserver
```

**✅ CHECK**

```bash
df -hT
```

`/fileserver` should no longer appear as a mounted filesystem.

Also check:

```bash
lsblk -f
```

---

## Step 15 — Detach the EBS Volume in AWS Console

**🌐 WHERE TO GO**  
AWS Console → EC2 → **Elastic Block Store → Volumes**

**🧭 WHAT TO DO**
1. Select the EBS volume.
2. Make sure it is unmounted in Linux first.
3. Click **Actions** → **Detach volume**.
4. Confirm detach.

**✅ CHECK**  
The EBS volume should return to:

```text
Available
```

---

## Step 16 — Delete the Lab Volume if You No Longer Need It

**🌐 WHERE TO GO**  
EC2 → Elastic Block Store → Volumes

**🧭 WHAT TO DO**
1. Select the detached test volume.
2. Click **Actions** → **Delete volume**.
3. Delete it only if its data is no longer required.

**💰 WHY**  
An unused EBS volume can still incur storage charges while it exists.

---

## 🧠 Easy Memory Flow

```text
Check EC2 AZ
   ↓
Create EBS in SAME AZ
   ↓
Attach to EC2
   ↓
lsblk -f
   ↓
file -s / blkid
   ↓
ONLY IF EMPTY → mkfs
   ↓
mkdir /fileserver
   ↓
mount
   ↓
Create test file
   ↓
umount
   ↓
Detach in AWS Console
```

## Commands to Remember

```bash
lsblk -f
sudo file -s /dev/YOUR-DEVICE
sudo blkid /dev/YOUR-DEVICE
sudo mkfs -t ext4 /dev/YOUR-DEVICE
sudo mkdir -p /fileserver
sudo mount /dev/YOUR-DEVICE /fileserver
df -hT /fileserver
sudo umount /fileserver
```

## 🚨 Most Important Rule

```text
lsblk first → identify disk → check filesystem → only then format
```

Never run `mkfs` on a disk containing data you want to keep.
