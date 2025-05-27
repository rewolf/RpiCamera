// Flag to track if an image load is in progress
let isLoading = false;
let updateTimer = null;
const statusElement = document.getElementById('status');
const canvas = document.getElementById('camera-canvas');
const ctx = canvas.getContext('2d');
const loading = document.getElementById('loading');
const timestamp = document.getElementById('timestamp');

// Draw initial blank canvas with text
function initializeCanvas() {
    ctx.fillStyle = '#f8f8f8';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = '#666';
    ctx.font = '16px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('Waiting for camera feed...', canvas.width / 2, canvas.height / 2);
}

function updateImage() {
    // If already loading an image, don't start another request
    if (isLoading) {
        statusElement.textContent = "Waiting for current image to load...";
        return;
    }

    isLoading = true;
    statusElement.textContent = "Loading new image...";

    // Create a new image object to preload
    const newImg = new Image();

    // Add timestamp to prevent caching
    const imageUrl = 'images/current.jpg?t=' + new Date().getTime();
    newImg.src = imageUrl;

    // When the image loads successfully
    newImg.onload = function() {
        // Clear the canvas
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        // Draw the new image on the canvas
        ctx.drawImage(newImg, 0, 0, canvas.width, canvas.height);

        // Hide loading message
        loading.style.display = 'none';

        // Update timestamp
        const now = new Date();
        timestamp.textContent = 'Last updated: ' + now.toLocaleTimeString();

        // Mark loading as complete
        isLoading = false;
        statusElement.textContent = "Image loaded successfully";

        // Schedule the next update
        scheduleNextUpdate();
    };

    // Handle errors
    newImg.onerror = function() {
        loading.textContent = 'Error loading image. Will retry...';
        statusElement.textContent = "Error loading image";

        // Mark loading as complete even on error
        isLoading = false;

        // Schedule the next update
        scheduleNextUpdate();

        // Note: We don't modify the canvas on error, keeping the last successful image
    };
}

function scheduleNextUpdate() {
    // Clear any existing timer
    if (updateTimer) {
        clearTimeout(updateTimer);
    }

    // Schedule the next update after 2 seconds
    updateTimer = setTimeout(updateImage, 2000);
}

// Initialize and start
initializeCanvas();
updateImage();