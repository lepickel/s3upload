# AWS S3 File Upload Script

This is a simple Bash script that uploads a local file to an AWS S3 bucket. It allows specifying the target directory within the S3 bucket and the desired storage class for the file.

## Features

- Verifies if the provided local file and S3 bucket exist before proceeding.
- Optionally allows uploading to a specific target directory in the S3 bucket.
- Validates AWS S3 storage classes.
- Checks if the file already exists in the S3 bucket and provides options to:
  - Skip the upload.
  - Overwrite the existing file.
  - Rename the file before uploading.
  
## Prerequisites

- AWS CLI installed and configured on your system with appropriate credentials.
- Access to the desired S3 bucket.

## Usage

```bash
./s3upload.sh <local_file> <s3_bucket> [target_directory] [storage_class]
```

- local_file: Path to the local file you want to upload.
- s3_bucket: The name of the target S3 bucket.
- target_directory (optional): The directory inside the S3 bucket where the file should be uploaded.
- storage_class (optional): The S3 storage class. Valid options include:
  - STANDARD
  - REDUCED REDUNDANCY
  - STANDARD_IA
  - ONEZONE_IA
  - GLACIER
  - DEEP_ARCHIVE
  - INTELLIGENT_TIERING

EXAMPLE:
```bash
./s3upload.sh myfile.txt mybucket some/directory STANDARD_IA
```
This command uploads myfile.txt to the some/directory inside mybucket using the STANDARD_IA storage class.

## Handling Duplicate Files
If the file already exists in the S3 bucket, the script will provide three options:

- Skip upload: The script will exit without uploading the file.
- Overwrite file: The existing file in the S3 bucket will be overwritten.
- Rename file and upload: You'll be prompted to enter a new name for the file before uploading.

## Error Handling
The script checks if the local file exists before uploading.
It validates if the S3 bucket and the target directory (if specified) exist.
If an invalid storage class is provided, the script will terminate with an error message.

## Installation
To install the script and make it available globally, you can use the provided `install.sh` script:

1. Clone the repository or download the scripts.
2. Navigate to the directory where the `install.sh` file is located. --Should be 's3upload'.
```bash
cd path/to/repo
```
3. Run the installation script after making it executable.
```bash
chmod +x install.sh
./install.sh
```

This will copy the s3upload.sh to /usr/local/bin and make it executable.

Note: You may need to use sudo to run the installation script depending on your privileges.

## Troubleshooting

If you encounter issues:
- Ensure AWS CLI is installed and properly configured with approriate credentials, region, output by running
```bash
aws configure list
```
- Ensure S3 bucket is public and the bucket policy allows s3:PutObject action.

## Future Enhancements
In the future, my plan is to enhance this tool with the following features:

### Multiple File Uploads
Enjoy the convenience of uploading multiple files in a single command, streamlining the process.

### Progress Tracking
A progress tracking feature allowing users to monitor the status of their file uploads.

### Shareable Links
After uploading, generate and display shareable links, making it simple to share files with others.

### File Encryption
For added security, an encryption feature will be implemented to safeguard your files during the upload process.

## Contributing
Feel free to contribute by opening an issue or submitting a pull request. Feedback and suggestions are welcome!

## License
This project is licensed under the MIT License.
