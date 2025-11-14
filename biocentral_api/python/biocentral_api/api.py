from __future__ import annotations

import time
import urllib.parse
import numpy as np

from typing import Optional, List, Dict, Any, Tuple

from ._generated import ApiClient, Configuration, TaxonomyItem, SequenceTrainingData, DefaultApi
from .clients import BiocentralServerTask, EmbeddingsClient, ProteinsClient, CustomModelsClient, PredictClient


class BiocentralAPI:
    """
    High-level Python API for programmatic use (e.g., notebooks).
    """

    DEFAULT_LOCAL_URL = "http://localhost:9540"
    API_URL = "https://biocentral.rostlab.org"

    def __init__(self,
                 api_token: Optional[str] = None,
                 fixed_server_url: Optional[str] = None,
                 local_only: bool = False):
        self.api_token = api_token or ""

        # Candidate URLs: either the provided one or a reasonable local default
        self._url_health_status: List[Tuple[str, bool]] = []
        if fixed_server_url:
            normalized = self._normalize_url(fixed_server_url)
            if local_only and not self._is_local_url(normalized):
                raise ValueError("Using local_only=True with a non-local server_url is not allowed")
            self._url_health_status.append((normalized, False))
        else:
            if not local_only:
                self._url_health_status.append((self.API_URL, False))

            self._url_health_status.append((self.DEFAULT_LOCAL_URL, False))

    def _create_api_client(self) -> ApiClient:
        """Create an ApiClient bound to the currently selected base URL, including auth headers if provided."""
        base_url = self._get_base_url()
        cfg = Configuration(host=base_url)
        # Attach API token via default headers if present
        if self.api_token and self.api_token != "":
            api_client = ApiClient(cfg, header_name="Authorization", header_value=f"Bearer {self.api_token}")
        else:
            api_client = ApiClient(cfg)
        return api_client

    # ----------------------- URL + Health utilities -----------------------
    @staticmethod
    def _normalize_url(url: str) -> str:
        if not url:
            return BiocentralAPI.DEFAULT_LOCAL_URL
        parsed = urllib.parse.urlparse(url if "://" in url else f"http://{url}")
        # strip trailing slashes
        netloc = parsed.netloc or parsed.path
        scheme = parsed.scheme or "http"
        normalized = f"{scheme}://{netloc}"
        return normalized.rstrip("/")

    @staticmethod
    def _is_local_url(url: str) -> bool:
        return any(h in url for h in ["localhost", "127.0.0.1"])

    def _get_base_url(self) -> str:
        # Prefer first healthy URL if any, otherwise first candidate
        for url, healthy in self._url_health_status:
            if healthy:
                return url
        return self._url_health_status[0][0]

    def get_health_status(self) -> Dict[str, bool]:
        return {url: healthy for (url, healthy) in self._url_health_status}

    def _update_health_status(self, request_timeout: float = 2.0) -> Dict[str, bool]:
        updated: List[Tuple[str, bool]] = []
        for (url, _) in self._url_health_status:
            healthy = self._health_check(url, timeout=request_timeout)
            updated.append((url, healthy))
        self._url_health_status = updated
        return self.get_health_status()

    @staticmethod
    def _health_check(url: str, timeout: float = 2.0) -> bool:
        try:
            configuration = Configuration(host=url)
            with ApiClient(configuration) as api_client:
                default_api = DefaultApi(api_client)
                resp = default_api.health_check_health_get_with_http_info(_request_timeout=timeout)
                return (resp.status_code or 404) == 200
        except Exception:
            return False

    def wait_until_healthy(self, max_wait_seconds: float = 30.0, poll_interval: float = 1.0) -> BiocentralAPI:
        """Poll the candidate URLs until a healthy one is found or timeout.

        Returns the selected base URL if found; raises TimeoutError otherwise.
        """
        deadline = time.time() + max_wait_seconds
        while time.time() < deadline:
            status = self._update_health_status()
            healthy_candidates = [u for u, ok in status.items() if ok]
            if len(healthy_candidates) > 0:
                print(f"Found healthy biocentral servers at:")
                for url in healthy_candidates:
                    print(f"  {url}")
                return self
            time.sleep(poll_interval)
        raise TimeoutError("No healthy biocentral service became available in time")

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
        with self._create_api_client() as api_client:
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
        with self._create_api_client() as api_client:
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
        with self._create_api_client() as api_client:
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
        with self._create_api_client() as api_client:
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
        with self._create_api_client() as api_client:
            biocentral_server_task = predict_client.predict(api_client, model_names, sequence_data)
            return biocentral_server_task
