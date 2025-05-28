# Simple Raspberry Pi Camera Server

A lightweight web-based camera viewer for Raspberry Pi. This implementation uses a bash script to capture images from
the Raspberry Pi camera module and serves them via a simple HTTP server.

**Perfect for home monitoring:** If you live in a multi-room or multi-floor house/apartment and want to keep an eye on
pets, children, or elderly family members in different rooms, this project offers a simple solution. Just place a
Raspberry Pi with a camera module in any room you want to monitor, run this software, and you can check in from any
device on your home network. It's an affordable, privacy-focused alternative to commercial monitoring cameras - ideal
for watching sleeping babies, pets while you're in another room, or checking if your 3D printer has finished its job.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
    - [Starting the Camera Server](#starting-the-camera-server)
    - [Accessing the Camera Feed](#accessing-the-camera-feed)
    - [Stopping the Camera Server](#stopping-the-camera-server)
- [Configuration](#configuration)
- [Files](#files)
- [How it Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
    - [Camera Not Working](#camera-not-working)
    - [Web Server Not Starting](#web-server-not-starting)
- [Automatic Startup with Crontab](#automatic-startup-with-crontab)
    - [Stopping the Automatic Startup](#stopping-the-automatic-startup)
    - [Troubleshooting Automatic Startup](#troubleshooting-automatic-startup)
- [License](#license)

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

To stop both the camera capture and web server, press `Ctrl+C` in the terminal where you started the
`start_camera_server.sh` script.

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

## How it Works

The Raspberry Pi Camera Server uses a simple but effective architecture:

1. A camera capture script continuously takes pictures using the Raspberry Pi camera module
2. A web server makes these images available over your local network
3. A web page automatically refreshes to show the latest image

The system is designed to be lightweight and reliable, using minimal resources while providing near real-time
monitoring.

For a detailed explanation of the system architecture with diagrams, see the [ARCHITECTURE.md](ARCHITECTURE.md)
document.

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

## Automatic Startup with Crontab

You can configure the camera server to start automatically when your Raspberry Pi boots up by using crontab:

1. Open the crontab editor:
   ```bash
   crontab -e
   ```

2. Add the following line to run the camera server at boot:
   ```
   @reboot cd /path/to/RpiCamera/simple && ./start_camera_server.sh >> /home/pi/camera_startup.log 2>&1
   ```

   Replace `/path/to/RpiCamera/simple` with the actual path to the directory containing the scripts.

   Note: Even though the script will detect its own directory, explicitly changing to the directory in the crontab entry
   is recommended for clarity and as a best practice.

3. Save and exit the editor (in nano, press Ctrl+O, then Enter, then Ctrl+X)

4. Reboot your Raspberry Pi to test the automatic startup:
   ```bash
   sudo reboot
   ```

5. After the Pi reboots, you can check if the camera server is running:
   ```bash
   ps aux | grep capture.sh
   ```

   You should see the capture.sh process in the list.

6. You can also check the startup log for any errors:
   ```bash
   cat /home/pi/camera_startup.log
   ```

### Stopping the Automatic Startup

If you want to disable the automatic startup:

1. Open the crontab editor:
   ```bash
   crontab -e
   ```

2. Find and remove or comment out (by adding a # at the beginning) the line that starts with `@reboot`

3. Save and exit the editor

### Troubleshooting Automatic Startup

If the camera server doesn't start automatically:

1. Check the startup log:
   ```bash
   cat /home/pi/camera_startup.log
   ```

2. Make sure all scripts have execute permissions:
   ```bash
   chmod +x capture.sh server.sh start_camera_server.sh
   ```

3. Try running the start script manually to see if there are any errors:
   ```bash
   cd /path/to/RpiCamera/simple
   ./start_camera_server.sh
   ```

4. Check if the camera module is enabled:
   ```bash
   vcgencmd get_camera
   ```
   You should see `supported=1 detected=1`

5. If you're still having issues, you can try adding a delay before starting the server:
   ```
   @reboot sleep 30 && cd /path/to/RpiCamera/simple && ./start_camera_server.sh >> /home/pi/camera_startup.log 2>&1
   ```

## License

This project is open source and available under the [MIT License](../LICENSE).