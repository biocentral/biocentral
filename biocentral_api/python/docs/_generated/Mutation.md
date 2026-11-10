# Mutation

Represents a single mutation (e.g. A15G)

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**wt** | **str** | Wild type residue | 
**position** | **int** | Position of the mutation | 
**mt** | **str** | Mutated residue | 
**one_indexed** | **bool** | Whether the position is one-indexed or zero-indexed | [optional] 

## Example

```python
from biocentral_api._generated.models.mutation import Mutation

# TODO update the JSON string below
json = "{}"
# create an instance of Mutation from a JSON string
mutation_instance = Mutation.from_json(json)
# print the JSON string representation of the object
print(Mutation.to_json())

# convert the object into a dict
mutation_dict = mutation_instance.to_dict()
# create an instance of Mutation from a dict
mutation_from_dict = Mutation.from_dict(mutation_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


