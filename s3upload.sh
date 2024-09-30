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
    echo "Error: The bucket name '$bucket_name' is invalid."
    bucket_names=$(aws s3api list-buckets --query "Buckets[*].Name" --output text)
    echo "Available buckets: $bucket_names"
    exit 1
fi

# Validate target directory
if [ -n "$target_directory" ]; then
  available_directories=$(aws s3api list-objects-v2 --bucket "$bucket_name" --delimiter '/' --query "CommonPrefixes[*].Prefix" --output text)
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

# Check if file exists in s3 bucket
file_exists=$(aws s3 ls "$s3_uri" 2>&1)
file_exists_exit_code=$?

if [ $file_exists_exit_code -ne 0 ]; then
    #File does not exist, proceed
    upload_output=$(aws s3 cp "$local_file" "$s3_uri" ${storage_class:+--storage-class "$storage_class"} 2>&1)
    upload_exit_code=$?
else
    #File exists, prompt user for action
    echo "File already exists in S3 bucket."
    echo "Choose an action..."
    echo "1) Skip upload"
    echo "2) Overwrite file"
    echo "3) Rename file and upload"
    read -p "Enter your choice [1/2/3]: " choice

    case $choice in
        1)
            echo "Skipping upload."
            exit 0
            ;;
        2)
            #Overwrite file
            upload_output=$(aws s3 cp "$local_file" "$s3_uri" ${storage_class:+--storage-class "$storage_class"} 2>&1)
            upload_exit_code=$?
            ;;
        3)
            #Prompt user for new file name
            read -p "Enter new filename: " new_filename
            if [ -n "$target_directory" ]; then
                new_s3_uri="s3://$bucket_name/$target_directory/$new_silename"
            else
                new_s3_uri="s3://$bucket_name/$new_filename"
            fi
            echo "Renaming file to '$new_filename' and uploading."
            upload_output=$(aws s3 cp "$local_file" "$new_s3_uri" ${storage_class:+--storage-class "$storage_class"} 2>&1)
            upload_exit_code=$?
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
fi

# Check for completion and return success or error message
case $upload_exit_code in
    0)
        echo "File '$local_file' successfully uplaoded to S3 bucket '$bucket_name/$target_directory'."
        ;;
    *)
        echo "Error: Failed to upload the file. Exit Code: $upload_exit_code Details: $upload_output"
        exit 1
        ;;
esac
