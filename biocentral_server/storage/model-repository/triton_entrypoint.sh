#!/bin/bash
# Triton Inference Server entrypoint script
# Parses TRITON_MODELS_TO_LOAD and starts Triton with explicit model loading

set -euo pipefail

MODEL_REPO_PATH="${MODEL_REPOSITORY_PATH:-/models}"
TRITON_MODELS="${TRITON_MODELS:-}"

echo "Starting Triton Inference Server..."
echo "Model repository path: ${MODEL_REPO_PATH}"

# Check if models to load are specified
if [[ -z "${TRITON_MODELS}" ]]; then
    echo "ERROR: TRITON_MODELS environment variable must be set"
    echo "Example: TRITON_MODELS='esm2_t33_pipeline,bind_embed,prott5_sec'"
    exit 1
fi

# Parse comma-separated model list
echo "Parsing models to load: ${TRITON_MODELS}"
IFS=',' read -ra MODELS_TO_LOAD <<< "${TRITON_MODELS}"

# Trim whitespace from each model name
MODELS_TO_LOAD=()
for model in "${MODELS_TO_LOAD[@]}"; do
    model=$(echo "${model}" | xargs)  # trim whitespace
    if [[ -n "${model}" ]]; then
        MODELS_TO_LOAD+=("${model}")
    fi
done

if [[ ${#MODELS_TO_LOAD[@]} -eq 0 ]]; then
    echo "ERROR: No valid models specified in TRITON_MODELS"
    exit 1
fi

echo "Found ${#MODELS_TO_LOAD[@]} models to load:"
for model in "${MODELS_TO_LOAD[@]}"; do
    echo "  - ${model}"
done

# Build --load-model flags
LOAD_MODEL_FLAGS=()
for model in "${MODELS_TO_LOAD[@]}"; do
    LOAD_MODEL_FLAGS+=("--load-model=${model}")
done

# Default Triton arguments
TRITON_ARGS=(
    "--model-repository=${MODEL_REPO_PATH}"
    "--model-control-mode=explicit"
    "--strict-model-config=false"
    "--log-verbose=1"
    "--allow-grpc=true"
    "--allow-http=true"
    "--allow-metrics=true"
)

# Add load model flags
TRITON_ARGS+=("${LOAD_MODEL_FLAGS[@]}")

echo "Starting Triton with command:"
echo "tritonserver ${TRITON_ARGS[*]}"
echo ""

# Execute Triton
exec tritonserver "${TRITON_ARGS[@]}"
