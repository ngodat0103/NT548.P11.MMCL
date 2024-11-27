#!/bin/bash

# Set a default value for SECRETS_DIR if not already defined
SECRETS_DIR=${SECRETS_DIR:-/secrets/app}

# Check if the directory exists
if [[ -d "$SECRETS_DIR" ]]; then
  # Iterate over each file in the directory
  for file in "$SECRETS_DIR"/*; do
    # Ensure it's a regular file
    if [[ -f "$file" ]]; then
      # Extract the filename
      filename=$(basename "$file")

      # Read the file's content
      content=$(cat "$file")

      # Export as an environment variable
      export "$filename=$content"

      echo "Exported: $filename"
    fi
  done
else
  echo "Directory $SECRETS_DIR does not exist."
  exit 1
fi
