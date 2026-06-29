from flask import Flask, jsonify
from app.config import Config

app = Flask(__name__)


@app.route("/")
def home():
    return jsonify({
        "message": "Welcome to Healthletic Flask API",
        "version": Config.APP_VERSION
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })


@app.route("/version")
def version():
    return jsonify({
        "version": Config.APP_VERSION
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)