import json
import numpy as np

from scipy import stats

def test_normal(json_data):
    data = json_data.get('data')

    if not data:
        print("Error: No data provided", flush=True)
        return {"error": "No data provided"}

    if isinstance(data, str):
        data = json.loads(data)

    # Convert data to numpy array
    np_data = np.array(data, dtype=float)

    # Perform Shapiro-Wilk test
    statistic, p_value = stats.shapiro(np_data)

    # Interpret the result
    is_normal = p_value > 0.05  # Using 0.05 as the significance level

    result = {
        "is_normal": bool(is_normal),
        "p_value": float(p_value),  # Convert to float for JSON serialization
        "statistic": float(statistic)
    }
    print(f"Result: {result}", flush=True)
    return result
