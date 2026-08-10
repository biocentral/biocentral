# SequenceData

## Properties

| Name           | Type                  | Description                                                 | Notes      |
| -------------- | --------------------- | ----------------------------------------------------------- | ---------- |
| **seq_id**     | **str**               | Sequence id                                                 |
| **seq**        | **str**               | Sequence                                                    |
| **label**      | **str**               | Shortcut for TARGET attribute                               | [optional] |
| **set**        | **str**               | Shortcut for SET attribute                                  | [optional] |
| **mask**       | **str**               | Shortcut for MASK attribute                                 | [optional] |
| **attributes** | **Dict[str, object]** | Attributes such as TARGET, SET or MASK                      | [optional] |
| **embedding**  | **List[object]**      | Embedding (should be a list or torch.tensor or numpy array) | [optional] |

## Example

```python
from biocentral_api._generated.models.sequence_data import SequenceData

# TODO update the JSON string below
json = "{}"
# create an instance of SequenceData from a JSON string
sequence_data_instance = SequenceData.from_json(json)
# print the JSON string representation of the object
print(SequenceData.to_json())

# convert the object into a dict
sequence_data_dict = sequence_data_instance.to_dict()
# create an instance of SequenceData from a dict
sequence_data_from_dict = SequenceData.from_dict(sequence_data_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
