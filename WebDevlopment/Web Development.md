# IoT Monitoring System with MQTT, Flutter, and MongoDB

A lightweight system where Flutter interacts directly with MQTT for real-time data and MongoDB for storage.

## Architecture Overview

![System Diagram](diagram.png) *(Replace with your actual diagram)*

### Key Components
1. **MQTT Explorer**  
   - Debugging tool to monitor MQTT topics/messages.

2. **MQTT Broker (e.g., Mosquitto/EMQX)**  
   - Central hub for device/app communication (pub/sub).

3. **Flutter App**  
   - Connects **directly to MQTT** for real-time updates.  
   - Uses **MongoDB Dart/Flutter SDK** (e.g., `mongo_dart`) for local/remote storage.  
   - Built with **Android Studio**.

4. **MongoDB**  
   - Stores data either:  
     - *Locally*: Embedded in the app (e.g., Hive for lightweight NoSQL).  
     - *Remotely*: Via MongoDB Realm or Atlas SDK (if cloud sync needed).

## Workflow
1. **Devices → MQTT Broker**  
   - Sensors publish data (e.g., `sensor/temperature`).  
2. **Flutter App ↔ MQTT Broker**  
   - Subscribes to topics for live data.  
   - Publishes control commands (e.g., `device/fan/on`).  
3. **Flutter App ↔ MongoDB**  
   - Saves critical data locally/remotely.  
4. **MQTT Explorer**  
   - Debugs traffic on the broker.

## Setup
1. **MQTT Broker**:  
   ```bash
   mosquitto -v
