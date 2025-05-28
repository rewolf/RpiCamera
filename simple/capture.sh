#!/bin/bash

# Configuration variables
QUALITY=90
WIDTH=720
HEIGHT=1280
ROTATION=90  # Set to 0 to disable rotation
TEMP_PREFIX="temp_"  # Prefix for temporary files

# Directory to store images
IMAGE_DIR="./images"
mkdir -p "$IMAGE_DIR"

# Track the previous file for deletion
PREV_FILE=""

# Clean up any leftover temp files from previous runs
find "$IMAGE_DIR" -name "${TEMP_PREFIX}*.jpg" -delete

# Start libcamera-still in signal mode
echo "Starting libcamera-still in signal mode..."
libcamera-still -t 0 -s -o signal.jpg --width ${WIDTH} --height ${HEIGHT} --quality ${QUALITY} &
CAMERA_PID=$!

# Make sure we kill the camera process when the script exits
trap "kill $CAMERA_PID 2>/dev/null; exit" EXIT INT TERM

# Give the camera a moment to initialize
sleep 2

echo "Camera ready. Beginning capture loop..."

while true; do
  # Generate timestamp for filename
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  TEMP_FILE="${IMAGE_DIR}/${TEMP_PREFIX}${TIMESTAMP}.jpg"
  FINAL_FILE="${IMAGE_DIR}/camera_${TIMESTAMP}.jpg"

  echo "Capturing new image: $FINAL_FILE"

  # Signal libcamera-still to take a picture
  kill -USR1 $CAMERA_PID

  # Wait a moment for the capture to complete
  sleep 1

  # Check if the signal.jpg file exists and copy it
  if [ -f "signal.jpg" ]; then
    cp "signal.jpg" "$TEMP_FILE"
  else
    echo "Error: Failed to capture image (signal.jpg not found)"
    sleep 2
    continue
  fi

  # Only rotate if ROTATION is not 0
  if [ "$ROTATION" -ne 0 ]; then
    # Rotate the image
    convert "$TEMP_FILE" -rotate ${ROTATION} "$FINAL_FILE"

    # Check if rotation was successful
    if [ ! -f "$FINAL_FILE" ]; then
      echo "Error: Failed to rotate image"
      rm -f "$TEMP_FILE"
      sleep 2
      continue
    fi
  else
    # No rotation needed, just move the file
    mv "$TEMP_FILE" "$FINAL_FILE"
  fi

  # Update the symbolic link to point to the new file
  pushd "$IMAGE_DIR" > /dev/null
  ln -sf "$(basename "$FINAL_FILE")" "current.jpg"
  popd > /dev/null

  # Clean up temporary files
  rm -f "$TEMP_FILE"

  # Delete the previous file if it exists
  if [ -n "$PREV_FILE" ] && [ -f "$PREV_FILE" ]; then
    rm -f "$PREV_FILE"
  fi

  # Remember this file for deletion next time
  PREV_FILE="$FINAL_FILE"

  echo "Updated current.jpg -> $FINAL_FILE"

  sleep 2
done
