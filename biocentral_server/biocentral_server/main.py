import os

from pathlib import Path
from fastapi import FastAPI
from redis.asyncio import Redis
from importlib.metadata import version
from fastapi_limiter import FastAPILimiter
from contextlib import asynccontextmanager
from fastapi.responses import HTMLResponse
from apscheduler.triggers.cron import CronTrigger
from fastapi.middleware.cors import CORSMiddleware
from apscheduler.schedulers.background import BackgroundScheduler

from .predict import PredictInitializer
from .server_management import (
    ServerInitializationManager,
    BodySizeLimitMiddleware,
    UserManager,
    EmbeddingDatabaseFactory,
)

# Import module routers
from .ppi import router as ppi_router
from .predict import router as predict_router
from .bay_opt import router as bay_opt_router
from .proteins import router as proteins_router
from .custom_models import router as custom_models_router
from .embeddings import embeddings_router, projection_router
from .biocentral_service import router as biocentral_service_router

from .utils import str2bool, Constants, get_logger


def _setup_directories():
    required_directories = ["logs", "storage"]
    for directory in required_directories:
        if not os.path.exists(directory):
            os.makedirs(directory)


def cleanup_database_task():
    """Scheduled task to cleanup old embeddings"""
    logger = get_logger(__name__)

    try:
        logger.info("[SCHEDULED] Running database cleanup...")

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        db_stats_prior = embeddings_db.get_database_statistics()
        logger.info(f"[SCHEDULED] Database statistics before cleanup: {db_stats_prior}")

        # Cleanup embeddings older than 30 days
        n_removed_entries = embeddings_db.cleanup_database(older_than_days=30)

        logger.info(
            f"[SCHEDULED] Database cleanup completed. Removed {n_removed_entries} entries."
        )
        db_stats_post = embeddings_db.get_database_statistics()
        logger.info(f"[SCHEDULED] Database statistics after cleanup: {db_stats_post}")

    except Exception as e:
        logger.error(f"[SCHEDULED] Error during database cleanup: {e}", exc_info=True)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events"""
    # Startup
    debug = str2bool(str(os.environ.get("SERVER_DEBUG", "True")))

    # Rate Limiting
    redis_host = os.environ.get("REDIS_JOBS_HOST", "redis-jobs")
    redis_port = os.environ.get("REDIS_JOBS_PORT", 6379)
    redis_conn = Redis(host=redis_host, port=redis_port, db=1)
    if not debug:
        await FastAPILimiter.init(
            redis=redis_conn, identifier=UserManager.get_user_id_from_request
        )
    else:
        await FastAPILimiter.init(
            redis=redis_conn, identifier=UserManager.get_random_user_id
        )

    # Directories
    _setup_directories()

    logger = get_logger(__name__)
    # Initialize modules
    initialization_manager = ServerInitializationManager()
    initialization_manager.register_initializer(PredictInitializer())
    # initialization_manager.run_all()

    # Scheduled tasks
    # Start background scheduler
    scheduler = BackgroundScheduler()

    # Schedule cleanup task
    scheduler.add_job(
        cleanup_database_task,
        CronTrigger(hour=2, minute=0),  # Daily at 2:00 AM
        id="cleanup_database",
        name="Cleanup old embeddings",
        replace_existing=True,
    )

    scheduler.start()
    logger.info(f"Scheduled jobs: {scheduler.get_jobs()}")
    logger.info("Application startup complete.")

    yield

    # Shutdown
    logger.info("Shutting down application...")
    scheduler.shutdown()
    logger.info("Background scheduler stopped")
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
    app.include_router(biocentral_service_router, prefix=prefix)
    app.include_router(embeddings_router, prefix=prefix)
    app.include_router(projection_router, prefix=prefix)
    app.include_router(bay_opt_router, prefix=prefix)
    app.include_router(ppi_router, prefix=prefix)
    app.include_router(predict_router, prefix=prefix)
    app.include_router(custom_models_router, prefix=prefix)
    app.include_router(proteins_router, prefix=prefix)

    # Health check
    __version__ = version("biocentral-server")

    @app.get("/health")
    async def health_check():
        return {"status": "healthy", "version": __version__}

    # Landing page
    assets_dir = Path(os.environ.get("ASSETS_DIR", "assets/"))
    landing_file_content = None
    with open(assets_dir / "landing.html", "r") as landing_file:
        landing_file_content = landing_file.read()

    if landing_file_content is None or len(landing_file_content) == 0:
        raise Exception("Landing page file not found or is empty!")

    @app.get("/", include_in_schema=False)
    async def landing_page():
        return HTMLResponse(content=landing_file_content)

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
