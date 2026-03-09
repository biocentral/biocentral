from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np
from pydantic import BaseModel, Field

from tests.fixtures.fixed_embedder import get_fixed_embedder

_FASTA_PATH = Path(__file__).parent / "test_sequences.fasta"


class TestSequence(BaseModel):
    """A single test sequence with metadata."""

    id: str = Field(description="Unique identifier for the test sequence")
    sequence: str = Field(description="The amino acid sequence string")
    description: str = Field(description="Human-readable description of the sequence")


class TestDataset(BaseModel):
    """Collection of test sequences for property-based testing."""

    sequences: List[TestSequence] = Field(
        description="List of test sequences in this dataset"
    )

    def get_by_id(self, seq_id: str) -> Optional[TestSequence]:
        """Get a sequence by its ID."""
        for seq in self.sequences:
            if seq.id == seq_id:
                return seq
        return None

    def get_all_sequences(self) -> List[str]:
        """Get all sequences as a list of strings."""
        return [s.sequence for s in self.sequences]

    def get_sequences_dict(self) -> Dict[str, str]:
        """Get all sequences as a dictionary (id -> sequence)."""
        return {s.id: s.sequence for s in self.sequences}

    def get_subset_dict(self, ids: List[str]) -> Dict[str, str]:
        """Get a subset of sequences by IDs as a dictionary."""
        return {id: self.get_by_id(id).sequence for id in ids}

    @classmethod
    def from_fasta(cls, fasta_path: Path) -> "TestDataset":
        """Load test dataset from a FASTA file."""
        from biotrainer.input_files import read_FASTA

        records = read_FASTA(fasta_path)
        sequences = [
            TestSequence(
                id=record.seq_id,
                sequence=record.seq,
                description=" ".join(f"{k}={v}" for k, v in record.attributes.items()),
            )
            for record in records
        ]
        return cls(sequences=sequences)


CANONICAL_TEST_DATASET = TestDataset.from_fasta(_FASTA_PATH)


def get_test_sequences(categories: Optional[List[str]] = None) -> List[str]:
    # Get test sequences, optionally filtered by category.
    if categories is None:
        return CANONICAL_TEST_DATASET.get_all_sequences()

    category_prefixes = {
        "standard": ["standard_"],
        "length": ["length_"],
        "unknown": ["unknown_"],
        "ambiguous": ["ambiguous_", "selenocysteine", "pyrrolysine"],
        "homopolymer": ["homopolymer_"],
        "motif": ["motif_"],
        "real": ["real_"],
        "edge_case": [
            "length_",
            "unknown_",
            "ambiguous_",
            "homopolymer_",
            "motif_",
            "selenocysteine",
            "pyrrolysine",
            "hydrophobic_",
            "charged_",
            "proline_",
            "cysteine_",
            "all_standard_aa",
        ],
    }

    prefixes = []
    for cat in categories:
        if cat in category_prefixes:
            prefixes.extend(category_prefixes[cat])

    result = []
    for seq in CANONICAL_TEST_DATASET.sequences:
        if any(seq.id.startswith(prefix) for prefix in prefixes):
            result.append(seq.sequence)

    return result if result else CANONICAL_TEST_DATASET.get_all_sequences()


def get_test_sequences_dict() -> Dict[str, str]:
    # Get test sequences as dictionary (id -> sequence).
    return CANONICAL_TEST_DATASET.get_sequences_dict()


def get_test_embeddings(
    model_name: str = "esm2_t6",
    pooled: bool = False,
) -> Tuple[Dict[str, str], Dict[str, np.ndarray]]:
    # Get test sequences and their embeddings ready for model testing.
    sequences_dict = get_test_sequences_dict()
    embedder = get_fixed_embedder(model_name)
    embeddings_dict = embedder.embed_dict(sequences_dict, pooled=pooled)
    return sequences_dict, embeddings_dict


def get_dataset_statistics() -> Dict:
    sequences = CANONICAL_TEST_DATASET.get_all_sequences()
    lengths = [len(s) for s in sequences]

    return {
        "total_sequences": len(sequences),
        "min_length": min(lengths),
        "max_length": max(lengths),
        "mean_length": sum(lengths) / len(lengths),
        "sequences_with_unknown": sum(1 for s in sequences if "X" in s),
    }
