import io
import json

import h5py
import base64
import numpy as np


def read_h5(json_data):
    h5_byte_string = json_data.get('h5_bytes')
    h5_bytes = base64.b64decode(h5_byte_string)

    h5_io = io.BytesIO(h5_bytes)
    embeddings_file = h5py.File(h5_io, 'r')

    # "original_id" from embeddings file -> Embedding
    id2emb = {
        embeddings_file[idx].attrs["original_id"]: np.array(embedding).tolist()
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
