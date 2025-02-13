import sys
import logging
import functionality

from flask import Flask, request, jsonify


# Redirect Flask logs to stdout
class StdoutFilter(logging.Filter):
    def filter(self, record):
        return True


handler = logging.StreamHandler(sys.stdout)
handler.addFilter(StdoutFilter())
logging.getLogger('werkzeug').addHandler(handler)
logging.getLogger('werkzeug').setLevel(logging.INFO)

app = Flask(__name__)
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)

@app.route('/test_normal', methods=['POST'])
def test_normal():
    result = functionality.test_normal(request.json)
    return jsonify(result)


@app.route('/read_h5', methods=['POST'])
def read_h5():
    result = functionality.read_h5(request.json)
    return jsonify(result)


@app.route('/write_h5', methods=['POST'])
def write_h5():
    result = functionality.write_h5(request.json)
    return jsonify(result)



@app.route('/terminate', methods=['GET'])
def terminate():
    print("Terminating server from terminate request")
    exit(0)


@app.route('/health_check', methods=['GET'])
def health_check():
    return jsonify({"status": "OK"})


def run_server():
    print("Starting server...", flush=True)
    app.run(port=50001, debug=True, use_reloader=False)
