# biocentral_api._generated.ProjectionsApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**project_api_v1_projection_service_project_post**](ProjectionsApi.md#project_api_v1_projection_service_project_post) | **POST** /api/v1/projection_service/project | Calculate projections
[**projection_config_api_v1_projection_service_projection_config_get**](ProjectionsApi.md#projection_config_api_v1_projection_service_projection_config_get) | **GET** /api/v1/projection_service/projection_config | Get Protspace config options


# **project_api_v1_projection_service_project_post**
> StartTaskResponse project_api_v1_projection_service_project_post(projection_request)

Calculate projections

Calculate projections for embeddings using Protspace

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.projection_request import ProjectionRequest
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
    api_instance = biocentral_api._generated.ProjectionsApi(api_client)
    projection_request = biocentral_api._generated.ProjectionRequest() # ProjectionRequest | 

    try:
        # Calculate projections
        api_response = api_instance.project_api_v1_projection_service_project_post(projection_request)
        print("The response of ProjectionsApi->project_api_v1_projection_service_project_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling ProjectionsApi->project_api_v1_projection_service_project_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projection_request** | [**ProjectionRequest**](ProjectionRequest.md)|  | 

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
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **projection_config_api_v1_projection_service_projection_config_get**
> GetProjectionConfigResponse projection_config_api_v1_projection_service_projection_config_get()

Get Protspace config options

Get Protspace project configs by projection method

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.get_projection_config_response import GetProjectionConfigResponse
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
    api_instance = biocentral_api._generated.ProjectionsApi(api_client)

    try:
        # Get Protspace config options
        api_response = api_instance.projection_config_api_v1_projection_service_projection_config_get()
        print("The response of ProjectionsApi->projection_config_api_v1_projection_service_projection_config_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling ProjectionsApi->projection_config_api_v1_projection_service_projection_config_get: %s\n" % e)
```



### Parameters

This endpoint does not need any parameter.

### Return type

[**GetProjectionConfigResponse**](GetProjectionConfigResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

### HTTP response details

| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | Successful Response |  -  |
**404** | Not Found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

