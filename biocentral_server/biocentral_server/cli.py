import sys
import click
import subprocess
from pathlib import Path
from dotenv import load_dotenv
from tqdm import tqdm

# We need to add the project root to sys.path to import biocentral_server
project_root = Path(__file__).parent.parent
sys.path.append(str(project_root))


@click.group()
def cli():
    """Biocentral CLI tool for server management."""
    pass


@cli.group()
def server():
    """Server management commands."""
    pass


@server.command()
@click.option(
    "--mode",
    type=click.Choice(["dev", "local", "prod"], case_sensitive=False),
    default="prod",
    help="Run mode: dev (development with build), local (local development), or prod (production, default)",
)
def up(mode):
    """Start local server."""
    env_file = project_root / ".env"
    if not env_file.exists():
        click.echo(".env file not found. Copying from .env.example...")
        example_env = project_root / ".env.example"
        if example_env.exists():
            import shutil

            shutil.copy(example_env, env_file)
            click.echo("Created .env from .env.example. Please check the values.")
        else:
            click.echo("Error: .env.example not found. Cannot create .env.")
            sys.exit(1)

    # Load .env to get directory paths
    from dotenv import dotenv_values

    env_vars = dotenv_values(env_file)

    # Directories to check/create from .env
    dir_env_keys = [
        "EMBEDDINGS_DATA_DIR",
        "FILES_DATA_DIR",
        "SERVER_TEMP_DATA_DIR",
        "MODEL_REPOSITORY_PATH",
        "HUGGINGFACE_MODELS_DIR",
        "REDIS_DATA_DIR",
    ]

    # Also include these by default if not in .env (though they should be)
    default_dirs = ["logs", "models"]

    dirs_to_check = []
    for key in dir_env_keys:
        val = env_vars.get(key)
        if val:
            dirs_to_check.append((key, val))

    for d in default_dirs:
        dirs_to_check.append((d.upper(), d))

    for key, d in dirs_to_check:
        # Expand ~ and handle absolute/relative paths
        path = Path(d).expanduser()
        if not path.is_absolute():
            path = project_root / path

        if not path.exists():
            if click.confirm(
                f"Directory {d} (from {key}) does not exist. Create it?", default=True
            ):
                path.mkdir(parents=True, exist_ok=True)
                click.echo(f"Created {path}")
        else:
            click.echo(f"Using {path}..")

    if mode == "dev":
        click.echo("Starting server in dev mode via docker compose...")
        # docker compose --profile app up --build --pull never
        cmd = [
            "docker",
            "compose",
            "--profile",
            "app",
            "up",
            "-d",
            "--build",
            "--pull",
            "never",
        ]  # Local build
    elif mode == "local":
        click.echo(
            "Starting server dependencies via docker compose (run server script locally!)..."
        )
        cmd = ["docker", "compose", "up", "-d"]  # Local (run server via script)
    else:  # prod
        click.echo("Starting server in production mode via docker compose...")
        cmd = [
            "docker",
            "compose",
            "-f",
            "docker-compose.yml",
            "up",
            "-d",
        ]  # Production (regular compose file)

    try:
        subprocess.run(cmd, check=True, cwd=str(project_root))
        click.echo("Server is starting up.")
    except subprocess.CalledProcessError as e:
        click.echo(f"Error starting server: {e}")
        sys.exit(1)


@server.command()
def down():
    """Shut down local server."""
    click.echo("Shutting down server...")
    try:
        # We use --profile app just in case it was started with it, it doesn't hurt if it wasn't
        subprocess.run(
            ["docker", "compose", "--profile", "app", "down"],
            check=True,
            cwd=str(project_root),
        )
        click.echo("Server shut down.")
    except subprocess.CalledProcessError as e:
        click.echo(f"Error shutting down server: {e}")
        sys.exit(1)


@server.command()
@click.option(
    "--h5", required=True, type=click.Path(exists=True), help="Path to h5 file"
)
@click.option(
    "--keep/--no-keep",
    default=True,
    help="Whether to keep the embeddings during cleanup (default: True)",
)
def snack(h5, keep):
    from biotrainer_core.h5_files import read_h5_db
    from biocentral_server.server_management import EmbeddingDatabaseFactory

    """'Snack' an h5 file and add it to the database."""
    load_dotenv(project_root / ".env")

    db_factory = EmbeddingDatabaseFactory()
    try:
        db = db_factory.get_embeddings_db()
    except Exception as e:
        click.echo(f"Error connecting to database: {e}. Is the server running?")
        sys.exit(1)

    click.echo(f"Reading embeddings from {h5}...")
    try:
        embd_dtos = []
        for embd_dto in tqdm(read_h5_db(h5), desc="Reading h5"):
            embd_dto = embd_dto.copy_with(keep=keep if keep else embd_dto.keep)
            embd_dtos.append(embd_dto)
    except Exception as e:
        click.echo(f"Error reading h5 file: {e}")
        sys.exit(1)

    click.echo("Saving embeddings to database...")

    db.snack_embeddings(embd_dtos)

    click.echo("Done.")


@server.command()
@click.option("--output", "-o", default="database_dump.h5", help="Output h5 file path")
def dump(output):
    from biotrainer_core.h5_files import write_h5_db
    from biocentral_server.server_management import EmbeddingDatabaseFactory

    """Dump all database information to an h5 file."""
    load_dotenv(project_root / ".env")

    db_factory = EmbeddingDatabaseFactory()
    try:
        db = db_factory.get_embeddings_db()
    except Exception as e:
        click.echo(f"Error connecting to database: {e}. Is the server running?")
        sys.exit(1)

    click.echo(f"Dumping database to {output}...")
    try:
        embd_dtos = []
        for embd_dto in tqdm(
            db.get_all_embeddings(), desc="Loading embeddings from database.."
        ):
            embd_dtos.append(embd_dto)
        total_count = 0
        for count in tqdm(
            write_h5_db(output, embd_dtos), total=len(embd_dtos), desc="Writing h5.."
        ):
            total_count = count
        if total_count != len(embd_dtos):
            raise Exception(
                f"Total count ({total_count}) does not match number of embeddings ({len(embd_dtos)})"
            )

        click.echo(f"Successfully dumped {total_count} embeddings to {output}!")

    except Exception as e:
        click.echo(f"Error dumping database: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)


@server.command()
def stats():
    from biocentral_server.server_management import EmbeddingDatabaseFactory

    """Show server stats."""
    load_dotenv(project_root / ".env")

    db_factory = EmbeddingDatabaseFactory()
    try:
        db = db_factory.get_embeddings_db()
    except Exception as e:
        click.echo(f"Error connecting to database: {e}. Is the server running?")
        sys.exit(1)

    try:
        statistics = db.get_database_statistics()
        if not statistics:
            click.echo("No statistics available. Is the database running?")
            return

        click.echo("--- Database Statistics ---")
        for key, value in statistics.items():
            click.echo(f"{key.replace('_', ' ').capitalize()}: {value}")
    except Exception as e:
        click.echo(f"Error fetching statistics: {e}")
        sys.exit(1)


if __name__ == "__main__":
    cli()
