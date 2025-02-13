from desktop import run_server

if __name__ == '__main__':
    run_server()

# Compile via
# dart run serious_python:main package --asset assets/python_companion.zip python_companion/ -p Linux --requirements -r,python_companion/requirements.txt

# Strictly only use these packages for web compatibility:
# https://pyodide.org/en/stable/usage/packages-in-pyodide.html