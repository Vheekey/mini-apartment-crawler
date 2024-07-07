#!/bin/bash

DATA_FILE="sites/apartments.json"
TEMP_FILE="apartments_bfgen.txt"
SUBJECT="Available Apartments"
EMAIL_SCRIPT="send_email.sh"
MIN_PRICE=14001
BFGEN_CRAWLER="sites/bfgen_crawler_node.js"
RECIPIENT="vheey01@gmail.com"
EMAIL_LOG="logs/email_log.txt"
LOG_FILE="logs/log.txt"



log() {
    echo "[$(date)] $1" >> $LOG_FILE;
}