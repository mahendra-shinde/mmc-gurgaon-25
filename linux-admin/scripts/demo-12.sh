#!/bin/bash
echo "Generating some text"
LOGFILE=/home/mahendra/app.log
touch $LOGFILE		# Make sure, file exists !
echo "Log started at $(date)" >> $LOGFILE
fortune -s >> $LOGFILE
echo "--------" >> $LOGFILE
