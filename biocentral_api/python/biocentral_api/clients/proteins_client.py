from __future__ import annotations

from tqdm import tqdm
from typing import List, Optional, Dict

from .client_interface import ClientInterface
from .tasks import DTOHandler, BiocentralServerTask

from .._generated import (
    ApiClient,
    TaxonomyRequest,
    ProteinsApi,
    TaxonomyItem,
    TaxonomyResponse,
    ClusteringRequest,
    PerplexityRequest,
    PerplexityResult,
    TaskDTO,
    TaskStatus,
)


class _ClusterDTOHandler(DTOHandler):
    def handle_result(self, dtos: List[TaskDTO]):
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.FINISHED:
                return dto.clustered_data

        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        for dto in dtos:
            status = dto.status
            match status:
                case TaskStatus.PENDING:
                    pbar.set_description("Waiting for clustering task to start..")
                case TaskStatus.RUNNING:
                    pbar.set_description("Clustering..")
                case TaskStatus.FINISHED:
                    pbar.set_description("Finished clustering!")
                    break
                case TaskStatus.FAILED:
                    pbar.set_description("Clustering failed!")
                    break
        return pbar

    def get_tqdm_initial_description(self) -> str:
        return "Running clustering.."


class _PerplexityDTOHandler(DTOHandler):
    def handle_result(self, dtos: List[TaskDTO]):
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.FINISHED:
                return dto.perplexity_result

        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        for dto in dtos:
            status = dto.status
            match status:
                case TaskStatus.PENDING:
                    pbar.set_description("Waiting for perplexity task to start..")
                case TaskStatus.RUNNING:
                    pbar.set_description("Calculating perplexity..")
                case TaskStatus.FINISHED:
                    pbar.set_description("Finished calculating perplexity!")
                    break
                case TaskStatus.FAILED:
                    pbar.set_description("Calculating perplexity failed!")
                    break
        return pbar

    def get_tqdm_initial_description(self) -> str:
        return "Running perplexity calculation.."


class ProteinsClient(ClientInterface):
    def taxonomy(
            self, api_client: ApiClient, taxonomy_ids: List[int]
    ) -> Optional[List[TaxonomyItem]]:
        api_instance = ProteinsApi(api_client)
        taxonomy_request = TaxonomyRequest(taxonomy_ids=taxonomy_ids)

        try:
            # Retrieve taxonomy data
            taxonomy_response: TaxonomyResponse = (
                api_instance.taxonomy_api_v1_protein_service_taxonomy_post(
                    taxonomy_request
                )
            )
            return taxonomy_response.taxonomy
        except Exception as e:
            print(
                "Exception when calling ProteinsApi->taxonomy_api_v1_protein_service_taxonomy_post: %s\n"
                % e
            )
            return None

    def cluster(
            self,
            api_client: ApiClient,
            sequence_data: Dict[str, str],
            sequence_identity_threshold: float,
    ) -> BiocentralServerTask[Dict[str, List[str]]]:
        assert len(sequence_data) > 0, "No sequences provided"
        assert len(sequence_data.values()) == len(
            set(sequence_data.values())
        ), "Duplicate sequences provided"

        api_instance = ProteinsApi(api_client)
        clustering_request = ClusteringRequest(
            sequence_data=sequence_data,
            sequence_identity_threshold=sequence_identity_threshold,
        )
        task_id = self._submit_task(
            endpoint_caller=lambda: api_instance.trigger_protein_clustering_api_v1_protein_service_cluster_post(
                clustering_request
            )
        )

        cluster_dto_handler = _ClusterDTOHandler()
        biocentral_server_task = BiocentralServerTask(
            task_id=task_id, api_client=api_client, dto_handler=cluster_dto_handler
        )
        return biocentral_server_task

    def perplexity(
            self,
            api_client: ApiClient,
            sequence_data: Dict[str, str],
            plm_name: str,
    ) -> BiocentralServerTask[PerplexityResult]:
        assert len(sequence_data) > 0, "No sequences provided"
        assert len(sequence_data.values()) == len(
            set(sequence_data.values())
        ), "Duplicate sequences provided"

        api_instance = ProteinsApi(api_client)
        perplexity_request = PerplexityRequest(
            sequence_data=sequence_data,
            plm_name=plm_name,
        )
        task_id = self._submit_task(
            endpoint_caller=lambda: api_instance.trigger_protein_perplexity_api_v1_protein_service_perplexity_post(
                perplexity_request
            )
        )

        perplexity_dto_handler = _PerplexityDTOHandler()
        biocentral_server_task = BiocentralServerTask(
            task_id=task_id, api_client=api_client, dto_handler=perplexity_dto_handler
        )
        return biocentral_server_task
