#!/bin/bash

# Check if at least two arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage #0 <local_file> <s3_bucket> [target_directory] [storage_class]"
    exit 1
fi

# Parse command line arguments
local_file=$1
bucket_name=$2
target_directory=$3
storage_class=$4

# Validate local file path
if [ ! -f "$local_file" ]; then
  echo "Error: The file '$local_file' does not exist."
  exit 1
fi

# Validate s3 bucket name
if ! aws s3api head-bucket --bucket "$bucket_name" >/dev/null 2>&1; then
  available_buckets=$(aws s3api list-buckets --query "Buckets[*].Name --output text)
  echo "Error: The bucket name '$bucket_name' is invalid."
  echo "Available buckets: $available_buckets"
  exit 1
fi

# Validate target directory
if [ -n "$target_directory" ]; then
  available_directories=$(aws s3api list-objects-v ---bucket "$bucket_name" --delimiter '/' --query "CommonPrefixes[*].Prefix" --output text)
  if ! echo "$available_directories" | grep -q "^${target_directory}/$"; then
    echo "Error: Target directory '$target_directory' does not exist in bucket '$bucket_name'."
    echo "Available directories: $available_directories"
    exit 1
  fi
fi

# List of valid storage classes
valid_storage_classes=("STANDARD" "REDUCED REDUNDANCY" "STANDARD_IA" "ONEZONE_IA" "GLACIER" "DEEP_ARCHIVE" "INTELLIGENT_TIERING")

#Validate storage class
if [ -n "$storage_class" ]; then
  if [[ ! " ${valid_storage_classes[@]} " =~ " ${storage_class} " ]]; then
    echo "Error: Invalid storage class '$storage_class'."
    echo "Valid storage classes are: ${valid_storage_classes[*]}"
    exit 1
  fi
fi

# Construct S3 URI
if [ -n "$target_directory" ];then
  s3_uri="s3://$bucket_name/$target_directory/$(basename "$local_file")"
else
  s3_uri="s3://$bucket_name/$(basename "$local_file")"
fi

# Upload local file to S3 bucket with AWS CLI
if [ -n "$storage_class" ]; then
  aws s3 cp "$local_file" "$s3_uri" --storage-class "$storage_class"
else
  aws s3 cp "$local_file" "$s3_uri"
fi

# Check for completion and return success or error message
if [ $? -eq 0 ]; then
  echo "File '$local_file' successfully uploaded to S3 bucket '$bucket_name/$target_directory'."
else
  echo "Error: Failed to upload the file."
fi