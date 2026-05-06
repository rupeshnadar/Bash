#!/bin/bash
# =======================================================================
# CIS Disk Setup Script (Safe Lab Version)
# Add additional disk as /dev/sdb of size 1 GB to create below partitions
# Creates partitions on /dev/sdb and mounts them
# =======================================================================

set -e

DISK="/dev/sdb"

echo "[INFO] Starting CIS disk setup on $DISK"

# ---------- Create partitions ----------
parted -s $DISK mklabel gpt

# parted -s $DISK mkpart primary xfs 1MiB 5GiB    # /tmp
# parted -s $DISK mkpart primary xfs 5GiB 20GiB   # /var
# parted -s $DISK mkpart primary xfs 20GiB 25GiB  # /var/tmp
# parted -s $DISK mkpart primary xfs 25GiB 35GiB  # /var/log
# parted -s $DISK mkpart primary xfs 35GiB 45GiB  # /var/log/audit
# parted -s $DISK mkpart primary xfs 45GiB 60GiB  # /home

parted -s $DISK mkpart primary xfs 1MiB 250MiB    # /tmp
parted -s $DISK mkpart primary xfs 250MiB 500MiB  # /var/tmp
parted -s $DISK mkpart primary xfs 500MiB 750MiB  # /var/log
parted -s $DISK mkpart primary xfs 750MiB 1000MiB  # /var/log/audit

sleep 2

# ---------- Format ----------
mkfs.xfs ${DISK}1
mkfs.xfs ${DISK}2
mkfs.xfs ${DISK}3
mkfs.xfs ${DISK}4

# ---------- Create mount points ----------
mkdir -p /tmp /var/tmp /var/log /var/log/audit

# ---------- Backup fstab ----------
cp /etc/fstab /etc/fstab.bak_$(date +%s)

# ---------- Add to fstab ----------
echo "${DISK}1 /tmp xfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab
echo "${DISK}3 /var/tmp xfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab
echo "${DISK}4 /var/log xfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab
echo "${DISK}5 /var/log/audit xfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab

# ---------- Mount all ----------
mount -a

echo "[SUCCESS] CIS partitions created and mounted"
