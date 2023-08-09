from flask import Flask, jsonify, request
from prometheus_client import Counter, generate_latest, Gauge, Histogram
import random
import time
import os
import redis

app = Flask(__name__)

USE_REDIS = os.environ.get('USE_REDIS', False)
REDIS_HOST = os.environ.get('REDIS_HOST', "127.0.0.1")

if USE_REDIS:
    try:
        r = redis.Redis(host=REDIS_HOST, port=6379)
        r.ping()
        print("Connected to Redis successfully!")
    except redis.ConnectionError as error:
        print("Error connecting to Redis:", error)
        exit(1)    


app = Flask(__name__)

@app.route('/message', methods=['GET', 'POST'])
def message():
    if not USE_REDIS:
        return 'Redis integration is not enabled.'
    if request.method == 'POST':
        message = request.form['message']
        r.set('message', message)
        return 'Message stored successfully!'
    else:
        response = r.get('message')
        if response:
            message = response.decode('utf-8')
        else:
            message = 'No message stored yet!'
        return 'Message: ' + message

@app.route("/")
def home():
    # 增加請求計數
    REQUEST_COUNT.labels(product="demo").inc()
    return "Hello, Docker!"

@app.route("/api2")
def gauge():
    RANDOM_NUMBER.set(random.randint(0,500)) 
    return "Hi, Gauge Demo"

@app.route("/api3")
def histogram():
    REQUEST_LATENCY.observe(random.uniform(0,10.0)) 
    return "Hi, Histogram Demo"

@app.route('/metrics')
def metrics():
    return generate_latest()

@app.route("/api/v1/hello")
def hello():
    return jsonify({"message": "Hello, API!"})

# 定義一個 Counter 指標
REQUEST_COUNT = Counter('request_count', 'Total number of requests', ['product'])
RANDOM_NUMBER = Gauge('my_random_number', 'Random Number')
REQUEST_LATENCY = Histogram('request_latency_seconds', 'Request latency in seconds')

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
