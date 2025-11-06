import hashlib


def calculate_sequence_hash(sequence: str) -> str:
    """ Sequence hashing function from biotrainer. """
    suffix = len(sequence)
    sequence = f"{sequence}_{suffix}"
    return hashlib.sha256(sequence.encode()).hexdigest()
