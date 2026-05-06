#!/bin/bash
# =======================================================================
# RHEL 7.9 Offline Setup Script (UUID आधारित persistent ISO mount)
# - Auto-detect ISO device
# - Mount ISO
# - Use UUID in /etc/fstab (stable mount)
# - Configure local YUM repo
# - Disable subscription-manager plugin
# - Install required CIS LAB packages
# =======================================================================

set -e

MOUNT_POINT="/mnt/rhel7iso"
REPO_FILE="/etc/yum.repos.d/rhel7-local.repo"

echo "[INFO] Starting offline setup using RHEL ISO..."

# ---------- Step 1: Detect ISO device ----------
echo "[INFO] Detecting ISO device..."

ISO_DEV=$(lsblk -o NAME,TYPE | awk '$2=="rom" {print "/dev/"$1}' | head -n1)

if [ -z "$ISO_DEV" ]; then
    echo "[ERROR] No ISO (ROM) device found. Attach ISO in Proxmox."
    lsblk
    exit 1
fi

echo "[INFO] Found ISO device: $ISO_DEV"

# ---------- Step 2: Get UUID ----------
echo "[INFO] Fetching UUID..."

UUID=$(blkid -s UUID -o value $ISO_DEV)

if [ -z "$UUID" ]; then
    echo "[ERROR] Could not fetch UUID for $ISO_DEV"
    exit 1
fi

echo "[INFO] ISO UUID: $UUID"

# ---------- Step 3: Create mount point ----------
mkdir -p $MOUNT_POINT

# ---------- Step 4: Mount ISO (if not already mounted) ----------
if mount | grep -q "$MOUNT_POINT"; then
    echo "[INFO] ISO already mounted at $MOUNT_POINT"
else
    echo "[INFO] Mounting ISO..."
    mount $ISO_DEV $MOUNT_POINT
fi

# ---------- Step 5: Verify ISO contents ----------
if [ ! -d "$MOUNT_POINT/Packages" ]; then
    echo "[ERROR] Invalid ISO or mount failed (Packages directory missing)"
    exit 1
fi

# ---------- Step 6: Add persistent mount using UUID ----------
echo "[INFO] Configuring persistent mount in /etc/fstab..."

FSTAB_ENTRY="UUID=$UUID  $MOUNT_POINT  iso9660  ro,loop  0 0"

if ! grep -q "$UUID" /etc/fstab; then
    echo "$FSTAB_ENTRY" >> /etc/fstab
    echo "[INFO] Added UUID-based entry to /etc/fstab"
else
    echo "[INFO] fstab entry already exists"
fi

# ---------- Step 7: Create local YUM repo ----------
echo "[INFO] Creating local YUM repository..."

cat > $REPO_FILE <<EOF
[rhel7-local]
name=RHEL 7.9 Local Repo
baseurl=file://$MOUNT_POINT
enabled=1
gpgcheck=0
EOF

# ---------- Step 8: Disable subscription-manager plugin ----------
echo "[INFO] Disabling subscription-manager plugin..."

if [ -f /etc/yum/pluginconf.d/subscription-manager.conf ]; then
    sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/subscription-manager.conf
fi

# ---------- Step 9: Clean and refresh YUM ----------
echo "[INFO] Cleaning YUM cache..."
yum clean all

echo "[INFO] Rebuilding YUM cache..."
yum makecache

echo "[INFO] Available repositories:"
yum repolist

# ---------- Step 10: Install required packages ----------
echo "[INFO] Installing required packages..."

yum install -y \
vim \
parted \
xfsprogs \
aide \
audit \
rsyslog \
sudo \
bash-completion \
net-tools

echo "[SUCCESS] Offline setup complete using UUID-based ISO mount."
