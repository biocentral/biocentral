import sys
import json
import h5py
import logging
import numpy as np

from scipy import stats
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

test_data = [0.1, 0.2, 0.3, 1, 2, 3, 10, 5]


def _test_normal(data):
    # Convert data to numpy array
    np_data = np.array(data, dtype=float)

    # Perform Shapiro-Wilk test
    statistic, p_value = stats.shapiro(np_data)

    # Interpret the result
    is_normal = p_value > 0.05  # Using 0.05 as the significance level

    result = {
        "is_normal": bool(is_normal),
        "p_value": p_value,
        "statistic": statistic
    }
    print(f"Result: {result}", flush=True)
    return result


_test_normal(test_data)


@app.route('/test_normal', methods=['POST'])
def test_normal():
    # Get data from the request
    print("Request received", flush=True)
    data = json.loads(request.json.get('data'))
    print(f"Received data: {data}", flush=True)
    if not data:
        print("Error: No data provided", flush=True)
        return jsonify({"error": "No data provided"}), 400

    try:
        result = _test_normal(data)
        return jsonify(result)

    except Exception as e:
        error_message = f"Error: {str(e)}"
        print(error_message, flush=True)
        return jsonify({"error": error_message}), 400


@app.route('/read_h5', methods=['POST'])
def read_h5():
    absolute_file_path = request.json.get('absolute_file_path')
    embeddings_file = h5py.File(absolute_file_path, 'r')

    # "original_id" from embeddings file -> Embedding
    id2emb = {embeddings_file[idx].attrs["original_id"]: np.array(embedding).tolist() for (idx, embedding) in
              embeddings_file.items()}

    embeddings_file.close()
    return jsonify({"id2emb": id2emb})


@app.route('/terminate', methods=['GET'])
def terminate():
    print("Terminating server from terminate request")
    exit(0)


@app.route('/health_check', methods=['GET'])
def health_check():
    return jsonify({"status": "OK"})


if __name__ == '__main__':
    print("Starting server...", flush=True)
    app.run(port=50001, debug=True, use_reloader=False)

# Compile via
# dart run serious_python:main package --asset assets/python_companion.zip python_companion/ -p Linux --requirements -r,python_companion/requirements.txt
