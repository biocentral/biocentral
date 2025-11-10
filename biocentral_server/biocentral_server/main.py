import os

from fastapi import FastAPI
from redis.asyncio import Redis
from fastapi_limiter import FastAPILimiter
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest
from fastapi.responses import Response

from .predict import PredictInitializer
from .server_management import (
    ServerInitializationManager,
    BodySizeLimitMiddleware,
    UserManager,
)

# Import module routers
from .ppi import router as ppi_router
from .embeddings import embeddings_router
from .predict import router as predict_router
from .bay_opt import router as bay_opt_router
from .plm_eval import router as plm_eval_router
from .proteins import router as proteins_router
from .biocentral import router as biocentral_router
from .custom_models import router as custom_models_router

from .utils import str2bool, Constants


def _setup_directories():
    required_directories = ["logs", "storage"]
    for directory in required_directories:
        if not os.path.exists(directory):
            os.makedirs(directory)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events"""
    # Startup

    # Rate Limiting
    redis_host = os.environ.get("REDIS_JOBS_HOST", "redis-jobs")
    redis_port = os.environ.get("REDIS_JOBS_PORT", 6379)
    redis_conn = Redis(host=redis_host, port=redis_port, db=0)
    await FastAPILimiter.init(
        redis=redis_conn, identifier=UserManager.get_user_id_from_request
    )

    # Directories
    _setup_directories()
    # Initialize modules
    initialization_manager = ServerInitializationManager()
    initialization_manager.register_initializer(PredictInitializer())
    # initialization_manager.run_all()

    yield

    # Shutdown
    await FastAPILimiter.close()


def create_app() -> FastAPI:
    """Create and configure FastAPI application"""
    app = FastAPI(
        title="Biocentral Server",
        description="API for biocentral services",
        version="1.0.0",
        lifespan=lifespan,
    )

    # Add middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=[
            "Content-Type",
            "Access-Control-Allow-Headers",
            "Authorization",
            "X-Requested-With",
        ],
    )
    app.add_middleware(BodySizeLimitMiddleware)

    # Include module routers
    prefix = "/api/v1"
    app.include_router(biocentral_router, prefix=prefix)
    app.include_router(embeddings_router, prefix=prefix)
    app.include_router(bay_opt_router, prefix=prefix)
    app.include_router(plm_eval_router, prefix=prefix)
    app.include_router(ppi_router, prefix=prefix)
    app.include_router(predict_router, prefix=prefix)
    app.include_router(custom_models_router, prefix=prefix)
    app.include_router(proteins_router, prefix=prefix)

    # Health check
    @app.get("/health")
    async def health_check():
        return {"status": "healthy"}

    # Prometheus metrics
    instrumentator = Instrumentator(
        should_group_status_codes=False,
        should_ignore_untemplated=True,
        should_respect_env_var=True,
        should_instrument_requests_inprogress=True,
        excluded_handlers=["/metrics", "/health"],
        env_var_name="ENABLE_METRICS",
        inprogress_name="http_requests_inprogress",
        inprogress_labels=True,
    )
    instrumentator.instrument(app).expose(app)

    @app.get("/metrics")
    async def metrics():
        return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)

    return app


app = create_app()


def run_server():
    """Run the server"""
    debug = str2bool(str(os.environ.get("SERVER_DEBUG", "True")))

    import uvicorn

    if debug:
        uvicorn.run(
            "biocentral_server.main:app",
            host="0.0.0.0",
            port=Constants.SERVER_DEFAULT_PORT,
            reload=True,
            log_level="info",
        )
    else:
        # For production
        uvicorn.run(
            app, host="0.0.0.0", port=Constants.SERVER_DEFAULT_PORT, log_level="info"
        )


if __name__ == "__main__":
    run_server()
