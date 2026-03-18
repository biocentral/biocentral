from typing import Generator

def batched(iterable, batch_size_limit: int = 1000) -> Generator[list, None, None]:
    """
    Yield batches of approximately equal sizes, not exceeding batch_size_limit.

    :param iterable: An iterable containing the items to be divided into batches.
    :param batch_size_limit: An integer specifying the maximum allowable size of a single
        batch. Default is 1000, which is the maximum batch size allowed by the embed API endpoint.
    :return: A generator that yields lists of items, where each list is a batch containing
        items from the input iterable.
    """
    if batch_size_limit <= 0:
        raise ValueError("batch_size_limit must be greater than 0!")

    items = list(iterable)
    total_items = len(items)

    if total_items == 0:
        return

    # Calculate number of batches needed
    num_batches = (total_items + batch_size_limit - 1) // batch_size_limit

    # Calculate actual batch size to distribute items evenly
    batch_size = (total_items + num_batches - 1) // num_batches

    for i in range(0, total_items, batch_size):
        yield items[i:i + batch_size]
