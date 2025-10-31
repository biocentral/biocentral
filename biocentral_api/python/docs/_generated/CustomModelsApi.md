# biocentral_server_api._generated.CustomModelsApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**config_options_api_v1_custom_models_service_config_options_protocol_get**](CustomModelsApi.md#config_options_api_v1_custom_models_service_config_options_protocol_get) | **GET** /api/v1/custom_models_service/config_options/{protocol} | Get configuration options for a protocol
[**model_files_api_v1_custom_models_service_model_files_post**](CustomModelsApi.md#model_files_api_v1_custom_models_service_model_files_post) | **POST** /api/v1/custom_models_service/model_files | Retrieve model files
[**protocols_api_v1_custom_models_service_protocols_get**](CustomModelsApi.md#protocols_api_v1_custom_models_service_protocols_get) | **GET** /api/v1/custom_models_service/protocols | Get available protocols
[**start_inference_api_v1_custom_models_service_start_inference_post**](CustomModelsApi.md#start_inference_api_v1_custom_models_service_start_inference_post) | **POST** /api/v1/custom_models_service/start_inference | Start model inference
[**start_training_api_v1_custom_models_service_start_training_post**](CustomModelsApi.md#start_training_api_v1_custom_models_service_start_training_post) | **POST** /api/v1/custom_models_service/start_training | Start model training
[**verify_config_api_v1_custom_models_service_verify_config_post**](CustomModelsApi.md#verify_config_api_v1_custom_models_service_verify_config_post) | **POST** /api/v1/custom_models_service/verify_config/ | Verify configuration


# **config_options_api_v1_custom_models_service_config_options_protocol_get**
> ConfigOptionsResponse config_options_api_v1_custom_models_service_config_options_protocol_get(protocol)

Get configuration options for a protocol

Retrieve available configuration options for a specific biotrainer protocol

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.config_options_response import ConfigOptionsResponse
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
    api_instance = biocentral_server_api._generated.CustomModelsApi(api_client)
    protocol = 'protocol_example' # str | 

    try:
        # Get configuration options for a protocol
        api_response = api_instance.config_options_api_v1_custom_models_service_config_options_protocol_get(protocol)
        print("The response of CustomModelsApi->config_options_api_v1_custom_models_service_config_options_protocol_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling CustomModelsApi->config_options_api_v1_custom_models_service_config_options_protocol_get: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **protocol** | **str**|  | 

### Return type

[**ConfigOptionsResponse**](ConfigOptionsResponse.md)

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
**400** | Bad Request |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **model_files_api_v1_custom_models_service_model_files_post**
> Dict[str, object] model_files_api_v1_custom_models_service_model_files_post(model_files_request)

Retrieve model files

Get trained model files after training completion

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.model_files_request import ModelFilesRequest
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
    api_instance = biocentral_server_api._generated.CustomModelsApi(api_client)
    model_files_request = biocentral_server_api._generated.ModelFilesRequest() # ModelFilesRequest | 

    try:
        # Retrieve model files
        api_response = api_instance.model_files_api_v1_custom_models_service_model_files_post(model_files_request)
        print("The response of CustomModelsApi->model_files_api_v1_custom_models_service_model_files_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling CustomModelsApi->model_files_api_v1_custom_models_service_model_files_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **model_files_request** | [**ModelFilesRequest**](ModelFilesRequest.md)|  | 

### Return type

**Dict[str, object]**

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

# **protocols_api_v1_custom_models_service_protocols_get**
> ProtocolsResponse protocols_api_v1_custom_models_service_protocols_get()

Get available protocols

Retrieve list of all available biotrainer protocols

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.protocols_response import ProtocolsResponse
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
    api_instance = biocentral_server_api._generated.CustomModelsApi(api_client)

    try:
        # Get available protocols
        api_response = api_instance.protocols_api_v1_custom_models_service_protocols_get()
        print("The response of CustomModelsApi->protocols_api_v1_custom_models_service_protocols_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling CustomModelsApi->protocols_api_v1_custom_models_service_protocols_get: %s\n" % e)
```



### Parameters

This endpoint does not need any parameter.

### Return type

[**ProtocolsResponse**](ProtocolsResponse.md)

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

# **start_inference_api_v1_custom_models_service_start_inference_post**
> StartTaskResponse start_inference_api_v1_custom_models_service_start_inference_post(start_inference_request)

Start model inference

Submit sequences for prediction using a trained model

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.start_inference_request import StartInferenceRequest
from biocentral_server_api._generated.models.start_task_response import StartTaskResponse
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
    api_instance = biocentral_server_api._generated.CustomModelsApi(api_client)
    start_inference_request = biocentral_server_api._generated.StartInferenceRequest() # StartInferenceRequest | 

    try:
        # Start model inference
        api_response = api_instance.start_inference_api_v1_custom_models_service_start_inference_post(start_inference_request)
        print("The response of CustomModelsApi->start_inference_api_v1_custom_models_service_start_inference_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling CustomModelsApi->start_inference_api_v1_custom_models_service_start_inference_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **start_inference_request** | [**StartInferenceRequest**](StartInferenceRequest.md)|  | 

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
**400** | Bad Request |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **start_training_api_v1_custom_models_service_start_training_post**
> StartTaskResponse start_training_api_v1_custom_models_service_start_training_post(start_training_request)

Start model training

Submit a new model training job with specified configuration and training data

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.start_task_response import StartTaskResponse
from biocentral_server_api._generated.models.start_training_request import StartTrainingRequest
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
    api_instance = biocentral_server_api._generated.CustomModelsApi(api_client)
    start_training_request = biocentral_server_api._generated.StartTrainingRequest() # StartTrainingRequest | 

    try:
        # Start model training
        api_response = api_instance.start_training_api_v1_custom_models_service_start_training_post(start_training_request)
        print("The response of CustomModelsApi->start_training_api_v1_custom_models_service_start_training_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling CustomModelsApi->start_training_api_v1_custom_models_service_start_training_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **start_training_request** | [**StartTrainingRequest**](StartTrainingRequest.md)|  | 

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
**400** | Bad Request |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verify_config_api_v1_custom_models_service_verify_config_post**
> ConfigVerificationResponse verify_config_api_v1_custom_models_service_verify_config_post(config_verification_request)

Verify configuration

Validate a biotrainer configuration dict

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.config_verification_request import ConfigVerificationRequest
from biocentral_server_api._generated.models.config_verification_response import ConfigVerificationResponse
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
    api_instance = biocentral_server_api._generated.CustomModelsApi(api_client)
    config_verification_request = biocentral_server_api._generated.ConfigVerificationRequest() # ConfigVerificationRequest | 

    try:
        # Verify configuration
        api_response = api_instance.verify_config_api_v1_custom_models_service_verify_config_post(config_verification_request)
        print("The response of CustomModelsApi->verify_config_api_v1_custom_models_service_verify_config_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling CustomModelsApi->verify_config_api_v1_custom_models_service_verify_config_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **config_verification_request** | [**ConfigVerificationRequest**](ConfigVerificationRequest.md)|  | 

### Return type

[**ConfigVerificationResponse**](ConfigVerificationResponse.md)

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

