# BiotrainerModelResult

## Properties

| Name                 | Type                                                      | Description                                      | Notes      |
| -------------------- | --------------------------------------------------------- | ------------------------------------------------ | ---------- |
| **config**           | **Dict[str, object]**                                     | Training configuration parameters                | [optional] |
| **derived_values**   | [**DerivedValues**](DerivedValues.md)                     | Values derived during the training process       | [optional] |
| **training_results** | [**Dict[str, TrainingResult]**](TrainingResult.md)        | Training results for each cross-validation split | [optional] |
| **test_results**     | [**Dict[str, TestResult]**](TestResult.md)                | Test results after training for each test set    | [optional] |
| **predictions**      | [**List[BiotrainerPrediction]**](BiotrainerPrediction.md) | Predictions made by the model                    | [optional] |

## Example

```python
from biocentral_api._generated.models.biotrainer_model_result import BiotrainerModelResult

# TODO update the JSON string below
json = "{}"
# create an instance of BiotrainerModelResult from a JSON string
biotrainer_model_result_instance = BiotrainerModelResult.from_json(json)
# print the JSON string representation of the object
print(BiotrainerModelResult.to_json())

# convert the object into a dict
biotrainer_model_result_dict = biotrainer_model_result_instance.to_dict()
# create an instance of BiotrainerModelResult from a dict
biotrainer_model_result_from_dict = BiotrainerModelResult.from_dict(biotrainer_model_result_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
