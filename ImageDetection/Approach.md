## Image Detection Approach

### Approach 1: Model Training with YOLO11s-cls
#### Introduction
1) Source: https://docs.ultralytics.com/tasks/detect/ 
<img width="750" alt="Screenshot 2568-03-26 at 20 20 17" src="https://github.com/user-attachments/assets/1f2cae21-7a54-48b3-92fb-0046dfc99485"> 
    
2) The training and testing were done on a MacBook Pro M1 w/ 16 GB of ram (2020). It used **"MPS"** instead of **"CUDA"** _(MPS - Metal Performance Shaders is the Apple’s GPU-accelerated framework for deep learning)_
    
3) This project used YOLO11s, _small_ to balance model performance and training resources.
    
4) Initially, YOLO11l _(large)_ was used. The system underwent training and testing, but its size and the amount of training resources it required significantly impacted the training time.
    
---

#### Data Acquisition

---

#### Settings
1) The structure of the code consists of three parts: .py and two .yaml(s) for settings.

<img width="500" alt="Screenshot 2568-03-26 at 21 07 39" src="https://github.com/user-attachments/assets/a26a0a96-5984-4ae3-ae94-f084e7ed45d3" />

<img width="500" alt="Screenshot 2568-03-26 at 21 08 14" src="https://github.com/user-attachments/assets/fc5cd35e-57fc-4111-baa6-4790cc8e8831" />

1.1) Model Settings named as "**cfg.yaml**" _(Left)_

1.2) Data set with Train, Validate, and Test named as "**dataset.yaml**" _(Right)_

---

#### Evaluation Metrics

---

#### Results 



---
### Approach 2: Model Training with EdgeImpulse
    1) Source: https://studio.edgeimpulse.com/studio/654682/impulse/1/learning/keras-object-detection/3


