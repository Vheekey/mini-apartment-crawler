#!/bin/bash

DATA_FILE="sites/apartments.json"
TEMP_FILE="apartments_found.txt"

MIN_PRICE=14001

#SITES
BFGEN_CRAWLER="sites/bfgen_crawler.js"
QASA_CRAWLER="sites/qasa_crawler.js"

#MAILING_DETAILS
SUBJECT="Available Apartments"
EMAIL_SCRIPT="send_email.sh"
RECIPIENT="vheey01@gmail.com"
EMAIL_LOG="logs/email_log.txt"
LOG_FILE="logs/log.txt"



log() {
    echo "[$(date)] $1" >> $LOG_FILE;
}