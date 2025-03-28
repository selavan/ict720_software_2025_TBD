## Image Detection Approach

### 2 Approaches in this project:
    1) Training with YOLO11n

    2) Training with EdgeImpulse

### Approach 1: Model Training with YOLO11n

---

#### Introduction
1) _**Source:**_  https://docs.ultralytics.com/tasks/detect/

<img width="600" alt="Screenshot 2568-03-28 at 12 42 29" src="https://github.com/user-attachments/assets/53286ff9-e104-4d52-881d-c9d06640214d" />

3) The training and testing were done on a MacBook Pro M1 w/ 16 GB of ram (2020). It used **"MPS"** instead of **"CUDA"** _(MPS - Metal Performance Shaders is the Apple’s GPU-accelerated framework for deep learning)_
    
4) This project used YOLO11n, _nano_ to balance model performance and training resources.
    
5) Initially, YOLO11l _(large)_ was used. The system underwent training and testing, but its size and the amount of training resources it required significantly impacted the training time.
    
---

#### Data Acquisition 1

<img width="350" alt="Screenshot 2568-03-27 at 13 03 41" src="https://github.com/user-attachments/assets/6529c500-f57a-4ab3-9da6-992958ed2519" />

1) _**source:**_ https://www.kaggle.com/datasets/jonathanoheix/face-expression-recognition-dataset


| No. | Class_No. | Class_Name |
|-----|-----------|------------|
|  1  |     0     | Angry      |
|  2  |     1     | Disgust    |
|  3  |     2     | Fear       |
|  4  |     3     | Happy      |
|  5  |     4     | Neutral    |
|  6  |     5     | Sad        |
|  7  |     6     | Surprise   |

2) ⬆️ 7 classses of the data
   
---

#### Settings
1) The structure of the code consists of three parts: .py and two .yaml(s) for settings.

<img width="500" alt="Screenshot 2568-03-26 at 21 07 39" src="https://github.com/user-attachments/assets/a26a0a96-5984-4ae3-ae94-f084e7ed45d3" />

<img width="500" alt="Screenshot 2568-03-26 at 21 08 14" src="https://github.com/user-attachments/assets/fc5cd35e-57fc-4111-baa6-4790cc8e8831" />

1.1) Model Settings named as "**cfg.yaml**" _(Left)_

1.2) Data set with Train, Validate, and Test named as "**dataset.yaml**" _(Right)_

---

#### Evaluation Metrics
| Aspect                    | Description                                                             | Remark               |                    
|---------------------------|-------------------------------------------------------------------------|---------------------|
| `epoch`                  | Current epoch number (1–10 shown here).                                 |   N/A             |                        
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

⬆️ 7 aspects of the evaluation metrics and selected group to be considered. 

3 main groups:

1) **Precision** and **Recall**
   
    1) **Precision**: Higher means fewer false alarms
    2) **Recall**: Higher means few misses
            
2) Mean Average Precision: **mAP50** and **mAP50-95**
    1) **mAP50**: Correct if overlap, more forgiving     
    2) **mAP50-95**: Thresholds between 50% to 95%, more strict and realistic
       
3) Loss: **box**, **classification**, and **validation**
    1) **box**: lower means better in localization
    2) **classification**: lower means better in class prediction
    3) **validation**: check how well your model generalizes

---

#### Results 

In this project, results are determined by 2 main metrics:

1) **Evaluation metrics**
   
    1.1) Results
    ![results](https://github.com/user-attachments/assets/59c9c054-9bf4-4712-9668-7e3f806c8ca8)

    
3) **Testing Results**

<img width="350" alt="Screenshot 2568-03-28 at 17 47 56" src="https://github.com/user-attachments/assets/df881bb7-808f-46a2-9758-6babc3774b07" />

<img width="200" alt="Screenshot 2568-03-28 at 17 48 13" src="https://github.com/user-attachments/assets/3707c52c-3666-4bf3-93fa-f37d05daa044" />


---

### Approach 2: Model Training with EdgeImpulse
_**Source:**_ https://studio.edgeimpulse.com/studio/654682/impulse/1/learning/keras-object-detection/3

---

#### Introduction

1) Training and testing methods are similar to the 1st approach; however, it makes things easier like a one-stop service for training-testing-deploying.

2) Best for grab-and-go users who require more build and deployment speed.

---

#### Data Aquisition

1) Randomly chose on the internet with various sources
2) The image size is about 200x200 (instead of 8x8 in Approach 1)

---

#### Settings

1) **Train/Test Split:**        68% / 32%
2) **Image width x height:**    96 x 96
3) **Resize mode:**             Fit longest axis
4) **Image color depth:**       Grayscale
5) **Epochs:**                  100
6) **LR:**                      1e-3

---

#### Results

<img width="400" alt="Screenshot 2568-03-28 at 18 36 08" src="https://github.com/user-attachments/assets/c83eb9e9-dcc3-4410-bf82-d0df6c785a15" />

_**Training Result**_

<img width="400" alt="Screenshot 2568-03-28 at 18 39 00" src="https://github.com/user-attachments/assets/2845191e-b6ad-43ee-ab99-bfba80f14b00" />

_**Testing Result**_

---

#### Actual Test Results

<img width="200" alt="Screenshot 2568-03-28 at 18 39 00" src="https://github.com/user-attachments/assets/f9958ccc-39e0-4f91-a322-d5eb650cd5bb"/>

<img width="200" alt="Screenshot 2568-03-28 at 18 39 00" src="https://github.com/user-attachments/assets/efad9d3c-f8a9-426d-bfcc-454dd6aacef9"/>

⬆️ Happy face

<img width="200" alt="Screenshot 2568-03-28 at 18 39 00" src="https://github.com/user-attachments/assets/0f3557e3-54ac-406a-b57b-d39672cfbf35"/>

<img width="200" alt="Screenshot 2568-03-28 at 18 39 00" src="https://github.com/user-attachments/assets/860ad35b-8204-46e9-810b-c7ecad811e17"/>

⬆️ Sad face

---

### Conclusion on AI
1) Works as expected

   1.1) Train and Test

   1.2) Build and upload to the ESP32 for actual testing

3) Image size was an issue as that dataset images were to small to use

4) Send detection data to the next stage.
