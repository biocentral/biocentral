import numpy as np

from typing import Optional, List, Dict, Any

from ._generated import ApiClient, Configuration, TaxonomyItem, SequenceTrainingData
from .clients import BiocentralServerTask, EmbeddingsClient, ProteinsClient, CustomModelsClient, PredictClient


class BiocentralAPI:
    def __init__(self, api_token: Optional[str] = None, server_url: Optional[str] = None):
        self.api_token = api_token if api_token else ""
        self.server_url = server_url if server_url else "http://laser.bio.cit.tum.de:9540"  # TODO!
        self.configuration = Configuration(
            host=self.server_url
        )

    def embed(self,
              embedder_name: str,
              sequence_data: Dict[str, str],
              reduce: Optional[bool] = True,
              use_half_precision: Optional[bool] = False) -> BiocentralServerTask[Dict[str, np.ndarray]]:
        """
        Generates embeddings for the given sequence data using the specified embedder.

        :param embedder_name: The name of the embedder to be used for generating embeddings.
            Examples: "one_hot_encoding", "Rostlab/prot_t5_xl_uniref50", "random_embedder"
        :param sequence_data: A dictionary containing the sequence data for which embeddings should be
            calculated. Typically maps identifiers to sequences.
        :param reduce: Specifies whether the embeddings should be reduced to per-sequence or not. Defaults to True.
        :param use_half_precision: Indicates whether half-precision should be used for embeddings to
            minimize memory usage. Defaults to False.
        :return: Returns a BiocentralServerTask object that can be run to retrieve the embeddings.
        """
        if len(sequence_data) == 0:
            raise ValueError("No sequence data provided.")
        sequences = list(sequence_data.values())
        if len(sequences) != len(set(sequences)):
            raise ValueError("Duplicate sequences provided. Please make sure to provide unique sequences.")

        embeddings_client = EmbeddingsClient()
        with ApiClient(self.configuration) as api_client:
            biocentral_server_task = embeddings_client.embed(api_client, embedder_name, reduce, sequence_data,
                                                             use_half_precision)
            return biocentral_server_task

    def taxonomy(self, taxonomy_ids: List[int]) -> Optional[List[TaxonomyItem]]:
        """
        Retrieve taxonomy information based on a list of taxonomy identifiers.

        This function retrieves taxonomy data for
        the specified taxonomy identifiers (e.g. scientific name and family).

        :param taxonomy_ids: List of taxonomy identifiers to query.
        :return: List of TaxonomyItems corresponding to the provided taxonomy identifiers, or None if request failed.
        """
        if len(taxonomy_ids) == 0:
            raise ValueError("No taxonomy identifiers provided.")

        proteins_client = ProteinsClient()
        with ApiClient(self.configuration) as api_client:
            taxonomy_data = proteins_client.taxonomy(api_client, taxonomy_ids)
            return taxonomy_data

    def train(self, config: Dict[str, Any],
              training_data: List[SequenceTrainingData]) -> BiocentralServerTask[Dict[str, Any]]:
        """
        Trains a deep learning model using the provided configuration and training data via biotrainer.

        This method initializes a custom models client and uses an API client to invoke
        the training process with the specified configuration and training data. The task
        of training is executed on the biocentral server.

        :param config: The configuration settings for the model to be trained.
            This dictionary defines the parameters necessary for training the model.
        :param training_data: A list of sequence training data used for training the model.
            The data must conform to required input specifications for the server.
        :return: A task representing the training operation on the biocentral server.
            The return value includes task-related information required for monitoring
            or tracking the training progress.
        """
        if len(config) == 0:
            raise ValueError("No configuration provided.")
        if len(training_data) == 0:
            raise ValueError("No training data provided.")
        if not isinstance(training_data, list):
            raise ValueError("Training data must be a list.")

        custom_models_client = CustomModelsClient()
        with ApiClient(self.configuration) as api_client:
            biocentral_server_task = custom_models_client.train(api_client, config, training_data)
            return biocentral_server_task

    def inference(self, model_hash: str, inference_data: Dict[str, str]) -> BiocentralServerTask[Dict[str, Any]]:
        """
        Run inference on a model trained via biocentral_server using given input data.

        This method facilitates executing an inference pipeline using a predefined
        model identified by its hash and specific input data. It initializes a
        custom models client and uses the API configuration to execute the inference
        call. The resulting server task is returned to the caller.

        :param model_hash: Unique identifier for the model to be used for inference.
        :param inference_data: A dictionary containing sequence data to be used for inference.
        :return: The task object from the server representing the result of the inference process.
        """
        if len(model_hash) == 0:
            raise ValueError("No valid model hash provided.")
        if len(inference_data) == 0:
            raise ValueError("No inference data provided.")
        if not isinstance(inference_data, dict):
            raise ValueError("Inference data must be a dictionary.")

        custom_models_client = CustomModelsClient()
        with ApiClient(self.configuration) as api_client:
            biocentral_server_task = custom_models_client.inference(api_client, model_hash, inference_data)
            return biocentral_server_task

    def predict(self, model_names: List[str], sequence_data: Dict[str, str]) -> BiocentralServerTask[Dict[str, Any]]:
        """
        Provides functionality to predict results based on specified pre-trained model names and sequence data.

        In contrast to the inference method, this method uses pre-defined models instead of
        user-defined and user-trained models.

        :param model_names: List of model names from which predictions should be created.
        :param sequence_data: Dictionary containing sequence data for prediction, where keys represent identifiers
            and values represent the sequences.
        """
        if len(model_names) == 0:
            raise ValueError("No valid model names provided.")
        invalid_model_names = [model_name for model_name in model_names if len(model_name) == 0]
        if len(invalid_model_names) > 0:
            raise ValueError(f"Invalid model names provided: {invalid_model_names}")
        if len(sequence_data) == 0:
            raise ValueError("No prediction data provided.")
        if not isinstance(sequence_data, dict):
            raise ValueError("Prediction data must be a dictionary.")

        predict_client = PredictClient()
        with ApiClient(self.configuration) as api_client:
            biocentral_server_task = predict_client.predict(api_client, model_names, sequence_data)
            return biocentral_server_task