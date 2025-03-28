# Baby Observation Project: Data Capture and Upload with ESP32-S3

## 📌 Project Overview
This project focuses on developing an automated system using the **T-SIMCAM ESP32-S3** microcontroller board to:
- Capture images and record audio upon detecting sound events (e.g., baby crying).
- Upload captured data to Firebase Cloud Storage for further analysis.

## 🎯 My Responsibility
- Writing embedded software for ESP32-S3.
- Implementing logic to detect noise thresholds.
- Capturing images and recording audio events efficiently.
- Uploading data securely to Firebase cloud storage.

## 🛠️ Hardware Components
- T-SIMCAM ESP32-S3 board
- Built-in camera module
- Integrated I2S microphone

## ⚙️ Implementation Details

### 🔊 Sound Detection
- The system continuously monitors ambient sound through the I2S microphone.
- Real-time audio samples are captured at a sampling rate of 16kHz.
- Calculates the root mean square (RMS) value of sound samples to accurately determine sound intensity.
- When the sound intensity exceeds a predefined RMS threshold, it triggers data capture.
- Continues monitoring during recording, only stopping after detecting a continuous silence period (approximately 3 seconds below threshold).

### 📸 Image Capture
- Upon detecting a significant sound event, the ESP32 camera immediately captures an image.
- Captures images in JPEG format with a resolution of QVGA (320x240 pixels) to balance quality and file size.
- Ensures images are timestamped uniquely for clear identification in Firebase.

### 🎙️ Audio Recording
- Begins recording audio simultaneously with image capture upon initial sound event detection.
- Stores recorded audio in WAV format with 16-bit depth at a 16kHz sampling rate.
- Continues recording until consistent silence is detected for a predefined duration (approximately 3 seconds), ensuring all relevant audio data is captured without excess.

### ☁️ Cloud Integration (Firebase)
- Securely uploads captured images and audio files to Firebase Cloud Storage.
- Uses structured naming conventions based on timestamps for easy retrieval and processing.

## 📁 Cloud Storage File Structure
```
xxxxx.appspot.com
│
├── images
│   └── image_TIMESTAMP.jpg
│
└── audio
    └── audio_TIMESTAMP.wav
```

## 📄 Code Files Provided
- `audio_image_capture.cpp` – Main embedded logic (capture and upload).
- `camera_pins.h` – Hardware pin definitions for camera integration.

## ✅ Outcome
- Automated, efficient, and reliable data capturing system.
- Reduced unnecessary uploads, effectively managing cloud storage space.
- Facilitates seamless integration with AI classification and mobile front-end by other team members.
