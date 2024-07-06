#!/bin/bash

source constants.sh

subject="${1}"
file="${2}"

recipient="${RECIPIENT}"
message="$(cat ${file})"

# Log the email details
echo "Sending email to $recipient with subject $subject"


# Send the email with msmtp
echo -e "Subject: $subject\n\n$message" | msmtp -a gmail "$recipient" 2>&1 | tee email_log.txt


if [ $? -eq 0 ]; then
    echo "Email sent successfully."
else
    echo "Failed to send email."
fi

echo "Removing temporary file..."
rm -f $file