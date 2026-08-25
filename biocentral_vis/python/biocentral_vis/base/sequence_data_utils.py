from typing import List, Optional
from biotrainer_core.data_classes import SequenceData

from .constants import DISCRETE_THRESHOLD

# Helper for SequenceData, move to biotrainer_core later
class SequenceDataUtils:
    DELIMITERS = [";", ","]

    def __init__(self, sequence_data: List[SequenceData]):
        self._sequence_data = sequence_data
        self._is_per_residue = None
        self._is_discrete = None
        self._maybe_delimiter = None

    def _maybe_label_delimiter(self) -> Optional[str]:
        if self._maybe_delimiter:
            return self._maybe_delimiter

        for seq_record in self._sequence_data:
            label = seq_record.label
            if label is not None:
                for delimiter in self.DELIMITERS:
                    if delimiter in label:
                        self._maybe_delimiter = delimiter
                        return delimiter
        return None

    def is_per_residue(self) -> bool:
        if self._is_per_residue is not None:
            return self._is_per_residue
        maybe_delimiter = self._maybe_label_delimiter()
        is_per_residue = all(
            [
                len(seq.label or "") == len(seq.seq or "") or (maybe_delimiter in (seq.label or "") if maybe_delimiter else False)
                for seq in self._sequence_data
            ]
        )
        self._is_per_residue = is_per_residue
        return is_per_residue

    def is_discrete(self) -> bool:
        if self._is_discrete is not None:
            return self._is_discrete

        is_per_residue = self.is_per_residue()
        labels_set = set()
        if is_per_residue:
            delimiter = self._maybe_label_delimiter()
            for seq_record in self._sequence_data:
                label = seq_record.label
                if label is None:
                    continue
                labels = label.split(delimiter)
                if len(labels) == 1:  # No delimiter
                    labels = list(labels[0])
                labels_set.update(labels)
        else:
            labels_set = {seq_record.label for seq_record in self._sequence_data if seq_record.label is not None}
        is_discrete = len(labels_set) < DISCRETE_THRESHOLD
        self._is_discrete = is_discrete
        return is_discrete

