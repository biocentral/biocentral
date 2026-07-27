import sys
import click
import subprocess
import re
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


def _copy_initial_content_if_empty(env_vars, env_key, source_subpath, project_root):
    """Check if a directory specified by an env variable is empty and prompt to copy initial content."""
    dir_val = env_vars.get(env_key)
    if not dir_val:
        return

    dir_path = Path(dir_val).expanduser()
    if not dir_path.is_absolute():
        dir_path = project_root / dir_path

    if dir_path.exists() and not any(dir_path.iterdir()):
        source_path = project_root / source_subpath
        if source_path.exists() and any(source_path.iterdir()):
            if click.confirm(
                f"{env_key} ({dir_path}) is empty. Copy initial content from ./{source_subpath}/?",
                default=True,
            ):
                try:
                    subprocess.run(
                        ["cp", "-r", f"{source_path}/*", str(dir_path)],
                        shell=True,
                        check=True,
                        cwd=str(project_root),
                    )
                    click.echo(f"Copied initial content to {dir_path}")
                except subprocess.CalledProcessError as e:
                    click.echo(f"Error copying content: {e}")


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
        "ASSETS_DIR",
    ]

    dirs_to_check = []
    for key in dir_env_keys:
        val = env_vars.get(key)
        if val:
            dirs_to_check.append((key, val))

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

    for key, d in dirs_to_check:
        if key in ["MODEL_REPOSITORY_PATH", "ASSETS_DIR"]:
            _copy_initial_content_if_empty(env_vars, key, d, project_root)

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


@server.command()
@click.option(
    "--interactive", is_flag=True, help="Interactive mode (next/previous error)"
)
def errors(interactive):
    """Analyze errors in logs."""
    error_list = []

    # 1. Collect from docker compose logs
    click.echo("Collecting logs from docker compose...")
    try:
        # We try to get logs for biocentral-server and biocentral-worker
        result = subprocess.run(
            [
                "docker",
                "compose",
                "logs",
                "biocentral-server",
                "biocentral-worker",
                "--no-color",
                "--timestamps",
            ],
            capture_output=True,
            text=True,
            cwd=str(project_root),
        )
        if result.returncode == 0:
            error_list.extend(_parse_logs(result.stdout, "docker"))
    except Exception as e:
        click.echo(f"Warning: Could not collect docker logs: {e}")

    # 2. Collect from ./logs directory
    logs_dir = project_root / "logs"
    if logs_dir.exists():
        click.echo("Collecting logs from ./logs directory...")
        for log_file in logs_dir.glob("*.log"):
            try:
                content = log_file.read_text()
                error_list.extend(_parse_logs(content, str(log_file.name)))
            except Exception as e:
                click.echo(f"Warning: Could not read {log_file.name}: {e}")

    if not error_list:
        click.echo("No errors found.")
        return

    # Deduplicate
    unique_errors = _deduplicate_errors(error_list)
    # Sort by timestamp
    unique_errors.sort(key=lambda x: x["timestamp"] or "", reverse=True)

    if interactive:
        _interactive_mode(unique_errors)
    else:
        for err in unique_errors:
            click.echo("-" * 40)
            click.echo(f"Timestamp: {err['timestamp']}")
            click.echo(f"Source: {err['source']}")
            click.echo(f"Message: {err['message']}")
            if err["context"]:
                click.echo("Context:")
                click.echo(err["context"])


def _parse_logs(content, source):
    errors = []
    lines = content.splitlines()

    # Simple regex to match timestamps and ERROR level
    # Format 1 (Docker with --timestamps): 2026-06-12T13:45:01.123456789Z message
    # Format 2 (File): 2026-05-13 16:33:36,937 ERROR ...

    current_error = None

    for line in lines:
        # Check for new error start
        # File format: 2026-05-13 16:33:36,937 ERROR
        file_match = re.match(
            r"^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}) ERROR (.*)", line
        )
        # Docker format: 2026-06-12T13:45:01.123456789Z biocentral-server-1 | 2026-06-12 13:45:01,123 ERROR ...
        # Or just Docker timestamp: 2026-06-12T13:45:01.123456789Z ERROR ...
        docker_match = re.match(
            r"^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z) (.*ERROR.*)", line
        )

        if file_match:
            if current_error:
                errors.append(current_error)
            current_error = {
                "timestamp": file_match.group(1),
                "message": file_match.group(2),
                "context": "",
                "source": source,
            }
        elif docker_match:
            if current_error:
                errors.append(current_error)
            current_error = {
                "timestamp": docker_match.group(1),
                "message": docker_match.group(2),
                "context": "",
                "source": source,
            }
        elif current_error:
            # Check if this line is part of a traceback or just a message continuation
            if (
                line.strip() == ""
                or line.startswith(" ")
                or line.startswith("\t")
                or "Traceback" in line
                or line.startswith("  File")
            ):
                current_error["context"] += line + "\n"
            else:
                # If it doesn't look like context and we encounter a new timestamp/INFO/WARNING,
                # we might be at the end of the error.
                if re.match(r"^(\d{4}-\d{2}-\d{2})", line):
                    errors.append(current_error)
                    current_error = None
                else:
                    current_error["context"] += line + "\n"

    if current_error:
        errors.append(current_error)

    return errors


def _deduplicate_errors(errors):
    seen = set()
    deduped = []
    for err in errors:
        # Deduplicate based on message and context (stripping some variable parts if needed)
        # For now, exact match on message and context
        key = (err["message"], err["context"])
        if key not in seen:
            seen.add(key)
            deduped.append(err)
    return deduped


def _interactive_mode(errors):
    idx = 0
    total = len(errors)

    while True:
        err = errors[idx]
        click.clear()

        # Header with navigation info
        click.secho(f"Error {idx + 1} of {total}", fg="cyan", bold=True)
        click.echo("-" * 40)

        # Error Details
        click.echo(f"Timestamp: {err['timestamp']}")
        click.echo(f"Source:    {err['source']}")
        click.secho(f"Message:   {err['message']}", fg="red", bold=True)

        if err["context"]:
            click.echo("\nContext:")
            # Strip trailing/leading whitespace from context for cleaner display
            click.echo(err["context"].strip())

        click.echo("-" * 40)
        # Commands
        nav_hint = []
        if idx > 0:
            nav_hint.append("[p]revious")
        if idx < total - 1:
            nav_hint.append("[n]ext")
        nav_hint.append("[q]uit")

        click.secho(f"Commands: {', '.join(nav_hint)}", fg="bright_white")

        char = click.getchar()
        if char.lower() == "n" and idx < total - 1:
            idx += 1
        elif char.lower() == "p" and idx > 0:
            idx -= 1
        elif char.lower() == "q":
            click.clear()
            break


if __name__ == "__main__":
    cli()
