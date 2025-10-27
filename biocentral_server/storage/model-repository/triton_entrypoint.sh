#!/bin/bash
# Triton Inference Server entrypoint script
# Reads initialized models and starts Triton with explicit model loading

set -euo pipefail

MODEL_REPO_PATH="${MODEL_REPOSITORY_PATH:-/models}"
SUCCESS_FILE="${MODEL_REPO_PATH}/.initialized_models"

echo "Starting Triton Inference Server..."
echo "Model repository path: ${MODEL_REPO_PATH}"

# Check if success file exists
if [[ ! -f "${SUCCESS_FILE}" ]]; then
    echo "ERROR: Model initialization file not found at ${SUCCESS_FILE}"
    echo "Make sure the triton-model-init container completed successfully"
    exit 1
fi

# Read initialized models
if [[ ! -s "${SUCCESS_FILE}" ]]; then
    echo "ERROR: No models were successfully initialized"
    echo "Check the triton-model-init container logs for errors"
    exit 1
fi

echo "Reading initialized models from ${SUCCESS_FILE}..."
INITIALIZED_MODELS=()
while IFS= read -r model; do
    if [[ -n "${model}" ]]; then
        INITIALIZED_MODELS+=("${model}")
    fi
done < "${SUCCESS_FILE}"

echo "Found ${#INITIALIZED_MODELS[@]} initialized models:"
for model in "${INITIALIZED_MODELS[@]}"; do
    echo "  - ${model}"
done

# Build --load-model flags
LOAD_MODEL_FLAGS=()
for model in "${INITIALIZED_MODELS[@]}"; do
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
