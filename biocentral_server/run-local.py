import multiprocessing

from rq import Worker
from redis import Redis
from dotenv import load_dotenv

# Load local environment variables
load_dotenv('.env.local')

def run_server():
    from biocentral_server.server_entrypoint import AppState
    app_state = AppState.get_instance()
    app = app_state.init_app()
    app_state.init_app_context()
    app.run(debug=True, port=9540)

def run_worker():
    redis_conn = Redis(host='localhost', port=6379)
    worker = Worker(['high', 'default', 'low'], connection=redis_conn)
    worker.work()

if __name__ == '__main__':
    # Start the worker process
    worker_process = multiprocessing.Process(target=run_worker)
    worker_process.start()

    try:
        # Run the server in the main process
        run_server()
    finally:
        # Ensure worker is terminated when server stops
        worker_process.terminate()
        worker_process.join()
