#include "esp_camera.h"
#include <driver/i2s.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "camera_pins.h"
#include "addons/TokenHelper.h"

// Wi-Fi credentials (replace with your own)
const char* ssid = "WIFI_SSID";
const char* password = "WIFI_PASSWORD";

// Firebase credentials (replace with your own)
#define API_KEY "FIREBASE_API_KEY"
#define STORAGE_BUCKET_ID "PROJECT.appspot.com"

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Sound threshold settings
#define SOUND_THRESHOLD 2000
#define SILENCE_DURATION 3000

bool recording = false;
unsigned long silenceStart = 0;

// I2S pins configuration (Adjust according to your hardware)
#define I2S_WS 18
#define I2S_SD 23
#define I2S_SCK 5

void setup() {
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println(" Wi-Fi connected!");

  config.api_key = API_KEY;
  config.token_status_callback = tokenStatusCallback;
  config.storage_bucket = STORAGE_BUCKET_ID;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  camera_config_t cam_config;
  cam_config.ledc_channel = LEDC_CHANNEL_0;
  cam_config.ledc_timer = LEDC_TIMER_0;
  cam_config.pin_d0 = Y2_GPIO_NUM;
  cam_config.pin_d1 = Y3_GPIO_NUM;
  cam_config.pin_d2 = Y4_GPIO_NUM;
  cam_config.pin_d3 = Y5_GPIO_NUM;
  cam_config.pin_d4 = Y6_GPIO_NUM;
  cam_config.pin_d5 = Y7_GPIO_NUM;
  cam_config.pin_d6 = Y8_GPIO_NUM;
  cam_config.pin_d7 = Y9_GPIO_NUM;
  cam_config.pin_xclk = XCLK_GPIO_NUM;
  cam_config.pin_pclk = PCLK_GPIO_NUM;
  cam_config.pin_vsync = VSYNC_GPIO_NUM;
  cam_config.pin_href = HREF_GPIO_NUM;
  cam_config.pin_sccb_sda = SIOD_GPIO_NUM;
  cam_config.pin_sccb_scl = SIOC_GPIO_NUM;
  cam_config.pin_pwdn = PWDN_GPIO_NUM;
  cam_config.pin_reset = RESET_GPIO_NUM;
  cam_config.xclk_freq_hz = 20000000;
  cam_config.pixel_format = PIXFORMAT_JPEG;
  cam_config.frame_size = FRAMESIZE_QVGA;
  cam_config.jpeg_quality = 10;
  cam_config.fb_count = 1;

  esp_camera_init(&cam_config);

  i2s_config_t i2s_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = 16000,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = I2S_COMM_FORMAT_I2S,
    .intr_alloc_flags = 0,
    .dma_buf_count = 4,
    .dma_buf_len = 256,
  };

  i2s_pin_config_t pin_config = {
    .bck_io_num = I2S_SCK,
    .ws_io_num = I2S_WS,
    .data_out_num = -1,
    .data_in_num = I2S_SD
  };

  i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);
}

void loop() {
  int soundLevel = readSoundLevel();

  if (!recording && soundLevel > SOUND_THRESHOLD) {
    recording = true;
    captureAndUploadImage();
    startAudioRecording();
    silenceStart = millis();
  }

  if (recording) {
    if (soundLevel > SOUND_THRESHOLD) {
      silenceStart = millis();
    } else if (millis() - silenceStart > SILENCE_DURATION) {
      recording = false;
      stopAudioRecordingAndUpload();
    }
  }

  delay(50);
}

int readSoundLevel() {
  int16_t buffer[128];
  size_t bytesRead;
  i2s_read(I2S_NUM_0, buffer, sizeof(buffer), &bytesRead, portMAX_DELAY);
  long sum = 0;
  int samples = bytesRead / 2;
  for (int i = 0; i < samples; i++) {
    sum += abs(buffer[i]);
  }
  return sum / samples;
}

void captureAndUploadImage() {
  camera_fb_t *fb = esp_camera_fb_get();
  if (fb) {
    String path = "/images/image_" + String(millis()) + ".jpg";
    Firebase.Storage.upload(&fbdo, STORAGE_BUCKET_ID, path, fb->buf, fb->len, "image/jpeg");
    esp_camera_fb_return(fb);
    Serial.println("Image uploaded.");
  }
}

File audioFile;
void startAudioRecording() {
  audioFile = SPIFFS.open("/audio.wav", FILE_WRITE);
}

void stopAudioRecordingAndUpload() {
  audioFile.close();
  File uploadFile = SPIFFS.open("/audio.wav", FILE_READ);
  if (uploadFile) {
    String path = "/audio/audio_" + String(millis()) + ".wav";
    Firebase.Storage.upload(&fbdo, STORAGE_BUCKET_ID, path, uploadFile, "audio/wav");
    uploadFile.close();
    SPIFFS.remove("/audio.wav");
    Serial.println("Audio uploaded.");
  }
}
