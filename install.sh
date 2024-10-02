#!/bin/bash

SCRIPT_NAME="s3upload.sh"
INSTALL_DIR="/usr/local/bin"

# Copy script to installation directory
if cp "bin/$SCRIPT_NAME" "$INSTALL_DIR/s3upload.sh"; then
    echo "Installation complete. You can now run 's3upload.sh' from anywhere."
else
    echo "Installation failed. You may need to use 'sudo' to install in $INSTALL_DIR."
fi

# Make the script executable
chmod +x "$INSTALL_DIR/s3upload.sh"
