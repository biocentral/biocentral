import numpy as np

MODEL_BASE_PATH = "PREDICT"


def get_batched_data(batch_size: int, data: np.array, mask: bool = False) -> list[dict]:
    """
    Returns the given data in batches. Each batch contains its data as a dict. The structure is enforced by the onnx runtime model.
    :param batch_size: The number of elements per batch
    :param data: The already embedded data
    :param mask: True if the onnx-model requires a mask, else false.
    :return: A list of dicts containing the batched data:
        'input': <batch_of_embeddings>
        and additionally if mask required:
        'mask': <attention_mask>
        The keys must be named like that, or else the onnx-model-inference will fail.
    """
    batched_data = []
    data = list(data)
    if mask:
        for i in range(0, len(data), batch_size):
            batch_data = data[i : i + batch_size]
            padded_embeddings_batch, attention_masks_batch = pad_embeddings(
                embeddings=batch_data, get_attention_mask=True
            )
            batched_data.append(
                {"input": padded_embeddings_batch, "mask": attention_masks_batch}
            )
    else:
        for i in range(0, len(data), batch_size):
            batched_data.append(
                {
                    "input": pad_embeddings(
                        embeddings=data[i : i + batch_size], get_attention_mask=False
                    )[0],
                }
            )
    return batched_data


def pad_embeddings(embeddings: np.array, get_attention_mask: bool = False):
    """
    Padds the given batch of embeddings to the longest given sequence. Creates the corresponding attention mask if needed.
    :param embeddings: Batch of embeddings to pad
    :param get_attention_mask: True if the attention mask is needed, else false
    :return: A tuple containing the padded batch of embeddings and the corresponding attention mask if get_attention_mask == True, else
    the padded embeddings and an empty list.
    """
    max_length = max(array.shape[0] for array in embeddings)
    padded_arrays = []
    attention_masks = []
    for array in embeddings:
        padding = ((0, max_length - array.shape[0]), (0, 0))
        padded_array = np.pad(array, padding, mode="constant", constant_values=0)
        padded_arrays.append(padded_array)

        if get_attention_mask:
            attention_mask = np.ones(array.shape[0], dtype=int)
            pad_mask = np.zeros(max_length - array.shape[0], dtype=int)
            full_attention_mask = np.concatenate([attention_mask, pad_mask])
            attention_masks.append(full_attention_mask)
    padded_embeddings = np.stack(padded_arrays)
    if get_attention_mask:
        attention_masks = np.float32(np.stack(attention_masks))
    return padded_embeddings, attention_masks
