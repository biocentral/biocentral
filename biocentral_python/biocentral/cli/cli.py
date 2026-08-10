import sys
import click

from .biocentral import Biocentral


@click.group()
def biocentral():
    """Biocentral CLI - unified access to the biocentral ecosystem."""
    pass


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
    "--no-reduce", is_flag=True, help="Do not reduce embeddings to per-sequence"
)
@click.option("--output", "-o", default=None, help="Output h5 file path")
def embed(fasta_path, embedder, mode, server_url, device, no_reduce, output):
    """Compute embeddings for sequences in a FASTA file."""
    bc = Biocentral(mode=mode, server_url=server_url, device=device)
    result = bc.embed(embedder, fasta_path, reduce=not no_reduce)

    if output:
        result.save(output)
        click.echo(f"Embeddings saved to {output}")
    else:
        id2emb = result.get_embeddings()
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

    bc = Biocentral(mode=mode, server_url=server_url, device=device)
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
    bc = Biocentral(mode=mode, server_url=server_url, device=device)
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
    bc = Biocentral(mode="api", server_url=server_url)
    result = bc.predict(list(model_names), fasta_path)

    for model_name, predictions in result.items():
        click.echo(f"\n--- {model_name} ---")
        for pred in predictions:
            click.echo(f"  {pred.seq_id}: {pred}")


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
        from biocentral_server.cli import server as server_cli

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
        from biocentral_server.cli import server as server_cli

        ctx = click.Context(server_cli)
        ctx.invoke(server_cli.commands["down"])
    except ImportError:
        click.echo(
            "Server management requires biocentral_server. Install with: pip install biocentral[server]"
        )
        sys.exit(1)


if __name__ == "__main__":
    biocentral()
