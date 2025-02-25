#!/bin/bash

# Default JSON file name
JSON_FILE="services-used.json"

# Create or initialize JSON file
initialize_json() {
    if [ ! -f "$JSON_FILE" ]; then
        echo "{}" > "$JSON_FILE"
        echo "Initialized $JSON_FILE with an empty JSON object."
    fi
}

# Add key-value pair to JSON
add_key_value() {
    local key="$1"
    local value="$2"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "Key and value cannot be empty."
        return 1
    fi

    # Update JSON using jq
    jq --arg k "$key" --arg v "$value" '. + {($k): $v}' "$JSON_FILE" > temp.json && mv temp.json "$JSON_FILE"
    echo "Added key: $key with value: $value to $JSON_FILE."
}

# Main execution
initialize_json

if [ ! -z "$1" ] && [ ! -z "$2" ]; then
    add_key_value "$1" "$2"
else
    echo "Usage: $0 [key] [value] or $0 --interactive"
fi

pwd

ls -la

echo "Services used in this action: `cat services-used.json`"

