#!/bin/bash
# =======================================================================
# First Boot Script (runs once after clone)
# =======================================================================

LOGFILE="/var/log/firstboot.log"

echo "[INFO] First boot script started at $(date)" | tee -a $LOGFILE

# ---------- Regenerate SSH keys ----------
echo "[INFO] Regenerating SSH host keys..." | tee -a $LOGFILE
rm -f /etc/ssh/ssh_host_*
ssh-keygen -A

# ---------- Restart network ----------
echo "[INFO] Restarting network..." | tee -a $LOGFILE
systemctl restart NetworkManager || systemctl restart network

# ---------- Optional: Set hostname ----------
# You can customize this if needed
HOSTNAME="rhel7-$(hostname -I | awk '{print $1}' | tr '.' '-')"
echo "[INFO] Setting hostname to $HOSTNAME" | tee -a $LOGFILE
hostnamectl set-hostname $HOSTNAME

# ---------- Disable this service ----------
echo "[INFO] Disabling firstboot service..." | tee -a $LOGFILE
systemctl disable firstboot.service

echo "[INFO] First boot script completed." | tee -a $LOGFILE
