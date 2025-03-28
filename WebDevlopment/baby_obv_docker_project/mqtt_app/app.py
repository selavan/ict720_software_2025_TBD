import paho.mqtt.client as mqtt
from datetime import datetime
import urllib3
import json
import sqlite3
from pymongo import MongoClient

http = urllib3.PoolManager()

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, reason_code, properties):
    print(f"Connected with result code {reason_code}")
    # Subscribing in on_connect() means that if we lose the connection and
    client.subscribe("baby_obv/#")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic + " " + str(msg.payload))
    
    # Baby data message
    if msg.topic.split('/')[-1] == "baby_status":
        data = json.loads(msg.payload.decode())
        
        # Extract baby status
        #station = msg.topic.split('/')[2]
        baby_status_var = data['baby_status']
        print(f"Status: {baby_status_var}")
        
        # Insert into SQLite
        c.execute("INSERT INTO baby (baby_status) VALUES (?)", 
                  (baby_status_var,))
        print("Inserted to SQLite")
        conn.commit()
        
        # Insert into MongoDB
        db = mongo_client.baby_obv_db
        db_col = db.ble_logs
        db_col.insert_one({
            "timestamp": datetime.now(), 
            "baby_status": baby_status_var
        })
        print("Inserted to MongoDB")

# Initialize MQTT
mqttc = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
mqttc.on_connect = on_connect
mqttc.on_message = on_message

mqttc.connect("mosquitto", 1883, 60)

# Initialize SQLite
conn = sqlite3.connect('baby.db')
c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS baby (
          _id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
          baby_status TEXT
          )''')
conn.commit()

# Initialize MongoDB
mongo_client = MongoClient('baby_obv_docker_project-mongo-1', 27017,
                           username='root', password='example')

# Start the MQTT loop
mqttc.loop_forever()