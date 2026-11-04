import os
import socket
from datetime import datetime

from flask import Flask, jsonify, render_template_string

app = Flask(__name__)

PAGE = """
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Cloud-Native Demo App</title>
  <style>
    body{font-family:Segoe UI,Arial,sans-serif;background:#0f172a;color:#e2e8f0;
         display:flex;justify-content:center;align-items:center;height:100vh;margin:0}
    .card{background:#1e293b;padding:36px 48px;border-radius:14px;
          box-shadow:0 8px 30px rgba(0,0,0,.4);max-width:560px}
    h1{margin:0 0 6px;color:#38bdf8} .sub{color:#94a3b8;margin-bottom:22px}
    table{width:100%;border-collapse:collapse}
    td{padding:8px 0;border-bottom:1px solid #334155} td:first-child{color:#94a3b8;width:40%}
    .ok{color:#4ade80;font-weight:600}
  </style>
</head>
<body>
  <div class="card">
    <h1>Cloud-Native Demo App</h1>
    <div class="sub">Containerized with Docker, deployed on Kubernetes</div>
    <table>
      <tr><td>Student</td><td>Aditya Ubale</td></tr>
      <tr><td>PRN</td><td>202301040111</td></tr>
      <tr><td>Pod / Container ID</td><td>{{ hostname }}</td></tr>
      <tr><td>App version</td><td>{{ version }}</td></tr>
      <tr><td>Server time</td><td>{{ now }}</td></tr>
      <tr><td>Status</td><td class="ok">Running</td></tr>
    </table>
  </div>
</body>
</html>
"""


@app.route("/")
def home():
    return render_template_string(
        PAGE,
        hostname=socket.gethostname(),
        version=os.getenv("APP_VERSION", "1.0.0"),
        now=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    )


@app.route("/health")
def health():
    return jsonify(status="healthy"), 200


@app.route("/api/info")
def info():
    return jsonify(
        student="Aditya Ubale",
        prn="202301040111",
        hostname=socket.gethostname(),
        version=os.getenv("APP_VERSION", "1.0.0"),
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
