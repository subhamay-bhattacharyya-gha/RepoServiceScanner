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

# Add key-value pair to JSON, including nested keys
add_key_value() {
    local key="$1"
    local value="$2"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "Key and value cannot be empty."
        return 1
    fi

    # Check for nested keys using dot notation
    IFS='.' read -ra keys <<< "$key"
    jq_script='.'
    for k in "${keys[@]}"; do
        jq_script+=" | .\"$k\""
    done

    # Update JSON using jq
    jq "$jq_script = \"$value\"" "$JSON_FILE" > temp.json && mv temp.json "$JSON_FILE"
    echo "Added nested key: $key with value: $value to $JSON_FILE."
}

# Main execution
initialize_json

add_key_value "awsLambda" "True"
add_key_value "awsLambda.filesModified" "True"

# k=awsLambda
# v="True"
# if [ ! -z "$k" ] && [ ! -z "$v" ]; then
#     add_key_value "$k" "$v"
# else
#     echo "Usage: $0 [key] [value] or $0 --interactive"
# fi

# k=awsLambda.filesModified
# v="True"
# if [ ! -z "$k" ] && [ ! -z "$v" ]; then
#     add_key_value "$k" "$v"
# else
#     echo "Usage: $0 [key] [value] or $0 --interactive"
# fi

pwd

ls -la

echo "Services used in this action: `cat services-used.json`"

