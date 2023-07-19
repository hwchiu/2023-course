from flask import Flask
from prometheus_client import start_http_server, Counter
import random
import time

app = Flask(__name__)

# 定義一個 Counter 指標
REQUEST_COUNT = Counter('request_count', 'Total number of requests')

# 模擬處理時間
def process_request():
    # 假設這裡是實際的處理程式碼
    time.sleep(random.uniform(0.1, 0.5))
    # 增加請求計數
    REQUEST_COUNT.inc()

# 定義一個路由處理函式
@app.route('/api/request', methods=['POST'])
def simulate_request():
    process_request()
    return 'Request processed successfully'

if __name__ == '__main__':
    # 啟動 HTTP 伺服器，監聽預設埠號 8000
    start_http_server(8000)
    # 啟動 Flask 應用程式
    app.run()
