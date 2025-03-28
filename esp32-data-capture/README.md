# Baby Observation Project: Data Capture and Upload with ESP32-S3

## 📌 Project Overview

This project utilizes an ESP32-S3 microcontroller to:

- Capture images and record audio upon detecting significant sound events, such as a baby crying.
- Upload the recorded data securely to Firebase Cloud Storage.

## 🎯 Project Responsibilities

- Develop embedded software for ESP32-S3.
- Implement sound detection algorithms.
- Automate image capturing and audio recording processes.
- Ensure secure and efficient data uploads to cloud storage.

## 🛠️ Hardware Components

- T-SIMCAM ESP32-S3 board
- Integrated camera module
- Built-in I2S microphone

## ⚙️ Technical Implementation

### 🔊 Sound Detection

- The microphone continuously samples ambient audio.
- Sound intensity is measured using Root Mean Square (RMS) calculations:

```cpp
int soundLevel = readSoundLevel();
if (!recording && soundLevel > SOUND_THRESHOLD) {
    recording = true;
    captureAndUploadImage();
    startAudioRecording();
    silenceStart = millis();
}
```
- Recording stops automatically after about 3 seconds of silence:

```cpp
if (recording && millis() - silenceStart > SILENCE_DURATION) {
    recording = false;
    stopAudioRecordingAndUpload();
}
```

### 📸 Image Capture

- The camera immediately captures an image upon detecting a loud sound event:

```cpp
void captureAndUploadImage() {
    camera_fb_t *fb = esp_camera_fb_get();
    if (fb) {
        String path = "/pictures/picture_" + String(millis()) + ".jpg";
        Firebase.Storage.upload(&fbdo, STORAGE_BUCKET_ID, path, fb->buf, fb->len, "image/jpeg");
        esp_camera_fb_return(fb);
    }
}
```
- Captured images have a resolution of 320x240 pixels to balance quality and file size.
- Images are timestamped clearly for efficient retrieval and analysis.

### 🎙️ Audio Recording

- Audio recording starts simultaneously with image capture:

```cpp
void startAudioRecording() {
    audioFile = SPIFFS.open("/audio.wav", FILE_WRITE);
}
```
- Continues recording until a quiet environment (below threshold) persists for about 3 seconds.
- Recorded audio is saved in WAV format at a sampling rate of 16kHz.

### ☁️ Cloud Storage (Firebase)

- Files are securely uploaded to Firebase Cloud Storage:

```cpp
Firebase.Storage.upload(&fbdo, STORAGE_BUCKET_ID, path, file, content_type);
```
- Uploaded data uses clear, timestamped filenames.

## 📁 Online Storage Structure (Example)

```
baby-observation-project-storage
│
├── pictures
│   ├── picture_20250401_120000.jpg
│   └── picture_20250401_123045.jpg
│
└── sounds
    ├── sound_20250401_120000.wav
    └── sound_20250401_123045.wav
```

## 📄 Provided Files

- `audio_image_capture.cpp` – Core logic for data capture and upload.
- `camera_pins.h` – Camera hardware pin definitions.

## ✅ Project Outcomes

- An automated and dependable system for capturing critical events.
- Efficient storage usage, uploading only relevant recordings. This efficiency is achieved by uploading data exclusively upon detecting significant sound events, thus minimizing unnecessary data storage.
- Facilitates subsequent data analysis and application development by team members.

---
