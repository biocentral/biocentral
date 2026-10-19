"""Generated engineering mutations must come out in the same order in every worker process."""

import json
import os
import subprocess
import sys

GENERATE = (
    "import json, random\n"
    "from biocentral_server.active_learning.pipelines.protein_engineering.steps"
    ".mutation_generation_step import MutationGenerationStep\n"
    "random.seed(42)\n"
    "print(json.dumps(MutationGenerationStep._generate_random_mutations("
    "'MKTAYIAKQRQISFVKSHFSRQ', set(), 50)))"
)


def _generate_in_process_with_hash_seed(hash_seed: str) -> list:
    """Each RQ work horse has its own string hash seed; mimic that per subprocess."""
    completed = subprocess.run(
        [sys.executable, "-c", GENERATE],
        env={**os.environ, "PYTHONHASHSEED": hash_seed},
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(completed.stdout.strip().splitlines()[-1])


def test_order_does_not_depend_on_the_process_hash_seed():
    first = _generate_in_process_with_hash_seed("1")
    second = _generate_in_process_with_hash_seed("2")

    assert len(first) == 50
    assert first == second
