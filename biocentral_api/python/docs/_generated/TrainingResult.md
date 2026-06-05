# TrainingResult

Training results for each cross-validation split. 

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**n_training_ids** | **int** | Number of sequences in the training set | [optional] 
**n_validation_ids** | **int** | Number of sequences in the validation set | [optional] 
**training_ids** | **List[str]** | List of IDs in the training set | [optional] 
**validation_ids** | **List[str]** | List of IDs in the validation set | [optional] 
**split_hyper_params** | **Dict[str, object]** | Hyperparameters used for this split | [optional] 
**n_free_parameters** | **int** | Number of free parameters in the model | [optional] 
**start_time** | **str** | Start time of the training process | [optional] 
**end_time** | **str** | End time of the training process | [optional] 
**elapsed_time** | **float** | Elapsed time in seconds for training | [optional] 
**training_losses** | **List[float]** | Training losses for each epoch | [optional] 
**validation_losses** | **List[float]** | Validation losses for each epoch | [optional] 
**best_epoch_metrics** | [**EpochMetrics**](EpochMetrics.md) | Best training epoch metrics | [optional] 

## Example

```python
from biocentral_api._generated.models.training_result import TrainingResult

# TODO update the JSON string below
json = "{}"
# create an instance of TrainingResult from a JSON string
training_result_instance = TrainingResult.from_json(json)
# print the JSON string representation of the object
print(TrainingResult.to_json())

# convert the object into a dict
training_result_dict = training_result_instance.to_dict()
# create an instance of TrainingResult from a dict
training_result_from_dict = TrainingResult.from_dict(training_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


