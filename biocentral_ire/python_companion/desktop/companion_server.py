import functionality
import hmac
import logging
import os
import sys
from flask import Flask, abort, request, jsonify


# Redirect Flask logs to stdout
class StdoutFilter(logging.Filter):
    def filter(self, record):
        return True


handler = logging.StreamHandler(sys.stdout)
handler.addFilter(StdoutFilter())
logging.getLogger("werkzeug").addHandler(handler)
logging.getLogger("werkzeug").setLevel(logging.INFO)

app = Flask(__name__)
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)


@app.before_request
def authorize_request():
    if request.host not in {"127.0.0.1:50001", "localhost:50001"}:
        abort(403)

    expected_token = os.environ.get("BIOCENTRAL_COMPANION_TOKEN", "")
    provided_token = request.headers.get("X-Companion-Token", "")
    if not expected_token or not hmac.compare_digest(
        provided_token.encode("utf-8"), expected_token.encode("utf-8")
    ):
        abort(403)


@app.route("/test_normal", methods=["POST"])
def test_normal():
    result = functionality.test_normal(request.json)
    return jsonify(result)


@app.route("/read_h5", methods=["POST"])
def read_h5():
    result = functionality.read_h5(request.json)
    return jsonify(result)


@app.route("/write_h5", methods=["POST"])
def write_h5():
    result = functionality.write_h5(request.json)
    return jsonify(result)


@app.route("/get_h5_info", methods=["POST"])
def get_h5_info():
    result = functionality.get_h5_info(request.json)
    return jsonify(result)


@app.route("/get_embedding", methods=["POST"])
def get_embedding():
    result = functionality.get_embedding(request.json)
    return jsonify(result)


@app.route("/sync_internal_h5", methods=["POST"])
def sync_internal_h5():
    result = functionality.sync_internal_h5(request.json)
    return jsonify(result)


@app.route("/terminate", methods=["POST"])
def terminate():
    print("Terminating server from terminate request")
    exit(0)


@app.route("/health_check", methods=["GET"])
def health_check():
    return jsonify({"status": "OK"})


def run_server():
    print("Starting server...", flush=True)
    app.run(host="127.0.0.1", port=50001, debug=False, use_reloader=False)
