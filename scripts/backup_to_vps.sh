#!/bin/bash
# Backup script - runs from Mac to VPS

# Config
VPS_HOST="187.124.4.156"
VPS_USER="root"
SSH_KEY="~/.ssh/vps_key"
BACKUP_DIR="/root/backup"

# What to backup
SOURCE_DIRS=(
    "~/Documents/xcode/spese app"
    "~/Documents/openclaw"
)

# Create backup dir on VPS
ssh -i $SSH_KEY $VPS_USER@$VPS_HOST "mkdir -p $BACKUP_DIR"

# Backup each directory
for dir in "${SOURCE_DIRS[@]}"; do
    dirname=$(basename "$dir")
    echo "Backing up $dirname..."
    rsync -avz -e "ssh -i $SSH_KEY" "$dir" $VPS_USER@$VPS_HOST:$BACKUP_DIR/
done

echo "Backup completato!"
