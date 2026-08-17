# Biocentral — PyCharm / IntelliJ Plugin

Bridges the [Biocentral](https://github.com/biocentral/biocentral) Python
ecosystem with PyCharm (and any IntelliJ-based IDE with the Python plugin).

**This Plugin is still under development and currently only serves as a Proof of Concept.**

## What it does

Once installed, opening any `.fasta` / `.fa` / `.faa` / `.fna` file inside a
project with a configured Python interpreter surfaces an editor banner with:

1. **Show Label / Length / Split Distribution** — invokes
   `BiocentralChart.label_distribution(...)` (and friends) against the file
   and renders the resulting Altair chart as HTML in a JCEF panel inside the
   Biocentral tool window.
2. **Embed Sequences…** — pops a small dialog, then runs
   `Biocentral(mode=…).embed(embedder_name, fasta_path, …)` and streams a
   compact summary (seq id, embedding shape, preview of the first values)
   into the tool window. The raw embedding JSON can be saved from the toolbar.

Both entry points respect per-project defaults saved in
_Settings → Tools → Biocentral_ (embedder, mode, API URL, device, reduce, half
precision).

## Design

The plugin is deliberately thin: all biology lives in the Python side, all UI
lives in the Java side, and the two communicate through a stable JSON envelope.

* **`src/main/resources/scripts/`** — the actual `biocentral` calls. Each
  script is a small, self-contained CLI:
    * `_bootstrap.py` — emits the shared `__BIOCENTRAL_RESULT__{...}` envelope
      that the Java side parses; also normalizes unhandled-exception reporting.
    * `render_chart.py` — dispatches to one of `BiocentralChart.<factory>`
      and saves the chart HTML to a file.
    * `embed_fasta.py` — runs `Biocentral(mode=...).embed(...)` and writes the
      full embedding payload as JSON.
    * `check_env.py` — reports which Biocentral packages are importable.
* **`com.biocentral.pycharm.python.BiocentralPythonRunner`** — resolves the
  project's Python SDK via the bundled Python plugin's
  [`PythonSdkUtil`](https://plugins.jetbrains.com/docs/intellij/idea-development-modules.html)
  (so virtualenvs, conda, poetry and remote targets are all handled by
  PyCharm's own SDK abstraction) and launches scripts via `GeneralCommandLine`
  — the same mechanism the Python plugin uses for one-shot script invocations.
  No hand-rolled subprocess management, no bundled Python.

Adding another action is a matter of dropping a new `.py` file next to the
existing scripts, registering it in `BiocentralScripts`, and wiring an
`AnAction` subclass in `plugin.xml`. The Java side never needs to know what
the script does; it just parses the envelope.

## Requirements

* PyCharm 2024.2+ (Community or Professional) **or** IntelliJ IDEA 2024.2+
  with the Python plugin installed.
* A project-level Python SDK with `biocentral` installed:
  * `pip install biocentral` — API mode (needs a running Biocentral server).
  * `pip install "biocentral[local]"` — local mode (runs Biotrainer in-process).

## Building the plugin

```bash
cd biocentral_plugins/jetbrains
./gradlew buildPlugin
```

The plugin ZIP lands in `build/distributions/biocentral-pycharm-<version>.zip`.

To iterate on the plugin against a real PyCharm sandbox:

```bash
./gradlew runIde
```

This spawns an isolated PyCharm Community instance with the plugin installed;
open a project there that has `biocentral` in its interpreter and open a
`.fasta` file.

## Installing

* From the plugin distribution ZIP:
  _Settings → Plugins → gear icon → Install Plugin from Disk…_
  Point at `build/distributions/biocentral-pycharm-<version>.zip`.

## Configuration

_Settings → Tools → Biocentral_ exposes the defaults used by every action:

| Setting            | Purpose                                                      |
|--------------------|--------------------------------------------------------------|
| Default embedder   | Any embedder name understood by Biocentral (e.g. `one_hot_encoding`, `Rostlab/prot_t5_xl_uniref50`). |
| Execution mode     | `api` (remote Biocentral server) or `local` (in-process).    |
| Custom API URL     | Overrides the default Biocentral API host (api mode).        |
| Device             | Passed to `Biocentral(mode="local", device=…)`.              |
| Reduce embeddings  | Mean-pool per sequence.                                      |
| Use half precision | Cast weights/activations to fp16 to save memory.             |

## Extending

To add a new chart type, extend `BiocentralChart` on the Python side (already
supported by the base plugin), then:

1. Add the new `<factory>` to the `CHART_RENDERERS` map in `render_chart.py`.
2. Add an `AnAction` subclass in `ShowChartAction`.
3. Register it in `plugin.xml`.

## Layout

```
biocentral_plugins/jetbrains/
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── gradle/wrapper/
├── gradlew, gradlew.bat
├── README.md
└── src/main/
    ├── java/com/biocentral/pycharm/
    │   ├── actions/        # AnAction implementations
    │   ├── fasta/          # File type + extension recognition
    │   ├── notification/   # Editor banner
    │   ├── python/         # SDK resolution + script runner
    │   ├── settings/       # Persistent state + settings UI
    │   └── ui/             # Tool window, chart / embedding panels
    └── resources/
        ├── META-INF/plugin.xml
        ├── icons/
        ├── messages/BiocentralBundle.properties
        └── scripts/        # Python scripts loaded from the classpath
```
