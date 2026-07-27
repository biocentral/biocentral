import os
import multiprocessing

from worker import run_worker as start_rq_worker
from dotenv import load_dotenv

from biocentral_server.main import run_server

# Load local environment variables
load_dotenv(".env")


def run_worker(worker_id):
    """Run a single worker process with a specific name"""
    # Use custom worker name to identify in monitoring
    worker_name = f"biocentral-worker-{worker_id}-{os.getpid()}"
    start_rq_worker(name=worker_name)


def start_workers(num_workers: int = 1):
    """Start multiple worker processes"""
    worker_processes = []
    for i in range(num_workers):
        process = multiprocessing.Process(
            target=run_worker, args=(i,), name=f"rq-worker-process-{i}"
        )
        process.start()
        worker_processes.append(process)
    return worker_processes


if __name__ == "__main__":
    num_workers = 1

    print(f"Starting {num_workers} RQ worker processes")
    worker_processes = start_workers(num_workers)

    try:
        # Run the server in the main process
        run_server()
    finally:
        # Ensure all workers are terminated when server stops
        print("Shutting down worker processes...")
        for process in worker_processes:
            process.terminate()
            process.join(timeout=2)  # Wait up to 2 seconds for each worker
            if process.is_alive():
                print(f"Force terminating worker {process.name}")
                os.kill(process.pid, 9)  # SIGKILL if still alive
