import base64
import h5py
import io
import json
import numpy as np


def get_h5_info(json_data):
    file_path = json_data.get('file_path')
    with h5py.File(file_path, 'r') as f:
        info = {}
        for key in f.keys():
            dataset = f[key]
            shape = dataset.shape
            # Assuming 2D is per-residue and 1D is per-sequence
            is_per_residue = len(shape) > 1

            info[key] = {
                "is_per_residue": is_per_residue,
                "dimension": shape[-1],
                "length": shape[0] if is_per_residue else 1,
                "attributes": dict(dataset.attrs)
            }
        return info


def get_embedding(json_data):
    key = json_data.get('key')
    file_path = json_data.get('file_path')
    id2emb = {key: None}
    with h5py.File(file_path, 'r') as f:
        if key not in f:
            return id2emb
        embedding = f[key]
        id2emb[key] = np.array(embedding).tolist()
    return id2emb


def read_h5(json_data):
    h5_byte_string = json_data.get('h5_bytes')
    h5_bytes = base64.b64decode(h5_byte_string)

    h5_io = io.BytesIO(h5_bytes)
    embeddings_file = h5py.File(h5_io, 'r')

    # sequence hash -> Embedding
    id2emb = {
        idx: np.array(embedding).tolist()
        for (idx, embedding) in embeddings_file.items()
    }

    embeddings_file.close()
    return {"id2emb": id2emb}


def write_h5(json_data):
    embeddings = json.loads(json_data.get('embeddings'))
    h5_io = io.BytesIO()
    with h5py.File(h5_io, "w") as embeddings_file:
        for seq_id, embedding in embeddings.items():
            embeddings_file.create_dataset(seq_id, data=embedding, compression="gzip", chunks=True)
            embeddings_file[seq_id].attrs["original_id"] = seq_id

    h5_io.seek(0)
    h5_base64 = base64.b64encode(h5_io.getvalue()).decode('utf-8')
    h5_io.close()

    return {"h5_bytes": h5_base64}
