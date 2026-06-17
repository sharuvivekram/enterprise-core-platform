from flask import Flask, jsonify
import os
import datetime

app = Flask(__name__)

@app.route('/')
def health_check():
    return jsonify({
        "status": "Healthy",
        "environment": os.getenv("ENVIRONMENT", "Production"),
        "platform": "Enterprise Core System",
        "timestamp": datetime.datetime.now().isoformat()
    }), 200

if __name__ == '__main__':
    # Running on port 8000 to match our existing service configurations
    app.run(host='0.0.0.0', port=8000)