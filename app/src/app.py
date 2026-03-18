from flask import Flask, jsonify
import os
import socket
from datetime import datetime, timezone

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "unknown-app")
POD_NAME = os.getenv("POD_NAME", socket.gethostname())
POD_IP = os.getenv("POD_IP", "unknown-ip")


@app.route("/", methods=["GET"])
def root():
    return jsonify({
        "app_name": APP_NAME,
        "pod_name": POD_NAME,
        "pod_ip": POD_IP,
        "timestamp_utc": datetime.now(timezone.utc).isoformat()
    })


@app.route("/healthz", methods=["GET"])
def healthz():
    return jsonify({
        "status": "ok",
        "app_name": APP_NAME
    }), 200


@app.route("/readyz", methods=["GET"])
def readyz():
    return jsonify({
        "status": "ready",
        "app_name": APP_NAME
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)