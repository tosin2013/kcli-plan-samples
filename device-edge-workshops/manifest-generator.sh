#!/bin/bash

# Check if input file and manifest file are provided
if [ $# -ne 1 ]; then
    echo "Usage: $0  <manifest_zip_file>"
    exit 1
fi

manifest_zip_file="$1"

# Encode the manifest file in base64
base64_content=$(base64 "$manifest_zip_file")

# Update the base64_manifest field in the input YAML file using yq
yq eval -i ".base64_manifest = \"$base64_content\"" extra_vars.yml
