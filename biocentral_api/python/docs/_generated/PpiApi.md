# biocentral_server_api._generated.PpiApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**auto_detect_format_by_header_api_v1_ppi_service_auto_detect_format_post**](PpiApi.md#auto_detect_format_by_header_api_v1_ppi_service_auto_detect_format_post) | **POST** /api/v1/ppi_service/auto_detect_format | Auto Detect Format By Header
[**formats_api_v1_ppi_service_formats_get**](PpiApi.md#formats_api_v1_ppi_service_formats_get) | **GET** /api/v1/ppi_service/formats | Formats
[**import_dataset_api_v1_ppi_service_import_post**](PpiApi.md#import_dataset_api_v1_ppi_service_import_post) | **POST** /api/v1/ppi_service/import | Import Dataset
[**run_test_api_v1_ppi_service_dataset_tests_run_test_post**](PpiApi.md#run_test_api_v1_ppi_service_dataset_tests_run_test_post) | **POST** /api/v1/ppi_service/dataset_tests/run_test | Run Test
[**tests_api_v1_ppi_service_dataset_tests_tests_get**](PpiApi.md#tests_api_v1_ppi_service_dataset_tests_tests_get) | **GET** /api/v1/ppi_service/dataset_tests/tests | Tests


# **auto_detect_format_by_header_api_v1_ppi_service_auto_detect_format_post**
> DetectedFormatResponse auto_detect_format_by_header_api_v1_ppi_service_auto_detect_format_post(auto_detect_format_request)

Auto Detect Format By Header

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.auto_detect_format_request import AutoDetectFormatRequest
from biocentral_server_api._generated.models.detected_format_response import DetectedFormatResponse
from biocentral_server_api._generated.rest import ApiException
from pprint import pprint

# Defining the host is optional and defaults to http://localhost
# See configuration.py for a list of all supported configuration parameters.
configuration = biocentral_server_api._generated.Configuration(
    host = "http://localhost"
)


# Enter a context with an instance of the API client
with biocentral_server_api._generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = biocentral_server_api._generated.PpiApi(api_client)
    auto_detect_format_request = biocentral_server_api._generated.AutoDetectFormatRequest() # AutoDetectFormatRequest | 

    try:
        # Auto Detect Format By Header
        api_response = api_instance.auto_detect_format_by_header_api_v1_ppi_service_auto_detect_format_post(auto_detect_format_request)
        print("The response of PpiApi->auto_detect_format_by_header_api_v1_ppi_service_auto_detect_format_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PpiApi->auto_detect_format_by_header_api_v1_ppi_service_auto_detect_format_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **auto_detect_format_request** | [**AutoDetectFormatRequest**](AutoDetectFormatRequest.md)|  | 

### Return type

[**DetectedFormatResponse**](DetectedFormatResponse.md)

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

# **formats_api_v1_ppi_service_formats_get**
> object formats_api_v1_ppi_service_formats_get()

Formats

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.rest import ApiException
from pprint import pprint

# Defining the host is optional and defaults to http://localhost
# See configuration.py for a list of all supported configuration parameters.
configuration = biocentral_server_api._generated.Configuration(
    host = "http://localhost"
)


# Enter a context with an instance of the API client
with biocentral_server_api._generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = biocentral_server_api._generated.PpiApi(api_client)

    try:
        # Formats
        api_response = api_instance.formats_api_v1_ppi_service_formats_get()
        print("The response of PpiApi->formats_api_v1_ppi_service_formats_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PpiApi->formats_api_v1_ppi_service_formats_get: %s\n" % e)
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

# **import_dataset_api_v1_ppi_service_import_post**
> ImportDatasetResponse import_dataset_api_v1_ppi_service_import_post(import_dataset_request)

Import Dataset

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.import_dataset_request import ImportDatasetRequest
from biocentral_server_api._generated.models.import_dataset_response import ImportDatasetResponse
from biocentral_server_api._generated.rest import ApiException
from pprint import pprint

# Defining the host is optional and defaults to http://localhost
# See configuration.py for a list of all supported configuration parameters.
configuration = biocentral_server_api._generated.Configuration(
    host = "http://localhost"
)


# Enter a context with an instance of the API client
with biocentral_server_api._generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = biocentral_server_api._generated.PpiApi(api_client)
    import_dataset_request = biocentral_server_api._generated.ImportDatasetRequest() # ImportDatasetRequest | 

    try:
        # Import Dataset
        api_response = api_instance.import_dataset_api_v1_ppi_service_import_post(import_dataset_request)
        print("The response of PpiApi->import_dataset_api_v1_ppi_service_import_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PpiApi->import_dataset_api_v1_ppi_service_import_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **import_dataset_request** | [**ImportDatasetRequest**](ImportDatasetRequest.md)|  | 

### Return type

[**ImportDatasetResponse**](ImportDatasetResponse.md)

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

# **run_test_api_v1_ppi_service_dataset_tests_run_test_post**
> RunTestResponse run_test_api_v1_ppi_service_dataset_tests_run_test_post(run_test_request)

Run Test

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.run_test_request import RunTestRequest
from biocentral_server_api._generated.models.run_test_response import RunTestResponse
from biocentral_server_api._generated.rest import ApiException
from pprint import pprint

# Defining the host is optional and defaults to http://localhost
# See configuration.py for a list of all supported configuration parameters.
configuration = biocentral_server_api._generated.Configuration(
    host = "http://localhost"
)


# Enter a context with an instance of the API client
with biocentral_server_api._generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = biocentral_server_api._generated.PpiApi(api_client)
    run_test_request = biocentral_server_api._generated.RunTestRequest() # RunTestRequest | 

    try:
        # Run Test
        api_response = api_instance.run_test_api_v1_ppi_service_dataset_tests_run_test_post(run_test_request)
        print("The response of PpiApi->run_test_api_v1_ppi_service_dataset_tests_run_test_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PpiApi->run_test_api_v1_ppi_service_dataset_tests_run_test_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **run_test_request** | [**RunTestRequest**](RunTestRequest.md)|  | 

### Return type

[**RunTestResponse**](RunTestResponse.md)

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

# **tests_api_v1_ppi_service_dataset_tests_tests_get**
> object tests_api_v1_ppi_service_dataset_tests_tests_get()

Tests

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.rest import ApiException
from pprint import pprint

# Defining the host is optional and defaults to http://localhost
# See configuration.py for a list of all supported configuration parameters.
configuration = biocentral_server_api._generated.Configuration(
    host = "http://localhost"
)


# Enter a context with an instance of the API client
with biocentral_server_api._generated.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = biocentral_server_api._generated.PpiApi(api_client)

    try:
        # Tests
        api_response = api_instance.tests_api_v1_ppi_service_dataset_tests_tests_get()
        print("The response of PpiApi->tests_api_v1_ppi_service_dataset_tests_tests_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PpiApi->tests_api_v1_ppi_service_dataset_tests_tests_get: %s\n" % e)
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

