# Copyright 2025 Tobias Olenyi.
# SPDX-License-Identifier: GPL-3.0-only

from __future__ import annotations

import re
import triton_python_backend_utils as pb_utils
from transformers import T5Tokenizer
import numpy as np
from typing import List

class ProteinPreprocessor:
    """Handles rare amino acid replacement before T5 tokenization"""
    
    def __init__(self, 
                 characters_to_replace: str = "UZOB",
                 replacement_character: str = "X",
                 uses_whitespaces: bool = True):
        self.characters_to_replace = characters_to_replace
        self.replacement_character = replacement_character
        self.uses_whitespaces = uses_whitespaces

    def preprocess_sequences(self, sequences: List[str]) -> List[str]:
        """
        Preprocess protein sequences:
        1. Replace rare amino acids (U, Z, O, B) with X
        2. Add spaces between amino acids for T5 tokenizer
        """
        # Replace rare amino acids
        sequences_cleaned = [
            re.sub(fr"[{self.characters_to_replace}]", self.replacement_character, sequence)
            for sequence in sequences
        ]
        
        # Add spaces between amino acids (T5 expects space-separated tokens)
        if self.uses_whitespaces:
            sequences_spaced = [" ".join(list(sequence)) for sequence in sequences_cleaned]
        else:
            sequences_spaced = sequences_cleaned
            
        return sequences_spaced

class TritonPythonModel:
    def initialize(self, args):
        """Initialize T5 tokenizer with protein preprocessing"""
        
        # Load the original T5 tokenizer from the current model version directory
        # args['model_repository'] is already '/models/prot_t5_tokenizer'
        model_path = args['model_repository'] + '/1'
        self.tokenizer = T5Tokenizer.from_pretrained(model_path, do_lower_case=False, legacy=False)
        
        # Initialize protein preprocessor for rare amino acid handling
        self.preprocessor = ProteinPreprocessor(
            characters_to_replace="UZOB",  # Rare amino acids: Selenocysteine, Pyrrolysine, etc.
            replacement_character="X",      # Standard replacement
            uses_whitespaces=True          # T5 expects space-separated amino acids
        )
        
    def execute(self, requests):
        """Process tokenization requests with rare amino acid preprocessing"""
        responses = []
        
        for request in requests:
            # Get protein sequences
            sequences_tensor = pb_utils.get_input_tensor_by_name(request, "sequences")
            sequences_array = sequences_tensor.as_numpy()
            
            # Handle different input formats (direct vs ensemble)
            sequences = []
            if sequences_array.ndim == 1:
                # Direct input format: [b'sequence1', b'sequence2']
                sequences = [seq.decode('utf-8') if isinstance(seq, bytes) else seq for seq in sequences_array]
            else:
                # Ensemble input format: [[b'sequence1'], [b'sequence2']]
                for seq_row in sequences_array:
                    for seq in seq_row:
                        if isinstance(seq, bytes):
                            sequences.append(seq.decode('utf-8'))
                        else:
                            sequences.append(seq)
            
            # Step 1: Preprocess sequences (handle rare amino acids)
            preprocessed_sequences = self.preprocessor.preprocess_sequences(sequences)
            
            # Step 2: Tokenize with T5Tokenizer (as originally trained)
            inputs = self.tokenizer(
                preprocessed_sequences,
                padding=True,
                truncation=False,
                return_tensors="np"
            )
            
            # Create output tensors
            input_ids = pb_utils.Tensor("input_ids", inputs["input_ids"].astype(np.int64))
            attention_mask = pb_utils.Tensor("attention_mask", inputs["attention_mask"].astype(np.int64))
            
            response = pb_utils.InferenceResponse(output_tensors=[input_ids, attention_mask])
            responses.append(response)
            
        return responses 