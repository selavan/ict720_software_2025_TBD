# ESP32 Data Capture (Baby Observation Project)

This code captures images and records audio using the **T-SIMCAM ESP32-S3** board when audio events (such as a baby crying) are detected, then uploads the captured files to **Firebase Cloud Storage**.

---

## 📋 Requirements

- ESP32 Arduino Core
- Firebase ESP32 Client library
- Wi-Fi credentials
- Firebase project setup (Cloud Storage bucket)

---

## ⚙️ Setup Instructions

1. **Hardware Connections**
   - Ensure your T-SIMCAM ESP32-S3 camera and microphone connections match the pins defined in `camera_pins.h`.

2. **Firebase Configuration**
   - Replace placeholders (`YOUR_WIFI_SSID`, `YOUR_WIFI_PASSWORD`, `YOUR_FIREBASE_API_KEY`, `YOUR_PROJECT.appspot.com`) in `audio_image_capture.cpp` with your credentials.

3. **Library Installation**
   - ESP32 Camera
   - Firebase ESP Client (Mobizt)
   - SPIFFS filesystem

4. **Arduino IDE Settings**
   - Board: ESP32-S3 Dev Module
   - Flash Mode: QIO
   - Partition Scheme: Huge APP (recommended)

---

## 🚀 Usage

Upload `audio_image_capture.cpp` to your ESP32-S3. The device will automatically detect sound events, capture images, record audio, and upload the files to Firebase.

---
