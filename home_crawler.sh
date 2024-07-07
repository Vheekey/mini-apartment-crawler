#!/bin/bash

source common.sh

log "Starting script"
log "Searching for apartments in Stockholm..."

# Run the Node.js crawler
log "Crawling bostad.stockholm.se"
node "${BFGEN_CRAWLER}"

# Check if the data file was created
if [[ ! -f "$DATA_FILE" ]]; then
  log "Error: Data file not found. Exiting."
  exit 1
fi

# Load the data
data_bostad=$(cat "$DATA_FILE")
count=$(echo "$data_bostad" | jq '. | length')

log "Found $count apartments"
echo "Found these apartments :" > "$TEMP_FILE"
echo "================================================================" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

if [[ $count -eq 0 ]]; then
  log "No apartments found"
  exit 1
fi

# Function to process each apartment
process_apartment() {
  local row="$1"
  local area=$(echo "$row" | jq -r '.area')
  local address=$(echo "$row" | jq -r '.address')
  local link=$(echo "$row" | jq -r '.link')
  local price=$(echo "$row" | jq -r '.priceInt')


  # Check if price is less than the minimum price
  if [[ -n "$price" && "$price" =~ ^[0-9]+$ ]]; then
    if [[ "$price" -lt "$MIN_PRICE" ]]; then
        echo "Apartment Found:" >> "$TEMP_FILE"
        echo "Area: $area" >> "$TEMP_FILE"
        echo "Address: $address" >> "$TEMP_FILE"
        echo "Link: $link" >> "$TEMP_FILE"
        echo "Price: $price" >> "$TEMP_FILE"
        echo "---------------------" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
    fi
  else
    log "Invalid or missing price for $address ($area)"
  fi
}

# Iterate over each apartment object
echo "$data_bostad" | jq -c '.[]' | while IFS= read -r row; do
  process_apartment "$row"
done

# Send the email
log "Sending email..."
bash "$EMAIL_SCRIPT" "$SUBJECT" "$TEMP_FILE"

# Clean up
rm -f "$TEMP_FILE"
log "Script finished"