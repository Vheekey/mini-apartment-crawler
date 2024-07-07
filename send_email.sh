#!/bin/bash

source common.sh

subject="${1}"
file="${2}"

recipient="${RECIPIENT}"
message="$(cat ${file})"

# Log the email details
log "Sending email to $recipient with subject $subject"


# Send the email with msmtp
echo -e "Subject: $subject\n\n$message" | msmtp -a gmail "$recipient" 2>&1 | tee "${EMAIL_LOG}"


if [ $? -eq 0 ]; then
    log "Email sent successfully."
    echo "Process executed and email sent at $(date)" >> "${EMAIL_LOG}"
else
    echo "Failed to send email at $(date)" >> "${EMAIL_LOG}"
    log "Failed to send email."
fi

log "Removing temporary file..."
rm -f $file