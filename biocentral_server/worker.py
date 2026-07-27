def run_worker(name: str = None, queues: list = None):
    import os

    from rq import Worker
    from redis import Redis

    redis_jobs_host = os.environ.get("REDIS_JOBS_HOST", "redis-jobs")
    redis_jobs_port = int(os.environ.get("REDIS_JOBS_PORT", 6379))
    redis_conn = Redis(host=redis_jobs_host, port=redis_jobs_port, db=0)

    # Register Triton cleanup on worker shutdown
    import atexit
    from biocentral_server.server_management import cleanup_repositories

    atexit.register(cleanup_repositories)

    # Provide the worker with the list of queues (str) to listen to.
    # The docker-compose uses 'high', 'default', 'low'
    if queues is None:
        queues = os.environ.get("RQ_QUEUES", "high default low").split()

    # Preload heavy libraries to reduce fork overhead
    from biocentral_server.utils import get_logger

    logger = get_logger(__name__)
    logger.info("Preloading heavy libraries...")
    # Add other heavy imports if identified
    logger.info("Preloading complete.")

    # Use SimpleWorker for local/preloaded environments to avoid fork overhead if requested
    worker = Worker(
        queues=queues,
        connection=redis_conn,
        name=name,
        worker_ttl=600,
        default_result_ttl=600,
        job_monitoring_interval=2,
    )

    if name:
        logger.info(f"Starting worker {name} listening on queues: {queues}")
    else:
        logger.info(f"Starting worker listening on queues: {queues}")

    worker.work()


if __name__ == "__main__":
    run_worker()
