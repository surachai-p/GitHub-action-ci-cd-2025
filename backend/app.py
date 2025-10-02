from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        "message": "Hello World!",
        "status": "running"
    })

@app.route('/health')
def health():
    db_status = "connected" if os.getenv('DATABASE_URL') else "not configured"
    redis_status = "connected" if os.getenv('REDIS_URL') else "not configured"
    
    return jsonify({
        "status": "healthy",
        "database": db_status,
        "redis": redis_status
    })

if __name__ == '__main__':
    # Use environment variable for debug mode in production
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    # Use environment variable for host binding
    host = os.getenv('FLASK_HOST', '127.0.0.1')
    app.run(host=host, port=5000, debug=debug_mode)
