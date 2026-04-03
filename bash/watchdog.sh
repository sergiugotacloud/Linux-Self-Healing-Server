#!/bin/bash

LOGFILE="/home/ec2-user/watchdog.log"

echo "---- $(date) ----" >> $LOGFILE

if ! docker ps | grep -q nginx-container
then
  echo "Container down → recreating" >> $LOGFILE
  
  docker rm nginx-container 2>/dev/null
  
  docker run -d -p 80:80 --name nginx-container nginx
fi
