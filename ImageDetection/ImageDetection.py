# ImageDetectionCode for model training

---

# Import necessary libraries
import os
import yaml
import torch
import shutil
import numpy as np
import cv2
import pandas as pd
from pathlib import Path
from ultralytics import YOLO
from concurrent.futures import ThreadPoolExecutor
from sklearn.metrics import precision_score, recall_score, f1_score

# Load configuration from YAML file
CONFIG_PATH = "cfg.yaml"
with open(CONFIG_PATH, "r") as file:
    config = yaml.safe_load(file)

# There are 2 .yaml files in this study: cfg.yaml, for model structure settings, and dataset.yaml, for model path directories. (Explained in "Approach.md")

# Define directories from YAML
BASE_MODEL = Path(config["directories"]["base"])
TRAIN_DIR = Path(config["directories"]["train"])
VAL_DIR = Path(config["directories"]["val"])
TEST_DIR = Path(config["directories"]["test"])
MODEL_DIR = Path(config["directories"]["model"])
RESULTS_DIR = Path(config["directories"]["results"])

LABEL_DIRS = {
    "train": TRAIN_DIR / "labels",
    "val": VAL_DIR / "labels",
    "test": TEST_DIR / "labels"
}

# Create label directories if they don’t exist
for label_dir in LABEL_DIRS.values():
    label_dir.mkdir(parents=True, exist_ok=True)

---
# Model Training

# Load Training Configuration
EPOCHS = config["training"]["epochs"]
BATCH_SIZE = config["training"]["batch_size"]
IMG_SIZE = config["training"]["img_size"]
LEARNING_RATE = config["training"]["learning_rate"]
MOMENTUM = config["training"]["momentum"]
WEIGHT_DECAY = config["training"]["weight_decay"]
OPTIMIZER = config["training"]["optimizer"]
PATIENCE = config["training"]["patience"]
SAVE_BEST = config["training"]["save_best"]

# Load Augmentation Config
#AUGMENTATION = config["augmentation"]

# Bounding Box settings (safe fallback)
BBOX = config.get("bbox", {"iou_t": 0.7, "cls": 0.5})

device = "mps"

if device == "mps":
    os.environ["PYTORCH_MPS_HIGH_WATERMARK_RATIO"] = "0.0"  # Remove MPS memory cap

# Ensure each image has a corresponding label file
def check_label_files(image_dir, label_dir):
    """Ensure each image file has a corresponding label file (executed in parallel)."""
    image_dir, label_dir = Path(image_dir), Path(label_dir)
    label_dir.mkdir(parents=True, exist_ok=True)

    with ThreadPoolExecutor(max_workers=2) as executor:  # Lower workers for efficiency
        for img_path in image_dir.glob("*.jpg"):
            label_file = label_dir / (img_path.stem + ".txt")
            if not label_file.exists():
                executor.submit(label_file.touch)  # Creates missing label files asynchronously

# Verify label files in parallel for train, val, test
check_label_files(TRAIN_DIR, LABEL_DIRS["train"])
check_label_files(VAL_DIR, LABEL_DIRS["val"])
check_label_files(TEST_DIR, LABEL_DIRS["test"])

model = YOLO(BASE_MODEL)

train_results = model.train(
    data="dataset.yaml",  # Ensure dataset.yaml is in the same directory
    epochs=EPOCHS,
    batch=BATCH_SIZE,
    imgsz=IMG_SIZE,
    lr0=LEARNING_RATE,
    momentum=MOMENTUM,
    weight_decay=WEIGHT_DECAY,
    optimizer=OPTIMIZER,
    patience=PATIENCE,
    device=device,
    cache=False,  # Prevents caching entire dataset in RAM
    #hsv_h=AUGMENTATION["hsv_h"],
    #hsv_s=AUGMENTATION["hsv_s"],
    #hsv_v=AUGMENTATION["hsv_v"],
    #flipud=AUGMENTATION["flipud"],
    #fliplr=AUGMENTATION["fliplr"],
    #scale=AUGMENTATION["scale"],
    iou=BBOX["iou_t"],
    cls=BBOX["cls"],
    verbose=True,
    workers=2,  # Lower worker count for efficient RAM usage
    amp=True,  # Enable Automatic Mixed Precision (reduces memory usage)
    single_cls=False,  # Prevents merging all classes into one (preserves accuracy)
)
