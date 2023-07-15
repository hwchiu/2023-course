from flask import Flask, jsonify, request
import os
import redis

app = Flask(__name__)

USE_REDIS = os.environ.get('USE_REDIS', False)
REDIS_HOST = os.environ.get('REDIS_HOST', "127.0.0.1")
SERVER_PORT = os.environ.get('SERVER_PORT', 5000)

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
    return "Hello, Docker!"

@app.route("/api/v1/hello")
def hello():
    return jsonify({"message": "Hello, API!"})

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
