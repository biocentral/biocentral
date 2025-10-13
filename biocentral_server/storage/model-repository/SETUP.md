# Triton Model Repository Setup

This directory contains the Triton model repository structure for serving ONNX models.

## Directory Structure

Each model follows this structure:
```
model_name/
├── config.pbtxt          # Triton model configuration
└── 1/                    # Version 1
    └── model.onnx        # ONNX model file
```

## Required Models

The following models need ONNX files:

### Embedding Models (3)
1. `prot_t5_pipeline` - ProtT5 tokenizer + ONNX ensemble
2. `esm2_t33_pipeline` - ESM2-t33 tokenizer + ONNX ensemble
3. `esm2_t36_pipeline` - ESM2-t36 tokenizer + ONNX ensemble

### Prediction Models (9)
4. `prott5_sec` - Secondary structure prediction
5. `prott5_cons` - Conservation prediction
6. `bind_embed` - Binding site prediction
7. `seth` - Disorder prediction (standalone)
8. `seth_pipeline` - Disorder prediction (with tokenizer)
9. `tmbed` - Transmembrane prediction
10. `light_attention_subcell` - Subcellular localization
11. `light_attention_membrane` - Membrane localization
12. `vespag` - Variant effect prediction

### Internal Models (6)
13. `_internal_prott5_tokenizer` - ProtT5 tokenizer only
14. `_internal_prott5_onnx` - ProtT5 ONNX only
15. `_internal_esm2_tokenizer` - ESM2 tokenizer only
16. `_internal_esm2_t33_onnx` - ESM2-t33 ONNX only
17. `_internal_esm2_t36_onnx` - ESM2-t36 ONNX only

## Setup Options

### Option 1: Use Existing ONNX Files (Recommended)

If you have ONNX model files:

```bash
# Copy your ONNX files to the correct locations
cp /path/to/prott5.onnx storage/model-repository/_internal_prott5_onnx/1/model.onnx
cp /path/to/esm2_t33.onnx storage/model-repository/_internal_esm2_t33_onnx/1/model.onnx
# ... etc for all models

# Verify files exist
find storage/model-repository -name "model.onnx"
```

### Option 2: Create Placeholder Files (Testing Only)

For testing infrastructure without real predictions:

```bash
# The init container will create 1KB placeholder files
docker compose -f docker-compose.triton-test.yml up triton-model-init

# This creates dummy ONNX files that pass Triton validation
# but won't produce meaningful predictions
```

### Option 3: Download from Source (If Configured)

If model download URLs are configured in `init_models.py`:

```bash
# Edit init_models.py to add download URLs
# Then run init container
docker compose -f docker-compose.triton-test.yml up triton-model-init
```

## Initialization Container

The `init_models.py` script runs in an init container to:
1. Check if ONNX files exist
2. Create placeholders for missing files (testing only)
3. Validate model directory structure
4. Log model status

**Environment Variables**:
- `MODEL_REPOSITORY_PATH`: Path to model repository (default: `/models`)
- `MODELS_TO_INITIALIZE`: Comma-separated list of models to initialize (default: all)
- `CREATE_PLACEHOLDERS`: Whether to create placeholder files (default: `true`)

## Testing the Repository

### Verify Structure

```bash
# Check all models have config.pbtxt
find storage/model-repository -name "config.pbtxt" | wc -l
# Should show 18

# Check which models have ONNX files
find storage/model-repository -name "model.onnx"
```

### Start Triton

```bash
# Start Triton with init container
docker compose -f docker-compose.triton-test.yml up -d

# Check logs
docker compose -f docker-compose.triton-test.yml logs triton-model-init
docker compose -f docker-compose.triton-test.yml logs triton

# Verify models loaded
curl http://localhost:8000/v2/models | jq '.[] | .name'
```

### Test Model Inference

```bash
# Check specific model
curl http://localhost:8000/v2/models/prot_t5_pipeline

# Run test predictions
TRITON_GRPC_URL=localhost:8001 uv run pytest tests/integration/triton_standalone/ -v
```

## Troubleshooting

### "Model file not found" errors

```bash
# Check if ONNX files exist
ls -lh storage/model-repository/*/1/model.onnx

# If missing, run init container to create placeholders
docker compose -f docker-compose.triton-test.yml up triton-model-init
```

### Triton fails to load models

```bash
# Check Triton logs for errors
docker compose -f docker-compose.triton-test.yml logs triton | grep -i error

# Verify config.pbtxt syntax
cat storage/model-repository/prot_t5_pipeline/config.pbtxt
```

### Init container fails

```bash
# Check init container logs
docker compose -f docker-compose.triton-test.yml logs triton-model-init

# Run init container manually for debugging
docker compose -f docker-compose.triton-test.yml run triton-model-init
```

## Model Files Not Included

⚠️ **Note**: ONNX model files are **not included in git** due to their size (100MB-2GB each).

The `.gitignore` file excludes:
- `*.onnx` - ONNX model files
- `*.pt` - PyTorch checkpoints
- `*.pth` - PyTorch model files
- `*.h5` - Keras/TensorFlow models

Only configuration files (`config.pbtxt`) and scripts (`*.py`) are tracked.

## Getting ONNX Models

To obtain real ONNX models:

1. **Export from PyTorch**: Convert trained models to ONNX format
2. **Download**: Get pre-converted models from model repository (if available)
3. **Generate**: Use biotrainer to export models to ONNX

Contact the biocentral team for access to pre-trained ONNX models.

## Next Steps

After setting up models:
1. Start Triton: `docker compose -f docker-compose.triton-test.yml up -d`
2. Verify health: `curl http://localhost:8000/v2/health/ready`
3. Run tests: `TRITON_GRPC_URL=localhost:8001 uv run pytest tests/integration/triton_standalone/ -v`

See [TESTING_TRITON.md](../../TESTING_TRITON.md) for complete testing guide.
