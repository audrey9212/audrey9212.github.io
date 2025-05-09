# Minimalist Three.js Sky and Water Scene

A serene 3D web experience featuring a beautiful sky and water simulation, created with Three.js.

## Features

- Realistic water simulation with reflections and animations
- Dynamic sky simulation with atmospheric effects
- Simple, minimalist aesthetic

## How to Run

You can run this project in two ways:

### Using a Local Server

1. Clone or download this repository
2. Start a local server in the project directory
   - Using Python: `python -m http.server`
   - Using Node.js: Install `http-server` with `npm install -g http-server` and run `http-server`
3. Open your browser and navigate to `http://localhost:8000` (or the port shown in your terminal)

### Directly Opening the HTML File

Simply open the `index.html` file in a modern web browser that supports ES6 modules.

## Controls

- Left-click and drag to rotate the camera
- Right-click and drag to pan
- Scroll to zoom in and out

## Technical Details

This project uses:
- Three.js for 3D rendering
- OrbitControls for camera movement
- Water and Sky modules from Three.js examples