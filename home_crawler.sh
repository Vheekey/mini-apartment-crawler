#!/bin/bash

source common.sh

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

log "Starting script"
log "Searching for apartments in Stockholm..."

# list of crawlers
SITES=(
  "${BFGEN_CRAWLER}"
  "${QASA_CRAWLER}"
)

# Iterate over each site
for site in "${SITES[@]}"; do
  # Run the Node.js crawler
  log "Crawling $site"
  node "$site"

  # Check if the data file was created
  if [[ ! -f "$DATA_FILE" ]]; then
    log "Error: Data file not found. Exiting."
    exit 1
  fi

  # Load the data
  data_bostad=$(cat "$DATA_FILE")
  count=$(echo "$data_bostad" | jq '. | length')

  log "Found $count apartments"

  if [[ $count -eq 0 ]]; then
    log "No apartments found"
    exit 1
  fi

  # Iterate over each apartment object
  echo "$data_bostad" | jq -c '.[]' | while IFS= read -r row; do
    process_apartment "$row"
  done


  if [ -s "$TEMP_FILE" ]; then
    # Send the email
    log "Sending email..."
    bash "$EMAIL_SCRIPT" "$SUBJECT" "$TEMP_FILE"
  fi

  # Clean up
  rm -f "$TEMP_FILE"
  log "Script finished"

done
