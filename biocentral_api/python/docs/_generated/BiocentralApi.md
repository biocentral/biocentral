# biocentral_api._generated.BiocentralApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**hashes_api_v1_biocentral_service_hashes_hash_id_file_type_get**](BiocentralApi.md#hashes_api_v1_biocentral_service_hashes_hash_id_file_type_get) | **GET** /api/v1/biocentral_service/hashes/{hash_id}/{file_type} | Hashes
[**services_api_v1_biocentral_service_services_get**](BiocentralApi.md#services_api_v1_biocentral_service_services_get) | **GET** /api/v1/biocentral_service/services | Services
[**stats_api_v1_biocentral_service_stats_get**](BiocentralApi.md#stats_api_v1_biocentral_service_stats_get) | **GET** /api/v1/biocentral_service/stats/ | Stats
[**task_status_api_v1_biocentral_service_task_status_task_id_get**](BiocentralApi.md#task_status_api_v1_biocentral_service_task_status_task_id_get) | **GET** /api/v1/biocentral_service/task_status/{task_id} | Task Status
[**task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get**](BiocentralApi.md#task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get) | **GET** /api/v1/biocentral_service/task_status_resumed/{task_id} | Task Status Resumed
[**transfer_file_api_v1_biocentral_service_transfer_file_post**](BiocentralApi.md#transfer_file_api_v1_biocentral_service_transfer_file_post) | **POST** /api/v1/biocentral_service/transfer_file | Transfer File


# **hashes_api_v1_biocentral_service_hashes_hash_id_file_type_get**
> object hashes_api_v1_biocentral_service_hashes_hash_id_file_type_get(hash_id, file_type)

Hashes

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
    api_instance = biocentral_api._generated.BiocentralApi(api_client)
    hash_id = 'hash_id_example' # str | 
    file_type = 'file_type_example' # str | 

    try:
        # Hashes
        api_response = api_instance.hashes_api_v1_biocentral_service_hashes_hash_id_file_type_get(hash_id, file_type)
        print("The response of BiocentralApi->hashes_api_v1_biocentral_service_hashes_hash_id_file_type_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralApi->hashes_api_v1_biocentral_service_hashes_hash_id_file_type_get: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **hash_id** | **str**|  | 
 **file_type** | **str**|  | 

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
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **services_api_v1_biocentral_service_services_get**
> object services_api_v1_biocentral_service_services_get()

Services

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
    api_instance = biocentral_api._generated.BiocentralApi(api_client)

    try:
        # Services
        api_response = api_instance.services_api_v1_biocentral_service_services_get()
        print("The response of BiocentralApi->services_api_v1_biocentral_service_services_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralApi->services_api_v1_biocentral_service_services_get: %s\n" % e)
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
    api_instance = biocentral_api._generated.BiocentralApi(api_client)

    try:
        # Stats
        api_response = api_instance.stats_api_v1_biocentral_service_stats_get()
        print("The response of BiocentralApi->stats_api_v1_biocentral_service_stats_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralApi->stats_api_v1_biocentral_service_stats_get: %s\n" % e)
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
    api_instance = biocentral_api._generated.BiocentralApi(api_client)
    task_id = 'task_id_example' # str | 

    try:
        # Task Status
        api_response = api_instance.task_status_api_v1_biocentral_service_task_status_task_id_get(task_id)
        print("The response of BiocentralApi->task_status_api_v1_biocentral_service_task_status_task_id_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralApi->task_status_api_v1_biocentral_service_task_status_task_id_get: %s\n" % e)
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
    api_instance = biocentral_api._generated.BiocentralApi(api_client)
    task_id = 'task_id_example' # str | 

    try:
        # Task Status Resumed
        api_response = api_instance.task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get(task_id)
        print("The response of BiocentralApi->task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralApi->task_status_resumed_api_v1_biocentral_service_task_status_resumed_task_id_get: %s\n" % e)
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

# **transfer_file_api_v1_biocentral_service_transfer_file_post**
> object transfer_file_api_v1_biocentral_service_transfer_file_post(transfer_file_request)

Transfer File

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.transfer_file_request import TransferFileRequest
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
    api_instance = biocentral_api._generated.BiocentralApi(api_client)
    transfer_file_request = biocentral_api._generated.TransferFileRequest() # TransferFileRequest | 

    try:
        # Transfer File
        api_response = api_instance.transfer_file_api_v1_biocentral_service_transfer_file_post(transfer_file_request)
        print("The response of BiocentralApi->transfer_file_api_v1_biocentral_service_transfer_file_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling BiocentralApi->transfer_file_api_v1_biocentral_service_transfer_file_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **transfer_file_request** | [**TransferFileRequest**](TransferFileRequest.md)|  | 

### Return type

**object**

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
**400** | Bad Request |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

