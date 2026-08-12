import sys
import click

from typing import Optional

from ..biocentral import Biocentral, BiocentralAPI


@click.group()
def biocentral():
    """Biocentral CLI - unified access to the biocentral ecosystem."""
    pass


def _make_biocentral_object(mode: str, server_url: Optional[str] = None, device: Optional[str] = None):
    if mode == "api":
        custom_api = None
        if server_url is not None:
            custom_api = BiocentralAPI(fixed_server_url=server_url)
        return Biocentral(mode=mode, custom_api=custom_api)
    elif mode == "local":
        if server_url is not None:
            print("WARNING: Custom server URL is ignored in local mode.")
        return Biocentral(mode=mode, device=device)
    else:
        raise ValueError(f"Invalid mode: {mode}")


@biocentral.command()
@click.argument("fasta_path", type=click.Path(exists=True))
@click.option(
    "--embedder", required=True, help="Embedder name (e.g. Rostlab/prot_t5_xl_uniref50)"
)
@click.option(
    "--mode", type=click.Choice(["api", "local"]), default="api", help="Execution mode"
)
@click.option("--server-url", default=None, help="Custom server URL (api mode)")
@click.option(
    "--device", default=None, help="Device for local computation (e.g. cuda, cpu)"
)
@click.option(
    "--reduce", is_flag=True, help="Reduce embeddings to per-sequence"
)
@click.option("--output", "-o", default=None, help="Output h5 file path")
def embed(fasta_path, embedder, mode, server_url, device, reduce, output):
    """Compute embeddings for sequences in a FASTA file."""
    bc = _make_biocentral_object(mode=mode, server_url=server_url, device=device)
    result = bc.embed(embedder, fasta_path, reduce=reduce)

    if output:
        result.save(output)
        click.echo(f"Embeddings saved to {output}")
    else:
        id2emb = result.to_dict()
        click.echo(
            f"Computed {len(id2emb)} embeddings (shape: {next(iter(id2emb.values())).shape})"
        )


@biocentral.command()
@click.argument("config_path", type=click.Path(exists=True))
@click.option(
    "--mode", type=click.Choice(["api", "local"]), default="api", help="Execution mode"
)
@click.option("--server-url", default=None, help="Custom server URL (api mode)")
@click.option(
    "--device", default=None, help="Device for local computation (e.g. cuda, cpu)"
)
def train(config_path, mode, server_url, device):
    """Train a model using a biotrainer configuration file."""
    from ruamel import yaml

    with open(config_path, "r") as f:
        config = yaml.load(f, Loader=yaml.RoundTripLoader)

    # Extract input_data from config if present
    input_data = None
    input_file = config.get("input_file")
    if input_file:
        from biotrainer_core.input_files import read_FASTA

        input_data = list(read_FASTA(input_file))

    if input_data is None:
        click.echo("Error: No input data found. Provide 'input_file' in the config.")
        sys.exit(1)

    bc = _make_biocentral_object(mode=mode, server_url=server_url, device=device)
    result = bc.train(dict(config), input_data)

    model_hash = None
    if result.derived_values and result.derived_values.model_hash:
        model_hash = result.derived_values.model_hash

    click.echo(f"Training complete. Model hash: {model_hash}")


@biocentral.command()
@click.argument("model_hash")
@click.argument("fasta_path", type=click.Path(exists=True))
@click.option(
    "--mode", type=click.Choice(["api", "local"]), default="api", help="Execution mode"
)
@click.option("--server-url", default=None, help="Custom server URL (api mode)")
@click.option(
    "--device", default=None, help="Device for local computation (e.g. cuda, cpu)"
)
def inference(model_hash, fasta_path, mode, server_url, device):
    """Run inference on a trained model using its hash."""
    bc = _make_biocentral_object(mode=mode, server_url=server_url, device=device)
    result = bc.inference(model_hash, fasta_path)

    for prediction in result.predictions:
        click.echo(f"{prediction.seq_id}: {prediction}")


@biocentral.command()
@click.argument("fasta_path", type=click.Path(exists=True))
@click.option(
    "--model",
    "model_names",
    required=True,
    multiple=True,
    help="Pre-trained model name(s)",
)
@click.option("--server-url", default=None, help="Custom server URL")
def predict(fasta_path, model_names, server_url):
    """Predict using pre-trained server-hosted models (API only)."""
    bc = _make_biocentral_object(mode="api", server_url=server_url)
    result = bc.predict(list(model_names), fasta_path)

    for model_name, predictions in result.items():
        click.echo(f"\n--- {model_name} ---")
        for pred in predictions:
            click.echo(f"  {pred}")


@biocentral.group()
def server():
    """Server management commands (requires biocentral[server])."""
    pass


@server.command()
@click.option(
    "--mode",
    type=click.Choice(["dev", "local", "prod"]),
    default="prod",
    help="Run mode: dev, local, or prod (default)",
)
def up(mode):
    """Start the biocentral server."""
    try:
        from .server_cli import server as server_cli

        ctx = click.Context(server_cli)
        ctx.invoke(server_cli.commands["up"], mode=mode)
    except ImportError:
        click.echo(
            "Server management requires biocentral_server. Install with: pip install biocentral[server]"
        )
        sys.exit(1)


@server.command()
def down():
    """Shut down the biocentral server."""
    try:
        from .server_cli import server as server_cli

        ctx = click.Context(server_cli)
        ctx.invoke(server_cli.commands["down"])
    except ImportError:
        click.echo(
            "Server management requires biocentral_server. Install with: pip install biocentral[server]"
        )
        sys.exit(1)


@server.command()
@click.argument("h5", type=click.Path(exists=True))
@click.option(
    "--keep/--no-keep",
    default=True,
    help="Whether to keep the embeddings during cleanup (default: True)",
)
def snack(h5, keep):
    """'Snack' an h5 file and add it to the database."""
    try:
        from .server_cli import server as server_cli

        ctx = click.Context(server_cli)
        ctx.invoke(server_cli.commands["snack"], h5=h5, keep=keep)
    except ImportError:
        click.echo(
            "Server management requires biocentral_server. Install with: pip install biocentral[server]"
        )
        sys.exit(1)


@server.command()
@click.option("--output", "-o", default="database_dump.h5", help="Output h5 file path")
def dump(output):
    """Dump all database information to an h5 file."""
    try:
        from .server_cli import server as server_cli

        ctx = click.Context(server_cli)
        ctx.invoke(server_cli.commands["dump"], output=output)
    except ImportError:
        click.echo(
            "Server management requires biocentral_server. Install with: pip install biocentral[server]"
        )
        sys.exit(1)


@server.command()
def stats():
    """Show server stats."""
    try:
        from .server_cli import server as server_cli

        ctx = click.Context(server_cli)
        ctx.invoke(server_cli.commands["stats"])
    except ImportError:
        click.echo(
            "Server management requires biocentral_server. Install with: pip install biocentral[server]"
        )
        sys.exit(1)


@server.command()
@click.option(
    "--interactive", is_flag=True, help="Interactive mode (next/previous error)"
)
def errors(interactive):
    """Analyze errors in logs."""
    try:
        from .server_cli import server as server_cli

        ctx = click.Context(server_cli)
        ctx.invoke(server_cli.commands["errors"], interactive=interactive)
    except ImportError:
        click.echo(
            "Server management requires biocentral_server. Install with: pip install biocentral[server]"
        )
        sys.exit(1)

if __name__ == "__main__":
    biocentral()
