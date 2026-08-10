# BiotrainerInferenceResult

## Properties

| Name            | Type                                                      | Description         | Notes      |
| --------------- | --------------------------------------------------------- | ------------------- | ---------- |
| **predictions** | [**List[BiotrainerPrediction]**](BiotrainerPrediction.md) | List of predictions |
| **metrics**     | **Dict[str, float]**                                      | Metrics             | [optional] |

## Example

```python
from biocentral_api._generated.models.biotrainer_inference_result import BiotrainerInferenceResult

# TODO update the JSON string below
json = "{}"
# create an instance of BiotrainerInferenceResult from a JSON string
biotrainer_inference_result_instance = BiotrainerInferenceResult.from_json(json)
# print the JSON string representation of the object
print(BiotrainerInferenceResult.to_json())

# convert the object into a dict
biotrainer_inference_result_dict = biotrainer_inference_result_instance.to_dict()
# create an instance of BiotrainerInferenceResult from a dict
biotrainer_inference_result_from_dict = BiotrainerInferenceResult.from_dict(biotrainer_inference_result_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
