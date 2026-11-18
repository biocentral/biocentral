import re


_SAFE_IDENTIFIER = re.compile(r"^[A-Za-z0-9_-]{1,128}$")


def validate_identifier(identifier: str) -> str:
    """ Validate server identifier (e.g. model or dataset hashes) """
    if not isinstance(identifier, str) or _SAFE_IDENTIFIER.fullmatch(identifier) is None:
        raise ValueError("Identifier must contain only letters, numbers, underscores, or hyphens")
    return identifier
