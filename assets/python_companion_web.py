import os
import json

from web import handle_command

if __name__ == '__main__':
    command = os.environ.get("PYODIDE_COMMAND", "")
    data = os.environ.get("PYODIDE_DATA", None)
    pyodide_result = json.dumps(handle_command(command, data))
    print(pyodide_result)

# Compile via
# dart run serious_python:main package --asset assets/python_companion.zip python_companion/ -p Pyodide --requirements "-r,python_companion/requirements.txt"

# Strictly only use these packages for web compatibility:
# https://pyodide.org/en/stable/usage/packages-in-pyodide.html