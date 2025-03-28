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
- The microphone continuously monitors surrounding sounds.
- It calculates sound intensity levels using RMS (Root Mean Square):

```cpp
int soundLevel = readSoundLevel();
if (!recording && soundLevel > SOUND_THRESHOLD) {
    recording = true;
    captureAndUploadImage();
    startAudioRecording();
    silenceStart = millis();
}
```

- Recording stops after about 3 seconds of silence:

```cpp
if (recording && millis() - silenceStart > SILENCE_DURATION) {
    recording = false;
    stopAudioRecordingAndUpload();
}
```

### 📸 Image Capture
- A picture is taken immediately when loud sound is detected:

```cpp
void captureAndUploadImage() {
    camera_fb_t *fb = esp_camera_fb_get();
    if (fb) {
        String path = "/images/image_" + String(millis()) + ".jpg";
        Firebase.Storage.upload(&fbdo, STORAGE_BUCKET_ID, path, fb->buf, fb->len, "image/jpeg");
        esp_camera_fb_return(fb);
    }
}
```

- Pictures are small (320x240 pixels) to save storage.
- Each image is timestamped for easy retrieval.


### 🎙️ Audio Recording
- Sound recording begins immediately upon event detection:

```cpp
void startAudioRecording() {
    audioFile = SPIFFS.open("/audio.wav", FILE_WRITE);
}
```

- It continues recording until the environment remains quiet for around 3 seconds.
- High-quality audio is saved as WAV format.
  
### ☁️ Cloud Integration (Firebase)
- Recorded data is safely uploaded to Firebase Cloud Storage:

```cpp
Firebase.Storage.upload(&fbdo, STORAGE_BUCKET_ID, path, file, content_type);
```

- Data files are clearly named using timestamps.

## 📁 Cloud Storage File Structure (Example)
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

## 📄 Code Files Provided
- `audio_image_capture.cpp` – Main embedded logic (capture and upload).
- `camera_pins.h` – Hardware pin definitions for camera integration.

## ✅ Outcome
- Automated, efficient, and reliable data capturing system.
- Reduced unnecessary uploads, effectively managing cloud storage space. This is because the system only records and uploads data when a significant noise event happens, avoiding unnecessary recordings when it's quiet, thus saving storage space.
- Facilitates seamless integration with AI classification and mobile front-end by other team members.
