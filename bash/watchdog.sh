#!/bin/bash

# ==========================================
# WATCHDOG SCRIPT — SELF-HEALING MECHANISM
# ==========================================
# Purpose:
# Detect if nginx container is down and recover it
# Log all actions for debugging and audit
# ==========================================

LOGFILE="/home/ec2-user/watchdog.log"

echo "---- $(date) ----" >> $LOGFILE

# Step 1 — Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^nginx-container$"
then
  echo "Container is NOT running → starting recovery" >> $LOGFILE

  # Step 2 — Remove stale container if exists
  docker rm nginx-container 2>/dev/null
  echo "Old container removed (if existed)" >> $LOGFILE

  # Step 3 — Attempt to start container
  docker run -d -p 80:80 --name nginx-container nginx >> $LOGFILE 2>&1
  EXIT_CODE=$?

  # Step 4 — Verify if recovery succeeded (exit code + actual state)
  if [ $EXIT_CODE -eq 0 ] && docker ps --format '{{.Names}}' | grep -q "^nginx-container$"
  then
    echo "Recovery SUCCESS — container is running" >> $LOGFILE
  else
    echo "Recovery FAILED — docker run error or container not running" >> $LOGFILE
  fi
else
  echo "Container is healthy — no action needed" >> $LOGFILE
fi
