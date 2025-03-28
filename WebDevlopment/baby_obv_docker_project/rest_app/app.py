from flask import Flask, request, jsonify
from pymongo import MongoClient
from datetime import datetime, timedelta
import os
import sys

# Initialize environment variables
mongo_uri = os.getenv('MONGO_URI', 'mongodb://root:example@baby_obv_docker_project-mongo-1:27017/')
mongo_db = os.getenv('MONGO_DB', 'baby_obv_db')
mongo_col = os.getenv('MONGO_COL', 'ble_logs')

if not mongo_uri or not mongo_db or not mongo_col:
    print('MongoDB configuration is required')
    sys.exit(1)

# Initialize app
app = Flask(__name__)
mongo_client = MongoClient(mongo_uri)
print("MongoDB connected: ", mongo_uri)

def get_recent_data(collection, query, mins_cond=1):
    """
    Fetches recent data from a MongoDB collection within the last 'mins_cond' minutes.
    Returns the data sorted by timestamp (newest first).
    """
    return collection.find({
        **query,
        "timestamp": {"$gt": datetime.now() - timedelta(minutes=mins_cond)}
    }).sort("timestamp", -1)

# Modified route to fetch baby_status data
@app.route('/api/baby_status', methods=['GET'])
def query_baby_status():
    """
    Handles GET requests to /api/baby_status. Fetches recent baby status data from MongoDB
    based on the requested time period (mins) and returns it as JSON.
    """ 
    resp = {}
    db = mongo_client[mongo_db]
    db_col = db[mongo_col]
    mins_cond = int(request.args.get('mins', 1))

    try:
        # Query without a station filter, just fetch recent data
        data = get_recent_data(db_col, {}, mins_cond)
        resp['status'] = 'ok'
        resp['data'] = [{
            'timestamp': record['timestamp'].isoformat(),
            'baby_status': record.get('baby_status', None)
        } for record in data]

        if not resp['data']:
            resp['status'] = 'error'
            resp['message'] = 'no data found'
            return jsonify(resp), 404

    except Exception as e:
        resp['status'] = 'error'
        resp['message'] = str(e)
        return jsonify(resp), 500

    return jsonify(resp)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')