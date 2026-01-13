from __future__ import annotations

import time
import warnings
import numpy as np
import urllib.parse

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any, Tuple, Union, Iterable

from ._generated import ApiClient, Configuration, TaxonomyItem, SequenceTrainingData, DefaultApi, \
    ActiveLearningCampaignConfig, ActiveLearningIterationConfig, ActiveLearningIterationResult, \
    ActiveLearningSimulationConfig, ActiveLearningSimulationResult, BiocentralPredictionModel, CommonEmbedder, Protocol
from .clients import BiocentralServerTask, EmbeddingsClient, ProteinsClient, CustomModelsClient, PredictClient, \
    ActiveLearningClient


class _BiocentralAPIHealth(BaseModel):
    url: str = Field(description="The URL of the biocentral server.")
    healthy: bool = Field(description="Indicates whether the biocentral server is healthy.")
    version: Optional[str] = Field(default=None, description="The version of the biocentral server.")


class BiocentralAPI:
    """
    High-level Python API for programmatic use (e.g., notebooks).
    """

    DEFAULT_LOCAL_URL = "http://localhost:9540"
    API_URL = "https://biocentral.rostlab.org"
    MIN_API_VERSION = "1.0.0"
    MAX_API_VERSION = "2.0.0"
    RECOMMENDED_MAX_SEQUENCE_LENGTH = 1024

    def __init__(self,
                 api_token: Optional[str] = None,
                 fixed_server_url: Optional[str] = None,
                 local_only: bool = False):
        self.api_token = api_token or ""

        # Candidate URLs: either the provided one or a reasonable local default
        self._url_health_status: List[_BiocentralAPIHealth] = []
        if fixed_server_url:
            normalized = self._normalize_url(fixed_server_url)
            if local_only and not self._is_local_url(normalized):
                raise ValueError("Using local_only=True with a non-local server_url is not allowed")
            self._url_health_status.append(_BiocentralAPIHealth(url=normalized, healthy=False))
        else:
            if not local_only:
                self._url_health_status.append(_BiocentralAPIHealth(url=self.API_URL, healthy=False))

            self._url_health_status.append(_BiocentralAPIHealth(url=self.DEFAULT_LOCAL_URL, healthy=False))

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
        base_url = self._url_health_status[0].url
        for url_health in self._url_health_status:
            if self._is_local_url(url_health.url) and url_health.healthy:
                # Always prefer local URLs over remote ones
                return url_health.url
            if url_health.healthy:
                base_url = url_health.url
        return base_url

    def get_health_status(self) -> List[Tuple[str, bool, str]]:
        return [(api_health_status.url, api_health_status.healthy, api_health_status.version) for api_health_status in
                self._url_health_status]

    def _update_health_status(self, request_timeout: float = 2.0) -> List[_BiocentralAPIHealth]:
        updated: List[_BiocentralAPIHealth] = []
        for api_health_status in self._url_health_status:
            updated_health_status = self._health_check(api_health_status.url, timeout=request_timeout)
            updated.append(updated_health_status)
        self._url_health_status = updated
        return self._url_health_status

    @staticmethod
    def _health_check(url: str, timeout: float = 2.0) -> _BiocentralAPIHealth:
        try:
            configuration = Configuration(host=url)
            with ApiClient(configuration) as api_client:
                default_api = DefaultApi(api_client)
                resp = default_api.health_check_health_get_with_http_info(_request_timeout=timeout)
                if (resp.status_code or 404) == 200:
                    server_version = resp.data["version"]
                    server_major_version = server_version.split(".")[0]
                    min_major_version = BiocentralAPI.MIN_API_VERSION.split(".")[0]
                    max_major_version = BiocentralAPI.MAX_API_VERSION.split(".")[0]
                    if min_major_version <= server_major_version < max_major_version:
                        return _BiocentralAPIHealth(url=url, healthy=True, version=server_version)
                return _BiocentralAPIHealth(url=url, healthy=False)
        except Exception:
            return _BiocentralAPIHealth(url=url, healthy=False)

    def wait_until_healthy(self, max_wait_seconds: float = 30.0, poll_interval: float = 1.0) -> BiocentralAPI:
        """Poll the candidate URLs until a healthy one is found or timeout.

        Returns the selected base URL if found; raises TimeoutError otherwise.
        """
        deadline = time.time() + max_wait_seconds
        while time.time() < deadline:
            status = self._update_health_status()
            healthy_candidates = [api_health_status for api_health_status in status if api_health_status.healthy]
            if len(healthy_candidates) > 0:
                print(f"Found healthy biocentral servers at:")
                for candidate in healthy_candidates:
                    print(f"  {candidate.url} - v{candidate.version}")
                return self
            time.sleep(poll_interval)
        raise TimeoutError("No healthy biocentral service became available in time")

    @staticmethod
    def _check_sequence_lengths(seqs: Iterable[str]) -> None:
        n_overlong_seqs = 0
        for seq in seqs:
            if len(seq) > BiocentralAPI.RECOMMENDED_MAX_SEQUENCE_LENGTH:
                n_overlong_seqs += 1
        if n_overlong_seqs > 0:
            warnings.warn(
                f"{n_overlong_seqs} sequences are longer than the recommended "
                f"amount of {BiocentralAPI.RECOMMENDED_MAX_SEQUENCE_LENGTH} amino acids!\n"
                f"Embeddings will still be computed, but might not be as reliable for these sequences.",
            stacklevel=3)

    def embed(self,
              embedder_name: Union[str, CommonEmbedder],
              sequence_data: Dict[str, str],
              reduce: Optional[bool] = True,
              use_half_precision: Optional[bool] = False) -> BiocentralServerTask[Dict[str, np.ndarray]]:
        """
        Generates embeddings for the given sequence data using the specified embedder.

        :param embedder_name: The name of the embedder to be used for generating embeddings.
            Can be any valid huggingface string identifier or a CommonEmbedder enum value.
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
        BiocentralAPI._check_sequence_lengths(sequences)

        if isinstance(embedder_name, CommonEmbedder):
            embedder_name = embedder_name.value

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
        BiocentralAPI._check_sequence_lengths([train_data_point.sequence for train_data_point in training_data])

        if "embedder_name" in config:
            embedder_name = config["embedder_name"]
            if isinstance(embedder_name, CommonEmbedder):
                config["embedder_name"] = embedder_name.value
        else:
            raise ValueError("No embedder name provided in configuration.")

        if "protocol" in config:
            protocol = config["protocol"]
            if isinstance(protocol, Protocol):
                config["protocol"] = protocol.value
        else:
            raise ValueError("No training protocol provided in configuration.")

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
        sequences = list(inference_data.values())
        if len(sequences) != len(set(sequences)):
            raise ValueError("Duplicate sequences provided. Please make sure to provide unique sequences.")
        if not isinstance(inference_data, dict):
            raise ValueError("Inference data must be a dictionary.")
        BiocentralAPI._check_sequence_lengths(sequences)

        custom_models_client = CustomModelsClient()
        with self._create_api_client() as api_client:
            biocentral_server_task = custom_models_client.inference(api_client, model_hash, inference_data)
            return biocentral_server_task

    def predict(self, model_names: List[BiocentralPredictionModel], sequence_data: Dict[str, str]) -> \
            BiocentralServerTask[Dict[str, Any]]:
        """
        Provides functionality to predict results based on specified pre-trained model names and sequence data.

        In contrast to the inference method, this method uses pre-defined models instead of
        user-defined and user-trained models.

        :param model_names: List of biocentral prediction model names from which predictions should be created.
        :param sequence_data: Dictionary containing sequence data for prediction, where keys represent identifiers
            and values represent the sequences.
        """
        if len(model_names) == 0:
            raise ValueError("No valid model names provided.")
        invalid_model_names = [model_name for model_name in model_names if
                               len(model_name) == 0 or model_name not in BiocentralPredictionModel.__members__.values()]
        if len(invalid_model_names) > 0:
            raise ValueError(f"Invalid model names provided: {invalid_model_names}")
        if len(sequence_data) == 0:
            raise ValueError("No prediction data provided.")
        if not isinstance(sequence_data, dict):
            raise ValueError("Prediction data must be a dictionary.")
        sequences = list(sequence_data.values())
        if len(sequences) != len(set(sequences)):
            raise ValueError("Duplicate sequences provided. Please make sure to provide unique sequences.")
        BiocentralAPI._check_sequence_lengths(sequences)

        predict_client = PredictClient()
        with self._create_api_client() as api_client:
            biocentral_server_task = predict_client.predict(api_client, model_names, sequence_data)
            return biocentral_server_task

    def al_iteration(self, campaign_config: ActiveLearningCampaignConfig,
                     iteration_config: ActiveLearningIterationConfig) -> BiocentralServerTask[
        ActiveLearningIterationResult]:
        if len(iteration_config.iteration_data) < 2:
            raise ValueError("Not enough data provided for an active learning iteration.")
        BiocentralAPI._check_sequence_lengths(
            [iteration_data_point.sequence for iteration_data_point in iteration_config.iteration_data])

        active_learning_client = ActiveLearningClient()
        with self._create_api_client() as api_client:
            biocentral_server_task = active_learning_client.al_iteration(api_client, campaign_config, iteration_config)
            return biocentral_server_task

    def al_simulation(self, campaign_config: ActiveLearningCampaignConfig,
                      simulation_config: ActiveLearningSimulationConfig) -> BiocentralServerTask[
        ActiveLearningSimulationResult]:
        if len(simulation_config.simulation_data) < 2:
            raise ValueError("Not enough data provided for an active learning simulation.")
        BiocentralAPI._check_sequence_lengths(
            [simulation_data_point.sequence for simulation_data_point in simulation_config.simulation_data])

        active_learning_client = ActiveLearningClient()
        with self._create_api_client() as api_client:
            biocentral_server_task = active_learning_client.al_simulation(api_client, campaign_config,
                                                                          simulation_config)
            return biocentral_server_task
