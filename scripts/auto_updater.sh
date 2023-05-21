#!/bin/bash

main() {
    # Name of the app and Github repo
    local APP_NAME="MacAudioWizard"
    # The destination directory
    local DEST_DIR="$HOME/Programs"

    # Get the URL of the latest release
    local RELEASE_URL="https://github.com/cbackas/$APP_NAME/releases/latest/download/$APP_NAME"

    # Move to the destination directory
    cd $DEST_DIR

    # Kill any running instances of the app
    pkill -f $APP_NAME

    # Remove old version
    rm -f $APP_NAME

    # Download the latest release
    curl -sOL $RELEASE_URL

    # Make the downloaded file executable
    chmod +x $APP_NAME

    # Start the app
    ./$APP_NAME &
}

# Call the main function
nohup ./main > /dev/null 2>&1 &