# biocentral_api._generated.BayesianOptimizationApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**train_and_inference_api_v1_bayesian_optimization_service_training_post**](BayesianOptimizationApi.md#train_and_inference_api_v1_bayesian_optimization_service_training_post) | **POST** /api/v1/bayesian_optimization_service/training | Start Bayesian optimization training


# **train_and_inference_api_v1_bayesian_optimization_service_training_post**
> StartTaskResponse train_and_inference_api_v1_bayesian_optimization_service_training_post(bayesian_optimization_request)

Start Bayesian optimization training

Submit a Bayesian optimization job with specified configuration and training data

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.bayesian_optimization_request import BayesianOptimizationRequest
from biocentral_api._generated.models.start_task_response import StartTaskResponse
from biocentral_api._generated.rest import ApiException
from pprint import pprint

# Defining the host is optional and defaults to http://localhost
# See configuration.py for a list of all supported configuration parameters.
configuration = biocentral_api._generated.Configuration(
    host = "http://localhost"
)


# Enter a context with an instance of the API client
with biocentral_api._generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = biocentral_api._generated.BayesianOptimizationApi(api_client)
    bayesian_optimization_request = biocentral_api._generated.BayesianOptimizationRequest() # BayesianOptimizationRequest | 

    try:
        # Start Bayesian optimization training
        api_response = api_instance.train_and_inference_api_v1_bayesian_optimization_service_training_post(bayesian_optimization_request)
        print("The response of BayesianOptimizationApi->train_and_inference_api_v1_bayesian_optimization_service_training_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BayesianOptimizationApi->train_and_inference_api_v1_bayesian_optimization_service_training_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bayesian_optimization_request** | [**BayesianOptimizationRequest**](BayesianOptimizationRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

### HTTP response details

| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | Successful Response |  -  |
**404** | Database Not Found |  -  |
**400** | Validation Error |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

