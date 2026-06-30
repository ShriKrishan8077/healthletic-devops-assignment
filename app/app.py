from flask import Flask, jsonify
from app.config import Config
from app.db import get_db_connection

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

@app.route("/db-health")
def db_health():
    try:
        connection = get_db_connection()

        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()

        cursor.close()
        connection.close()

        return jsonify({
            "database": "connected"
        }), 200

    except Exception as e:
        return jsonify({
            "database": "failed",
            "error": str(e)
        }), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)