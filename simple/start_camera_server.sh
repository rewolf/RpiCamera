#!/bin/bash

# Get the directory where the script is located and change to it
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Configuration
CAMERA_LOG="camera.log"
SERVER_LOG="server.log"

echo "Starting Raspberry Pi Camera Server..."

# Check if the images directory exists, create if not
if [ ! -d "images" ]; then
    mkdir -p images
    echo "Created images directory"
fi

# Function to check if a process is already running
is_running() {
    pgrep -f "$1" > /dev/null
    return $?
}

# Kill any existing instances
if is_running "capture.sh"; then
    echo "Stopping existing camera capture process..."
    pkill -f "capture.sh"
    sleep 1
fi

# Start the camera capture script in the background
echo "Starting camera capture process..."
./capture.sh > "$CAMERA_LOG" 2>&1 &
CAMERA_PID=$!

# Check if camera process started successfully
sleep 2
if ! ps -p $CAMERA_PID > /dev/null; then
    echo "Error: Failed to start camera capture process. Check $CAMERA_LOG for details."
    exit 1
fi

echo "Camera capture process started (PID: $CAMERA_PID)"
echo "Camera logs are being written to $CAMERA_LOG"

# Start the web server
echo "Starting web server..."
./server.sh > "$SERVER_LOG" 2>&1 &
SERVER_PID=$!

# Check if server process started successfully
sleep 2
if ! ps -p $SERVER_PID > /dev/null; then
    echo "Error: Failed to start web server. Check $SERVER_LOG for details."
    pkill -P $CAMERA_PID
    exit 1
fi

echo "Web server started (PID: $SERVER_PID)"
echo "Server logs are being written to $SERVER_LOG"

# Get the IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo ""
echo "Camera server is now running!"
echo "Access the camera at: http://$IP_ADDRESS:8080"
echo ""
echo "To stop the server, press Ctrl+C"

# Set up trap to catch Ctrl+C and kill processes
trap 'echo "Stopping camera server..."; pkill -P $CAMERA_PID; kill $CAMERA_PID; kill $SERVER_PID; echo "Camera server stopped."; exit 0' INT TERM

# Keep the script running to allow for Ctrl+C to work
while true; do
    sleep 1
done
