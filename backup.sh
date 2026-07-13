#!/bin/bash

#############################################
# Production Backup Script
# Author : DevOps Team
# Version: 1.0
#############################################

############ VARIABLES ######################

DATE=$(date +%Y-%m-%d_%H-%M-%S)

BACKUP_DIR="/backup"

SOURCE_DIR="/var/www/html"

DATABASE_NAME="mydb"

DB_USER="root"

DB_PASSWORD="password"

LOG_DIR="/var/log/backup"

LOG_FILE="$LOG_DIR/backup_$DATE.log"

RETENTION_DAYS=7

MIN_DISK_SPACE=1024

#############################################

mkdir -p $BACKUP_DIR
mkdir -p $LOG_DIR

#############################################

log(){

echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" | tee -a $LOG_FILE

}

#############################################

log "==============================="
log "Backup Started"
log "==============================="

#############################################
# Disk Space Check
#############################################

AVAILABLE=$(df $BACKUP_DIR | awk 'NR==2 {print $4}')

if [ "$AVAILABLE" -lt "$MIN_DISK_SPACE" ]
then
      log "ERROR : Low Disk Space"
      exit 1
fi

log "Disk Space Check Passed"

#############################################
# Directory Backup
#############################################

log "Taking Directory Backup..."

tar -czf $BACKUP_DIR/files_$DATE.tar.gz $SOURCE_DIR >> $LOG_FILE 2>&1

if [ $? -eq 0 ]
then
      log "Directory Backup Successful"
else
      log "Directory Backup Failed"
      exit 1
fi

#############################################
# Database Backup
#############################################

log "Taking MySQL Backup..."

mysqldump -u$DB_USER -p$DB_PASSWORD $DATABASE_NAME | gzip > $BACKUP_DIR/db_$DATE.sql.gz

if [ $? -eq 0 ]
then
      log "Database Backup Successful"
else
      log "Database Backup Failed"
      exit 1
fi

#############################################
# Verify Backup
#############################################

if [ -f "$BACKUP_DIR/files_$DATE.tar.gz" ] && [ -f "$BACKUP_DIR/db_$DATE.sql.gz" ]
then
      log "Backup Verification Successful"
else
      log "Backup Verification Failed"
      exit 1
fi

#############################################
# Delete Old Backups
#############################################

log "Removing Backups Older Than $RETENTION_DAYS Days"

find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete

#############################################
# Calculate Backup Size
#############################################

SIZE=$(du -sh $BACKUP_DIR | awk '{print $1}')

log "Current Backup Size : $SIZE"

#############################################
# Backup Completed
#############################################

log "Backup Completed Successfully"

exit 0
