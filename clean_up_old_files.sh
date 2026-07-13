#!/bin/bash

#############################################
# Cleanup Old Files Script
# Author: DevOps Team
# Version: 1.0
#############################################

# Directory to clean
TARGET_DIR="/backup"

# Delete files older than 7 days
RETENTION_DAYS=7

# Log file
LOG_FILE="/var/log/cleanup.log"

# Function for logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" | tee -a "$LOG_FILE"
}

log "========== Cleanup Started =========="

# Check if directory exists
if [ ! -d "$TARGET_DIR" ]; then
    log "ERROR: Directory $TARGET_DIR does not exist."
    exit 1
fi

# Display files before deletion
log "Files older than $RETENTION_DAYS days:"
find "$TARGET_DIR" -type f -mtime +$RETENTION_DAYS

# Delete old files
find "$TARGET_DIR" -type f -mtime +$RETENTION_DAYS -delete

if [ $? -eq 0 ]; then
    log "Old files deleted successfully."
else
    log "ERROR: Failed to delete old files."
    exit 1
fi

log "========== Cleanup Completed =========="

# Count total files before cleanup
TOTAL_FILES=$(find "$TARGET_DIR" -type f | wc -l)
log "Total files before cleanup: $TOTAL_FILES"

# Show available disk space
DISK_SPACE=$(df -h "$TARGET_DIR" | awk 'NR==2 {print $4}')
log "Available disk space: $DISK_SPACE"

# Count remaining files after cleanup
REMAINING_FILES=$(find "$TARGET_DIR" -type f | wc -l)
log "Remaining files after cleanup: $REMAINING_FILES"

# Print the names of deleted files before deleting
find "$TARGET_DIR" -type f -mtime +$RETENTION_DAYS -print -delete

# Synchronize file system
sync

# Script completion message
log "Cleanup completed successfully."
