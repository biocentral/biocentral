# biocentral_api._generated.BiocentralServiceApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**stats_api_v1_biocentral_service_stats_get**](BiocentralServiceApi.md#stats_api_v1_biocentral_service_stats_get) | **GET** /api/v1/biocentral_service/stats/ | Stats
[**task_status_api_v1_biocentral_service_task_status_task_id_get**](BiocentralServiceApi.md#task_status_api_v1_biocentral_service_task_status_task_id_get) | **GET** /api/v1/biocentral_service/task_status/{task_id} | Task Status
[**task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get**](BiocentralServiceApi.md#task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get) | **GET** /api/v1/biocentral_service/task_status_resumed/{task_id} | Task Status Resumed
[**welcome_message_api_v1_biocentral_service_welcome_message_get**](BiocentralServiceApi.md#welcome_message_api_v1_biocentral_service_welcome_message_get) | **GET** /api/v1/biocentral_service/welcome_message | Welcome Message


# **stats_api_v1_biocentral_service_stats_get**
> object stats_api_v1_biocentral_service_stats_get()

Stats

### Example


```python
import biocentral_api._generated
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
    api_instance = biocentral_api._generated.BiocentralServiceApi(api_client)

    try:
        # Stats
        api_response = api_instance.stats_api_v1_biocentral_service_stats_get()
        print("The response of BiocentralServiceApi->stats_api_v1_biocentral_service_stats_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralServiceApi->stats_api_v1_biocentral_service_stats_get: %s\n" % e)
```



### Parameters

This endpoint does not need any parameter.

### Return type

**object**

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

# **task_status_api_v1_biocentral_service_task_status_task_id_get**
> TaskStatusResponse task_status_api_v1_biocentral_service_task_status_task_id_get(task_id)

Task Status

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.task_status_response import TaskStatusResponse
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
    api_instance = biocentral_api._generated.BiocentralServiceApi(api_client)
    task_id = 'task_id_example' # str | 

    try:
        # Task Status
        api_response = api_instance.task_status_api_v1_biocentral_service_task_status_task_id_get(task_id)
        print("The response of BiocentralServiceApi->task_status_api_v1_biocentral_service_task_status_task_id_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralServiceApi->task_status_api_v1_biocentral_service_task_status_task_id_get: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **task_id** | **str**|  | 

### Return type

[**TaskStatusResponse**](TaskStatusResponse.md)

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
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get**
> TaskStatusResponse task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get(task_id)

Task Status Resumed

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.task_status_response import TaskStatusResponse
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
    api_instance = biocentral_api._generated.BiocentralServiceApi(api_client)
    task_id = 'task_id_example' # str | 

    try:
        # Task Status Resumed
        api_response = api_instance.task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get(task_id)
        print("The response of BiocentralServiceApi->task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralServiceApi->task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **task_id** | **str**|  | 

### Return type

[**TaskStatusResponse**](TaskStatusResponse.md)

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
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **welcome_message_api_v1_biocentral_service_welcome_message_get**
> object welcome_message_api_v1_biocentral_service_welcome_message_get()

Welcome Message

### Example


```python
import biocentral_api._generated
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
    api_instance = biocentral_api._generated.BiocentralServiceApi(api_client)

    try:
        # Welcome Message
        api_response = api_instance.welcome_message_api_v1_biocentral_service_welcome_message_get()
        print("The response of BiocentralServiceApi->welcome_message_api_v1_biocentral_service_welcome_message_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralServiceApi->welcome_message_api_v1_biocentral_service_welcome_message_get: %s\n" % e)
```



### Parameters

This endpoint does not need any parameter.

### Return type

**object**

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

