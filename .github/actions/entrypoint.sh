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
    parent_path='.'
    for ((i = 0; i < ${#keys[@]} - 1; i++)); do
        parent_path+=" | .\"${keys[i]}\""
        # Ensure each parent is an object
        jq "$parent_path |= (if . == null or . == \"\" or type != \"object\" then {} else . end)" "$JSON_FILE" > temp.json && mv temp.json "$JSON_FILE"
    done

    # Add the final key-value pair
    final_key="${keys[-1]}"
    jq "$parent_path += {\"$final_key\": \"$value\"}" "$JSON_FILE" > temp.json && mv temp.json "$JSON_FILE"
    echo "Added nested key: $key with value: $value to $JSON_FILE."
}

# Main execution
initialize_json

# Check if lambda-code directory exists
if [ -d "lambda-code" ]; then
    echo "Lambda function directory found."
    add_key_value awsLambda "True"
    # Check if lambda-code was modified in the latest commit
    if git diff --name-only HEAD^ HEAD | grep '^lambda-code/'; then
        echo "Changes detected in lambda-code directory."
        add_key_value awsLambda "True"
    else
        echo "No changes detected in lambda-code directory."
        add_key_value awsLambda "False"
    fi
else
    echo "Lambda function directory not found."
    add_key_value awsLambda "False"
fi

# Check if cf-template directory exists
if [ -d "cf-template" ]; then
    echo "CloudFormation template directory found."
    add_key_value cloudFormation "True"
    # Check if lambda-code was modified in the latest commit
    if git diff --name-only HEAD^ HEAD | grep '^cf-template/'; then
        echo "Changes detected in cf-template directory."
        add_key_value awsCloudFormation "True"
    else
        echo "No changes detected in cf-template directory."
        add_key_value awsCloudFormation "False"
    fi
else
    echo "CloudFormation template directory not found."
    add_key_value awsCloudFormation "False"
fi

echo "Services used in this action: `cat services-used.json`"

