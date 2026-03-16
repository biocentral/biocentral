# ZeroShotFrameworkReport


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**method** | [**ZeroShotMethod**](ZeroShotMethod.md) | Scoring method used | 
**aggregated_results** | [**Dict[str, RankingResult]**](RankingResult.md) | Accumulated autoeval task results (combined_task_name -&gt; RankingResult) | 
**individual_results** | [**Dict[str, RankingResult]**](RankingResult.md) | Individual autoeval task results (dataset_name -&gt; RankingResult) | 

## Example

```python
from biocentral_api._generated.models.zero_shot_framework_report import ZeroShotFrameworkReport

# TODO update the JSON string below
json = "{}"
# create an instance of ZeroShotFrameworkReport from a JSON string
zero_shot_framework_report_instance = ZeroShotFrameworkReport.from_json(json)
# print the JSON string representation of the object
print(ZeroShotFrameworkReport.to_json())

# convert the object into a dict
zero_shot_framework_report_dict = zero_shot_framework_report_instance.to_dict()
# create an instance of ZeroShotFrameworkReport from a dict
zero_shot_framework_report_from_dict = ZeroShotFrameworkReport.from_dict(zero_shot_framework_report_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


