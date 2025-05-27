# Raspberry Pi Camera Server Architecture

This document explains the technical architecture and operation of the Simple Raspberry Pi Camera Server.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                 │
│                                         Raspberry Pi                                            │
│                                                                                                 │
│  ┌────────────────┐          ┌─────────────────────┐          ┌─────────────────────────┐      │
│  │                │          │                     │          │                         │      │
│  │  Camera Module ├─────────►│  capture.sh         │          │  server.sh              │      │
│  │                │          │  (libcamera-still)  │          │  (Python HTTP Server)   │      │
│  └────────────────┘          │                     │          │  Port 8080              │      │
│                              └──────────┬──────────┘          └─────────────┬───────────┘      │
│                                         │                                   │                   │
│                                         │                                   │                   │
│                                         ▼                                   │                   │
│                              ┌──────────────────────┐                       │                   │
│                              │                      │                       │                   │
│                              │  images/             │                       │                   │
│                              │  camera_TIMESTAMP.jpg│                       │                   │
│                              │                      │                       │                   │
│                              └──────────┬───────────┘                       │                   │
│                                         │                                   │                   │
│                                         │ symlink                           │                   │
│                                         ▼                                   │                   │
│                              ┌──────────────────────┐                       │                   │
│                              │                      │                       │                   │
│                              │  images/current.jpg  │◄──────────────────────┘                   │
│                              │  (symlink)           │  serves files                             │
│                              │                      │                                           │
│                              └──────────┬───────────┘                                           │
│                                         │                                                       │
└─────────────────────────────────────────┼───────────────────────────────────────────────────────┘
                                                   │
                                                   │ HTTP request/response
                                                   │
                                                   ▼
                                       ┌──────────────────────────────────────────┐
                                       │                                          │
                                       │  Web Browser (on any network device)     │
                                       │                                          │
                                       │  ┌────────────────────────────────────┐  │
                                       │  │                                    │  │
                                       │  │  index.html + camera.js            │  │
                                       │  │  • Requests image every 2 seconds  │  │
                                       │  │  • Renders to canvas               │  │
                                       │  │  • Updates timestamp               │  │
                                       │  │                                    │  │
                                       │  └────────────────────────────────────┘  │
                                       │                                          │
                                       └──────────────────────────────────────────┘
```

## Client Side (Web Browser)

1. **Image Requests**: The JavaScript code in `camera.js` repeatedly requests the latest image from the server
   - Uses a timestamp query parameter (`?t=1234567890`) to prevent browser caching
   - Requests are made every 2 seconds

2. **Canvas Rendering**: When a new image is received, it:
   - Loads the image into memory
   - Draws it onto an HTML canvas element
   - Updates the timestamp display
   - Schedules the next image request

3. **Error Handling**: If an image fails to load, the previous image is retained on screen and another request is scheduled

## Server Side (Raspberry Pi)

1. **HTTP Server**: A simple Python HTTP server (started by `server.sh`) runs on port 8080
   - Serves all files in the project directory
   - Provides access to the web interface and images

2. **Camera Capture Process**:
   - `libcamera-still` runs in signal mode, waiting for commands
   - When signaled (via `kill -USR1`), it captures a new image
   - The image is optionally rotated based on configuration
   - A symbolic link (`current.jpg`) is updated to point to the newest image
   - Old images are automatically deleted to save space

3. **Startup Script**: The `start_camera_server.sh` script:
   - Starts both the camera capture process and HTTP server
   - Redirects output to log files
   - Sets up proper shutdown handling

## Data Flow

1. User loads the web page in a browser
2. JavaScript initiates a request for the current image
3. The HTTP server on the Raspberry Pi serves the image file
4. JavaScript renders the image and schedules the next request
5. Meanwhile, the capture script periodically:
   - Signals the camera to take a new picture
   - Processes the image (rotation if needed)
   - Updates the symbolic link to point to the new image
   - Deletes the previous image to save space

This design is simple but effective, with minimal dependencies and resource usage. The system maintains only one image file at a time (plus the currently displayed image), keeping storage requirements minimal while providing near real-time monitoring.
