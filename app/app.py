import os
from flask import Flask
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return {
        # 🔌 Now it dynamically pulls from the ConfigMap injection!
        # os.getenv("VARIABLE_NAME", "FALLBACK_VALUE")
        "environment": os.getenv("APP_ENV", "Local-Development"),
        "platform": os.getenv("PLATFORM_NAME", "Fallback-Platform-Name"),
        "status": os.getenv("APP_STATUS", "Running without ConfigMap"),
        "timestamp": datetime.utcnow().isoformat()
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)