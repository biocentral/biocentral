# BayesianOptimizationRequest

Request model for Bayesian optimization training

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**database_hash** | **str** | Hash identifier for the training database | 
**model_type** | **str** | Type of model to use | 
**coefficient** | **float** | Coefficient value (must be non-negative) | 
**embedder_name** | **str** | Name of embedder to use | 
**discrete** | **bool** | Whether to perform discrete optimization or continuous optimization | 
**optimization_mode** | **str** | Optimization mode selection | 
**target_lb** | **float** |  | [optional] 
**target_ub** | **float** |  | [optional] 
**target_value** | **float** |  | [optional] 
**discrete_labels** | **List[str]** |  | 
**discrete_targets** | **List[str]** |  | 

## Example

```python
from biocentral_server_api._generated.models.bayesian_optimization_request import BayesianOptimizationRequest

# TODO update the JSON string below
json = "{}"
# create an instance of BayesianOptimizationRequest from a JSON string
bayesian_optimization_request_instance = BayesianOptimizationRequest.from_json(json)
# print the JSON string representation of the object
print(BayesianOptimizationRequest.to_json())

# convert the object into a dict
bayesian_optimization_request_dict = bayesian_optimization_request_instance.to_dict()
# create an instance of BayesianOptimizationRequest from a dict
bayesian_optimization_request_from_dict = BayesianOptimizationRequest.from_dict(bayesian_optimization_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


