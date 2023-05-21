#!/bin/bash

APP_NAME="~/Programs/MacAudioWizard"
NOTIFIED=false

while true; do
  # Check if the application is running
  if pgrep -f "$APP_NAME" > /dev/null
  then
    NOTIFIED=false
  else
    # If the application isn't running and we haven't already sent a notification
    if ! $NOTIFIED; then
      # Display an alert dialog
      osascript -e 'tell app "System Events" to display dialog "MacAudioWizard is not running." with title "MacAudioWizard Status"'
      NOTIFIED=true
    fi
  fi
  # Sleep for 10 seconds before checking again
  sleep 10
done
