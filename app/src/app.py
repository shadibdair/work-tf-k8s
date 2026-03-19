from flask import Flask, jsonify
import os
import socket
from datetime import datetime, timezone
from prometheus_client import CONTENT_TYPE_LATEST, Gauge, generate_latest

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "unknown-app")
POD_NAME = os.getenv("POD_NAME", socket.gethostname())
POD_IP = os.getenv("POD_IP", "unknown-ip")

# Export basic app identity as Prometheus metrics.
# This enables kube-prometheus-stack ServiceMonitors to "monitor the apps".
app_pod_info = Gauge(
    "app_pod_info",
    "Application identity exported by the custom Flask apps",
    ["app_name", "pod_name", "pod_ip"],
)


@app.route("/", methods=["GET"])
def root():
    # Main endpoint used by the task to expose pod identity details.
    return jsonify({
        "app_name": APP_NAME,
        "pod_name": POD_NAME,
        "pod_ip": POD_IP,
        "timestamp_utc": datetime.now(timezone.utc).isoformat()
    })


@app.route("/healthz", methods=["GET"])
def healthz():
    # Kubernetes liveness probe endpoint.
    return jsonify({
        "status": "ok",
        "app_name": APP_NAME
    }), 200


@app.route("/readyz", methods=["GET"])
def readyz():
    # Kubernetes readiness probe endpoint.
    return jsonify({
        "status": "ready",
        "app_name": APP_NAME
    }), 200


@app.route("/metrics", methods=["GET"])
def metrics():
    # Set identity gauges on each scrape (values come from env vars).
    # Prometheus will store the label set and the gauge value.
    app_pod_info.labels(APP_NAME, POD_NAME, POD_IP).set(1)
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)