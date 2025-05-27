#!/bin/bash

# Configuration
PORT=8080
HOST=0.0.0.0  # Listen on all interfaces

# Check if python3 is available
if command -v python3 &> /dev/null; then
    echo "Starting HTTP server on $HOST:$PORT..."
    echo "Access the camera at http://$(hostname -I | awk '{print $1}'):$PORT"

    # Start a simple HTTP server using Python
    python3 -m http.server $PORT --bind $HOST
elif command -v python &> /dev/null; then
    # Fallback to python2 if python3 is not available
    echo "Starting HTTP server on $HOST:$PORT (using Python 2)..."
    echo "Access the camera at http://$(hostname -I | awk '{print $1}'):$PORT"

    # Python 2 syntax is slightly different
    python -m SimpleHTTPServer $PORT
else
    echo "Error: Python is not installed. Please install Python to run the HTTP server."
    exit 1
fi
