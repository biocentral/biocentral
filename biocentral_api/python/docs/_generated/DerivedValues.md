# DerivedValues

Derived values calculated during the training process. 

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**biotrainer_version** | **str** | Version of BioTrainer used for training | [optional] 
**class_int2str** | **Dict[str, str]** | Mapping of class integers to class names | [optional] 
**class_str2int** | **Dict[str, int]** | Mapping of class names to class integers | [optional] 
**computed_class_weights** | **Dict[str, float]** | Class weights computed during training | [optional] 
**embedding_stats** | [**EmbeddingStats**](EmbeddingStats.md) | Statistics of the embeddings | [optional] 
**embeddings_file** | **str** | Path to the embeddings file | [optional] 
**model_hash** | **str** | Hash of the model | [optional] 
**n_classes** | **int** | Number of classes in the dataset | [optional] 
**n_features** | **int** | Number of input features (e.g. embedding dimensions) | [optional] 
**n_testing_ids** | **int** | Number of sequences in the test set | [optional] 
**pipeline_elapsed_time** | **float** | Elapsed time in seconds for the pipeline | [optional] 
**pipeline_end_time** | **str** | End time of the pipeline | [optional] 
**pipeline_start_time** | **str** | Start time of the pipeline | [optional] 
**training_elapsed_time** | **float** | Elapsed time in seconds for training | [optional] 

## Example

```python
from biocentral_api._generated.models.derived_values import DerivedValues

# TODO update the JSON string below
json = "{}"
# create an instance of DerivedValues from a JSON string
derived_values_instance = DerivedValues.from_json(json)
# print the JSON string representation of the object
print(DerivedValues.to_json())

# convert the object into a dict
derived_values_dict = derived_values_instance.to_dict()
# create an instance of DerivedValues from a dict
derived_values_from_dict = DerivedValues.from_dict(derived_values_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


