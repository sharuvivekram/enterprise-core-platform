from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/',methods=['GET'])
def home():
    return jsonify({
        "status": "success",
        "message": "Welcome to the Enterprise core platform",
        "hostname": socket.gethostname(),
        "environment": os.environ.get('ENV', 'development')
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "success",
        
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)