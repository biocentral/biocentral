import itertools
import Levenshtein as pylev

from typing import Dict, Set, Tuple, Any
from collections import defaultdict, namedtuple

SequenceTuple = namedtuple("SequenceTuple", ["id", "seq"])


def _get_all_possible_sequence_pairs(
    sequences: Dict[str, str],
) -> Set[Tuple[SequenceTuple, SequenceTuple]]:
    return set(
        sorted(
            list(
                itertools.chain.from_iterable(
                    [
                        [
                            (
                                SequenceTuple(id=id1, seq=s1),
                                SequenceTuple(id=id2, seq=s2),
                            )
                            for (id1, s1) in sequences.items()
                        ]
                        for (id2, s2) in sequences.items()
                    ]
                )
            )
        )
    )


def _lev_distance_matrix(
    sequences: Tuple[SequenceTuple, SequenceTuple],
) -> Dict[str, Dict[str, Dict[str, Any]]]:
    """
    Calculate Levenshtein distance and ratio metrics on an input pair of strings.
    :param seqs: Pair of sequence tuples (id, seq)
    :return:
    """
    seqs_sorted = sorted(sequences, key=lambda t: t.seq)

    return {
        seqs_sorted[0].id: {
            seqs_sorted[1].id: {
                "distance": pylev.distance(seqs_sorted[0].seq, seqs_sorted[1].seq),
                "ratio": pylev.ratio(seqs_sorted[0].seq, seqs_sorted[1].seq),
            }
        }
    }


def calculate_levenshtein_distances(sequences: Dict[str, str]) -> defaultdict:
    """
    Calculates the levenshtein distances for each sequence pair in the given dictionary

    :param sequences: Dict with seq_id -> sequence
    :return: Dict with seq_id -> Dict[seq_id, (int, float)] with levenshtein (distance, ratio) for each sequence pair
    """
    all_sequence_pairs = _get_all_possible_sequence_pairs(sequences=sequences)
    seq_sim_results = list(map(_lev_distance_matrix, all_sequence_pairs))

    sequence_distances = defaultdict(lambda: {})
    for result in seq_sim_results:
        for id1, v1 in result.items():
            for id2, v2 in v1.items():
                sequence_distances[id1][id2] = (v2["distance"], v2["ratio"])
                sequence_distances[id2][id1] = (v2["distance"], v2["ratio"])

    return sequence_distances
