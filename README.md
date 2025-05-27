# Raspberry Pi Camera Viewer

This repository contains implementations for running camera viewers on a Raspberry Pi with a camera module. These solutions allow you to view your Raspberry Pi camera feed through a web browser from any device on your network.

## Implementations

### Simple Implementation

A lightweight, static HTML-based camera viewer that captures images at regular intervals and serves them via a simple HTTP server. This implementation is easy to set up and has minimal dependencies.

[View Simple Implementation Documentation](simple/README.md)

## Future Plans

We're planning to develop a more advanced implementation that only activates the camera when users are viewing the page, saving power and reducing wear on the camera.

[View Future Development Plan](PLAN.md)

## Requirements

All implementations require:
- Raspberry Pi with Raspberry Pi OS
- Raspberry Pi Camera Module
- Network connection

## License

This project is open source and available under the [MIT License](LICENSE).