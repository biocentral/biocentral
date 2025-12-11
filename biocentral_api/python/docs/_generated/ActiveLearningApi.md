# biocentral_api._generated.ActiveLearningApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**active_learning_iteration_api_v1_active_learning_service_iteration_post**](ActiveLearningApi.md#active_learning_iteration_api_v1_active_learning_service_iteration_post) | **POST** /api/v1/active_learning_service/iteration | Run one active learning iteration
[**active_learning_simulation_api_v1_active_learning_service_simulation_post**](ActiveLearningApi.md#active_learning_simulation_api_v1_active_learning_service_simulation_post) | **POST** /api/v1/active_learning_service/simulation | Run a simulated active learning campaign


# **active_learning_iteration_api_v1_active_learning_service_iteration_post**
> StartTaskResponse active_learning_iteration_api_v1_active_learning_service_iteration_post(active_learning_iteration_request)

Run one active learning iteration

Submit an active learning iteration job

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.active_learning_iteration_request import ActiveLearningIterationRequest
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
    api_instance = biocentral_api._generated.ActiveLearningApi(api_client)
    active_learning_iteration_request = biocentral_api._generated.ActiveLearningIterationRequest() # ActiveLearningIterationRequest | 

    try:
        # Run one active learning iteration
        api_response = api_instance.active_learning_iteration_api_v1_active_learning_service_iteration_post(active_learning_iteration_request)
        print("The response of ActiveLearningApi->active_learning_iteration_api_v1_active_learning_service_iteration_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling ActiveLearningApi->active_learning_iteration_api_v1_active_learning_service_iteration_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **active_learning_iteration_request** | [**ActiveLearningIterationRequest**](ActiveLearningIterationRequest.md)|  | 

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
**404** | Not Found |  -  |
**400** | Validation Error |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **active_learning_simulation_api_v1_active_learning_service_simulation_post**
> StartTaskResponse active_learning_simulation_api_v1_active_learning_service_simulation_post(active_learning_simulation_request)

Run a simulated active learning campaign

Submit an active learning simulation job

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.active_learning_simulation_request import ActiveLearningSimulationRequest
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
    api_instance = biocentral_api._generated.ActiveLearningApi(api_client)
    active_learning_simulation_request = biocentral_api._generated.ActiveLearningSimulationRequest() # ActiveLearningSimulationRequest | 

    try:
        # Run a simulated active learning campaign
        api_response = api_instance.active_learning_simulation_api_v1_active_learning_service_simulation_post(active_learning_simulation_request)
        print("The response of ActiveLearningApi->active_learning_simulation_api_v1_active_learning_service_simulation_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling ActiveLearningApi->active_learning_simulation_api_v1_active_learning_service_simulation_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **active_learning_simulation_request** | [**ActiveLearningSimulationRequest**](ActiveLearningSimulationRequest.md)|  | 

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
**404** | Not Found |  -  |
**400** | Validation Error |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

