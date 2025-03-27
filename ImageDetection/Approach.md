## Image Detection Approach

### Approach 1: Model Training with YOLO11s-cls
#### Introduction
1) _**Source:**_  https://docs.ultralytics.com/tasks/detect/ 
<img width="600" alt="Screenshot 2568-03-26 at 20 20 17" src="https://github.com/user-attachments/assets/1f2cae21-7a54-48b3-92fb-0046dfc99485"> 
    
2) The training and testing were done on a MacBook Pro M1 w/ 16 GB of ram (2020). It used **"MPS"** instead of **"CUDA"** _(MPS - Metal Performance Shaders is the Apple’s GPU-accelerated framework for deep learning)_
    
3) This project used YOLO11s, _small_ to balance model performance and training resources.
    
4) Initially, YOLO11l _(large)_ was used. The system underwent training and testing, but its size and the amount of training resources it required significantly impacted the training time.
    
---

#### Data Acquisition

<img width="350" alt="Screenshot 2568-03-27 at 13 03 41" src="https://github.com/user-attachments/assets/6529c500-f57a-4ab3-9da6-992958ed2519" />

_**source:**_ https://www.kaggle.com/datasets/jonathanoheix/face-expression-recognition-dataset

| No. | Class_No. | Class_Name |
|-----|-----------|------------|
|  1  |     0     | Angry      |
|  2  |     1     | Disgust    |
|  3  |     2     | Fear       |
|  4  |     3     | Happy      |
|  5  |     4     | Neutral    |
|  6  |     5     | Sad        |
|  7  |     6     | Surprise   |

---

#### Settings
1) The structure of the code consists of three parts: .py and two .yaml(s) for settings.

<img width="500" alt="Screenshot 2568-03-26 at 21 07 39" src="https://github.com/user-attachments/assets/a26a0a96-5984-4ae3-ae94-f084e7ed45d3" />

<img width="500" alt="Screenshot 2568-03-26 at 21 08 14" src="https://github.com/user-attachments/assets/fc5cd35e-57fc-4111-baa6-4790cc8e8831" />

1.1) Model Settings named as "**cfg.yaml**" _(Left)_

1.2) Data set with Train, Validate, and Test named as "**dataset.yaml**" _(Right)_

---

#### Evaluation Metrics
| Aspect                    | Description                                                             | Remark               |                    |
|---------------------------|-------------------------------------------------------------------------|---------------------|---------------------| 
| `epoch`                  | Current epoch number (1–10 shown here).                                 |   N/A             |                        |
| `time`                   | Time taken in seconds per epoch.                                        |      N/A          |
| `train/box_loss`         | Bounding box regression loss — lower is better.                         |       N/A         |
| `train/cls_loss`         | Classification loss — penalizes misclassified objects.                  |        N/A        |
| `train/dfl_loss`         | Distribution Focal Loss — improves box localization (YOLOv8).           |        N/A        |
| `metrics/precision(B)`   | % of true positives out of all predicted positives (TP / (TP + FP)).     |        Considered        |
| `metrics/recall(B)`      | % of true positives out of all actual positives (TP / (TP + FN)).        |       Considered         |
| `metrics/mAP50(B)`       | Mean Average Precision at IoU 0.50 — general object detection metric.   |     Considered           |
| `metrics/mAP50-95(B)`    | mAP averaged over IoUs 0.5 to 0.95 — stricter and more reliable.        |     Considered           |
| `val/box_loss`           | Box loss on the validation set — lower means better generalization.     |         Considered       |
| `val/cls_loss`           | Validation classification loss.                                         |       Considered         |
| `val/dfl_loss`           | Validation focal loss.                                                  |        Considered        |
| `lr/pg0`, `pg1`, `pg2`   | Learning rates for different model layers (e.g., backbone, head).        |         N/A       |

There are 7 aspects of the evaluation metrics to be considered.

---

#### Results 



---
### Approach 2: Model Training with EdgeImpulse
_**Source:**_ https://studio.edgeimpulse.com/studio/654682/impulse/1/learning/keras-object-detection/3


