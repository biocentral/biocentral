import json
import functionality

_command_functions = {
    "setup": lambda _: "Success",
    "test_normal": lambda data: functionality.test_normal(data),
    "read_h5": lambda data: functionality.read_h5(data),
    "write_h5": lambda data: functionality.write_h5(data)
}


def handle_command(command: str, data):
    command_function = _command_functions.get(command)
    try:
        loaded_data = json.loads(data)
    except json.decoder.JSONDecodeError:
        loaded_data = data
    return command_function(loaded_data)
