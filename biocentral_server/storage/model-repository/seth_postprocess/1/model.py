# Copyright 2025 Tobias Olenyi.
# SPDX-License-Identifier: GPL-3.0-only

"""
Triton Python backend for SETH disorder prediction post-processing.
"""
import numpy as np
import triton_python_backend_utils as pb_utils


class TritonPythonModel:
    """Post-processing model for disorder predictions."""
    
    def initialize(self, args):
        """Initialize the model."""
        self.model_config = args['model_config']
        self.class_labels = {0: "Ordered", 1: "Disordered"}
        
    def execute(self, requests):
        """Execute post-processing on raw ONNX scores."""
        responses = []
        
        for request in requests:
            # Get raw scores from ONNX model
            raw_scores = pb_utils.get_input_tensor_by_name(request, "raw_scores")
            raw_scores_np = raw_scores.as_numpy()  # Shape: (batch_size, seq_len, 2)
            
            # Convert to class predictions
            class_predictions = np.argmax(raw_scores_np, axis=-1)  # Shape: (batch_size, seq_len)
            
            # Convert to string labels
            batch_size, seq_len = class_predictions.shape
            string_predictions = []
            
            for i in range(batch_size):
                sequence_labels = [
                    self.class_labels[int(pred)] for pred in class_predictions[i]
                ]
                # Join labels with no delimiter for per-residue predictions
                string_predictions.append("".join(sequence_labels))
            
            # Create output tensor
            output_tensor = pb_utils.Tensor(
                "disorder_predictions", 
                np.array(string_predictions, dtype=object)
            )
            
            responses.append(pb_utils.InferenceResponse([output_tensor]))
        
        return responses
    
    def finalize(self):
        """Clean up resources."""
        pass