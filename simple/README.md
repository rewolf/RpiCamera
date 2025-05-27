# Simple Raspberry Pi Camera Server

A lightweight web-based camera viewer for Raspberry Pi. This implementation uses a bash script to capture images from the Raspberry Pi camera module and serves them via a simple HTTP server.

## Prerequisites

- Raspberry Pi (any model) with Raspberry Pi OS installed
- Raspberry Pi Camera Module connected and enabled
- Python 3 installed (comes pre-installed with Raspberry Pi OS)
- ImageMagick for image rotation (`convert` command)

## Installation

1. Clone this repository or download the files to your Raspberry Pi

2. Install required dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install -y imagemagick
   ```

3. Make the scripts executable:
   ```bash
   chmod +x capture.sh server.sh start_camera_server.sh
   ```

## Usage

### Starting the Camera Server

The easiest way to start everything is to use the provided startup script:

```bash
./start_camera_server.sh
```

This will:
- Start the camera capture process
- Start the web server
- Display the URL where you can view the camera feed

### Accessing the Camera Feed

Once the server is running, you can access the camera feed by opening a web browser and navigating to:

```
http://[YOUR_PI_IP_ADDRESS]:8080
```

The page will automatically refresh with a new image every few seconds.

### Stopping the Camera Server

To stop both the camera capture and web server, press `Ctrl+C` in the terminal where you started the `start_camera_server.sh` script.

## Configuration

You can modify the following settings in the `capture.sh` file:

- `QUALITY`: JPEG image quality (1-100, higher is better quality but larger file size)
- `WIDTH`: Image width in pixels
- `HEIGHT`: Image height in pixels
- `ROTATION`: Image rotation in degrees (set to 0 to disable rotation)

## Files

- `capture.sh`: Script that captures images from the camera
- `server.sh`: Script that starts a simple HTTP server
- `start_camera_server.sh`: Script that starts both the camera capture and web server
- `index.html`: Web page that displays the camera feed
- `web_assets/styles.css`: Stylesheet for the web page
- `web_assets/camera.js`: JavaScript code for updating the camera feed
## Troubleshooting

### Camera Not Working

1. Make sure the camera is properly connected
2. Ensure the camera is enabled in `raspi-config`:
   ```bash
   sudo raspi-config
   ```
   Navigate to "Interface Options" > "Camera" and enable it

3. Check the camera logs:
   ```bash
   cat camera.log
   ```

### Web Server Not Starting

1. Make sure port 8080 is not already in use
2. Check the server logs:
   ```bash
   cat server.log
   ```

## License

This project is open source and available under the [MIT License](../LICENSE).