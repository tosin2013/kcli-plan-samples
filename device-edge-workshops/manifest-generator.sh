#!/bin/bash

# Check if input file and manifest file are provided
if [ $# -ne 1 ]; then
    echo "Usage: $0  <manifest_zip_file>"
    exit 1
fi

manifest_zip_file="$1"

# Encode the manifest file in base64
base64_content=$(base64 "$manifest_zip_file")


# Remove the existing base64_manifest line from the input YAML file
sed -i '/^base64_manifest/d' extra_vars.yml

# Append the new base64_manifest line with multi-line content
echo "base64_manifest: |" | tee -a extra_vars.yml
echo "$base64_content" | sed 's/^/  /' | tee -a extra_vars.yml
