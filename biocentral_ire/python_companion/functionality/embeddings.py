import base64
import h5py
import io
import json
import numpy as np


def get_h5_info(json_data):
    file_path = json_data.get("file_path")
    with h5py.File(file_path, "r") as f:
        info = {}
        for key in f.keys():
            dataset = f[key]
            shape = dataset.shape
            # Assuming 2D is per-residue and 1D is per-sequence
            is_per_residue = len(shape) > 1

            info[key] = {
                "embeddingType": is_per_residue,
                "dimension": shape[-1],
                "length": shape[0] if is_per_residue else 1,
                "attributes": dict(dataset.attrs),
            }
        return info


def get_embedding(json_data):
    key = json_data.get("key")
    file_path = json_data.get("file_path")
    id2emb = {key: None}
    with h5py.File(file_path, "r") as f:
        if key not in f:
            return id2emb
        embedding = f[key]
        id2emb[key] = np.array(embedding).tolist()
    return {"id2emb": id2emb}


def read_h5(json_data):
    h5_byte_string = json_data.get("h5_bytes")
    h5_bytes = base64.b64decode(h5_byte_string)

    h5_io = io.BytesIO(h5_bytes)
    embeddings_file = h5py.File(h5_io, "r")

    # sequence hash -> Embedding
    id2emb = {
        idx: np.array(embedding).tolist()
        for (idx, embedding) in embeddings_file.items()
    }

    embeddings_file.close()
    return {"id2emb": id2emb}


def sync_internal_h5(json_data):
    external_file_path = json_data.get("external_file_path")
    internal_file_path = json_data.get("internal_file_path")

    # Open external file and read all datasets
    with h5py.File(external_file_path, "r") as external_f:
        # Create or open internal file in write mode (will overwrite existing content)
        with h5py.File(internal_file_path, "w") as internal_f:
            # Copy all datasets from external to internal
            for key in external_f.keys():
                # Read dataset from external file
                dataset = external_f[key]
                data = np.array(dataset)

                # Create dataset in internal file with same data and compression
                internal_f.create_dataset(
                    key, data=data, compression="gzip", chunks=True
                )

                # Copy all attributes
                for attr_name, attr_value in dataset.attrs.items():
                    internal_f[key].attrs[attr_name] = attr_value

    return get_h5_info({"file_path": internal_file_path})


def write_h5(json_data):
    embeddings = json.loads(json_data.get("embeddings"))
    h5_io = io.BytesIO()
    with h5py.File(h5_io, "w") as embeddings_file:
        for seq_id, embedding in embeddings.items():
            embeddings_file.create_dataset(
                seq_id, data=embedding, compression="gzip", chunks=True
            )
            embeddings_file[seq_id].attrs["original_id"] = seq_id

    h5_io.seek(0)
    h5_base64 = base64.b64encode(h5_io.getvalue()).decode("utf-8")
    h5_io.close()

    return {"h5_bytes": h5_base64}
