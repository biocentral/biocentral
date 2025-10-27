# Triton Model Repository Setup

This directory contains the Triton model repository structure for serving ONNX models with dynamic initialization.

## Directory Structure

Each model follows this structure:
```
model_name/
├── config.pbtxt          # Triton model configuration
└── 1/                    # Version 1
    └── model.onnx        # ONNX model file
```

## Required Models

The following models can be initialized:

### Embedding Models (3)
1. `prot_t5_pipeline` - ProtT5 tokenizer + ONNX ensemble
2. `esm2_t33_pipeline` - ESM2-t33 tokenizer + ONNX ensemble
3. `esm2_t36_pipeline` - ESM2-t36 tokenizer + ONNX ensemble

### Prediction Models (9)
4. `prott5_sec` - Secondary structure prediction
5. `prott5_cons` - Conservation prediction
6. `bind_embed` - Binding site prediction ensemble
7. `seth` - Disorder prediction (standalone)
8. `tmbed` - Transmembrane prediction
9. `light_attention_subcell` - Subcellular localization
10. `light_attention_membrane` - Membrane localization
11. `vespag` - Variant effect prediction

### Internal Models (6)
12. `_internal_prott5_tokenizer` - ProtT5 tokenizer only
13. `_internal_prott5_onnx` - ProtT5 ONNX only
14. `_internal_esm2_tokenizer` - ESM2 tokenizer only
15. `_internal_esm2_t33_onnx` - ESM2-t33 ONNX only
16. `_internal_esm2_t36_onnx` - ESM2-t36 ONNX only

## Dynamic Model Initialization

The system uses an initialization container pattern to download models from URLs and configure Triton to load only successfully initialized models.

### Environment Configuration

Set these environment variables to configure model downloads:

```bash
# Model names (space-separated)
MODEL_NAMES="esm2_t33_pipeline prott5_sec bind_embed"

# Corresponding download URLs (space-separated, same order)
MODEL_URLS="https://example.com/models/esm2_t33.onnx https://example.com/models/prott5_sec.onnx https://example.com/models/bind_embed.onnx"
```

### Docker Compose Usage

```bash
# Set environment variables
export MODEL_NAMES="esm2_t33_pipeline prott5_sec"
export MODEL_URLS="https://example.com/models/esm2_t33.onnx https://example.com/models/prott5_sec.onnx"

# Start services (init container runs first, then Triton)
docker compose up triton
```

### Manual Initialization

```bash
# Run init container manually
docker compose run triton-model-init

# Check what was initialized
cat storage/model-repository/.initialized_models
```

## Initialization Container

The `init_models.py` script runs in an init container to:
1. Parse MODEL_NAMES and MODEL_URLS environment variables
2. Download ONNX models from URLs with progress tracking
3. Validate downloaded files (size, ONNX format)
4. Write success state file for Triton startup
5. Fail container if any download fails

**Environment Variables**:
- `MODEL_REPOSITORY_PATH`: Path to model repository (default: `/models`)
- `MODEL_NAMES`: Space-separated list of model names to initialize
- `MODEL_URLS`: Space-separated list of download URLs (parallel to MODEL_NAMES)

## Testing the Repository

### Verify Initialization

```bash
# Check which models were initialized
cat storage/model-repository/.initialized_models

# Check ONNX files exist
find storage/model-repository -name "model.onnx" -exec ls -lh {} \;
```

### Start Triton

```bash
# Set environment variables for testing
export MODEL_NAMES="esm2_t33_pipeline prott5_sec"
export MODEL_URLS="https://example.com/models/esm2_t33.onnx https://example.com/models/prott5_sec.onnx"

# Start Triton with init container
docker compose up triton

# Check logs
docker compose logs triton-model-init
docker compose logs triton

# Verify models loaded
curl http://localhost:8000/v2/models | jq '.[] | .name'
```

### Test Model Inference

```bash
# Check specific model
curl http://localhost:8000/v2/models/esm2_t33_pipeline

# Run test predictions
TRITON_GRPC_URL=localhost:8001 uv run pytest tests/integration/triton_standalone/ -v
```

## Troubleshooting

### Init container fails

```bash
# Check init container logs
docker compose logs triton-model-init

# Common issues:
# - Invalid URLs (404, timeout)
# - Invalid ONNX files (wrong format)
# - Missing environment variables
```

### Triton fails to start

```bash
# Check Triton logs
docker compose logs triton

# Check if success file exists
docker compose exec triton cat /models/.initialized_models

# Verify entrypoint script
docker compose exec triton ls -la /usr/local/bin/triton_entrypoint.sh
```

### No models loaded

```bash
# Check if any models were initialized
docker compose exec triton cat /models/.initialized_models

# If empty, check init container logs for download failures
docker compose logs triton-model-init
```

### Model download issues

```bash
# Test URL accessibility
curl -I https://example.com/models/esm2_t33.onnx

# Check file size and format
curl -s https://example.com/models/esm2_t33.onnx | head -c 8 | xxd
# Should show ONNX magic bytes: 4f 4e 4e 58 (ONNX)
```

## Runtime Model Availability

The system includes runtime checking to verify which models are actually available in Triton:

```python
from biocentral_server.server_management.triton_client.model_router import TritonModelRouter

# Check if a model is available at runtime
is_available = await TritonModelRouter.is_triton_embedding_available_runtime("esm2_t33")
print(f"ESM2-t33 available: {is_available}")

# Get all available models
available_embeddings = await TritonModelRouter.get_available_embedding_models()
print(f"Available embeddings: {available_embeddings}")
```

## Model Files Not Included

⚠️ **Note**: ONNX model files are **not included in git** due to their size (100MB-2GB each).

The `.gitignore` file excludes:
- `*.onnx` - ONNX model files
- `*.pt` - PyTorch checkpoints
- `*.pth` - PyTorch model files
- `*.h5` - Keras/TensorFlow models

Only configuration files (`config.pbtxt`) and scripts (`*.py`) are tracked.

## Next Steps

After setting up models:
1. Configure environment variables: `MODEL_NAMES` and `MODEL_URLS`
2. Start Triton: `docker compose up triton`
3. Verify health: `curl http://localhost:8000/v2/health/ready`
4. Run tests: `TRITON_GRPC_URL=localhost:8001 uv run pytest tests/integration/triton_standalone/ -v`
