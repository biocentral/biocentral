from fastapi import APIRouter, Depends, Request, HTTPException
from fastapi_limiter.depends import RateLimiter

from .taxonomy import Taxonomy
from .endpoint_models import TaxonomyResponse, TaxonomyRequest, TaxonomyItem, ClusteringRequest
from .proteins_task import ClusterSequencesTask  

from ..server_management import ErrorResponse, NotFoundErrorResponse, TaskManager, UserManager, StartTaskResponse
from ..utils import get_logger

logger = get_logger(__name__)

router = APIRouter(
    prefix="/protein_service",
    tags=["proteins"],
    responses={404: {"model": NotFoundErrorResponse}},
)


# Endpoint to get taxonomy data (taxon name and family name from taxonomy id)
@router.post(
    "/taxonomy/",
    response_model=TaxonomyResponse,
    responses={400: {"model": ErrorResponse}},
    summary="Retrieve taxonomy data",
    description="Retrieve taxonomy data for a list of taxonomy ids",
    dependencies=[Depends(RateLimiter(times=20, seconds=60))],
)
def taxonomy(taxonomy_request: TaxonomyRequest):
    taxonomy_ids = taxonomy_request.taxonomy_ids

    taxonomy_list = []
    taxonomy_object = Taxonomy()
    for taxonomy_id in taxonomy_ids:
        name = ""
        family = ""
        try:
            name = taxonomy_object.get_name_from_id(int(taxonomy_id))
            family = taxonomy_object.get_family_from_id(int(taxonomy_id))
        except Exception:
            logger.warning(f"Unknown taxonomy id: {taxonomy_id}")
        taxonomy_list.append(
            TaxonomyItem(taxonomy_id=taxonomy_id, name=name, family=family)
        )

    return TaxonomyResponse(taxonomy=taxonomy_list)


@router.post("/cluster/")
async def trigger_protein_clustering(payload: ClusteringRequest, request: Request):
    try:
        task_instance = ClusterSequencesTask(
            sequence_data=payload.sequence_data,  
            sequence_identity_threshold=payload.sequence_identity_threshold,
        )
        
        user_id = await UserManager.get_user_id_from_request(req=request)
        
        task_manager = TaskManager()
        task_id = task_manager.add_task(task=task_instance, user_id=user_id)
        
        return StartTaskResponse(task_id=task_id)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to submit background cluster task: {str(e)}")
    