#!/bin/bash

# Configuration variables
QUALITY=90
WIDTH=720
HEIGHT=1280
ROTATION=90  # Set to 0 to disable rotation
FINAL_PREFIX="final_"  # Prefix for final image files
CURRENT_LINK="current.jpg"    # Symlink name for the latest image

# Directory to store images
IMAGE_DIR="./images"
mkdir -p "$IMAGE_DIR"

# Define snapshot file path in the images directory
SNAPSHOT_FILE="${IMAGE_DIR}/snapshot.jpg"

# Track the previous file for deletion
PREV_FILE=""

# Clean up any leftover files from previous runs
# We only keep the most recent image, so clean up all final images at startup
find "$IMAGE_DIR" -name "${FINAL_PREFIX}*.jpg" -delete

# Start libcamera-still in signal mode
echo "Starting libcamera-still in signal mode..."
libcamera-still -t 0 -s -o "$SNAPSHOT_FILE" --width ${WIDTH} --height ${HEIGHT} --quality ${QUALITY} &
CAMERA_PID=$!

# Make sure we kill the camera process when the script exits
trap 'kill $CAMERA_PID 2>/dev/null; exit' EXIT INT TERM

# Give the camera a moment to initialize
sleep 2

echo "Camera ready. Beginning capture loop..."

while true; do
  # Generate timestamp for filename
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  FINAL_FILE="${IMAGE_DIR}/${FINAL_PREFIX}${TIMESTAMP}.jpg"

  echo "Capturing new image: $FINAL_FILE"

  # Signal libcamera-still to take a picture
  kill -USR1 $CAMERA_PID

  # Wait a moment for the capture to complete
  sleep 1

  # Check if the snapshot file exists
  if [ ! -f "$SNAPSHOT_FILE" ]; then
    echo "Error: Failed to capture image ($SNAPSHOT_FILE not found)"
    sleep 2
    continue
  fi

  # Only rotate if ROTATION is not 0
  if [ "$ROTATION" -ne 0 ]; then
    # Rotate the image
    convert "$SNAPSHOT_FILE" -rotate ${ROTATION} "$FINAL_FILE"

    # Check if rotation was successful
    if [ ! -f "$FINAL_FILE" ]; then
      echo "Error: Failed to rotate image"
      sleep 2
      continue
    fi
  else
    # No rotation needed, just copy the file
    cp "$SNAPSHOT_FILE" "$FINAL_FILE"
  fi

  # Update the symbolic link to point to the new file
  pushd "$IMAGE_DIR" > /dev/null
  ln -sf "$(basename "$FINAL_FILE")" "$CURRENT_LINK"
  popd > /dev/null

  # Delete the previous file if it exists
  if [ -n "$PREV_FILE" ] && [ -f "$PREV_FILE" ]; then
    rm -f "$PREV_FILE"
  fi

  # Remember this file for deletion next time
  PREV_FILE="$FINAL_FILE"

  echo "Updated $CURRENT_LINK -> $FINAL_FILE"

  sleep 2
done
