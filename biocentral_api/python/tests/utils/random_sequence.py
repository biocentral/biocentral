import random


def create_random_sequence(length: int = 50):
    """ Generate a random sequence to always test embedding rather than loading from database """
    return "".join(random.choices("ACDEFGHIKLMNPQRSTVWY", k=length))
