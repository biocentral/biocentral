# biocentral_api._generated.PlmEvalApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**autoeval_api_v1_plm_eval_service_autoeval_post**](PlmEvalApi.md#autoeval_api_v1_plm_eval_service_autoeval_post) | **POST** /api/v1/plm_eval_service/autoeval | Automated Protein Language Model Evaluation
[**plm_eval_information_api_v1_plm_eval_service_plm_eval_information_get**](PlmEvalApi.md#plm_eval_information_api_v1_plm_eval_service_plm_eval_information_get) | **GET** /api/v1/plm_eval_service/plm_eval_information | Get PLM eval information
[**validate_api_v1_plm_eval_service_validate_model_id_post**](PlmEvalApi.md#validate_api_v1_plm_eval_service_validate_model_id_post) | **POST** /api/v1/plm_eval_service/validate_model_id | Validate model ID


# **autoeval_api_v1_plm_eval_service_autoeval_post**
> StartTaskResponse autoeval_api_v1_plm_eval_service_autoeval_post(plm_eval_autoeval_request)

Automated Protein Language Model Evaluation

Automated protein language model evaluation on pre-defined, curated datasets and tasks

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.plm_eval_autoeval_request import PLMEvalAutoevalRequest
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
    api_instance = biocentral_api._generated.PlmEvalApi(api_client)
    plm_eval_autoeval_request = biocentral_api._generated.PLMEvalAutoevalRequest() # PLMEvalAutoevalRequest | 

    try:
        # Automated Protein Language Model Evaluation
        api_response = api_instance.autoeval_api_v1_plm_eval_service_autoeval_post(plm_eval_autoeval_request)
        print("The response of PlmEvalApi->autoeval_api_v1_plm_eval_service_autoeval_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PlmEvalApi->autoeval_api_v1_plm_eval_service_autoeval_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **plm_eval_autoeval_request** | [**PLMEvalAutoevalRequest**](PLMEvalAutoevalRequest.md)|  | 

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

# **plm_eval_information_api_v1_plm_eval_service_plm_eval_information_get**
> PLMEvalInformationResponse plm_eval_information_api_v1_plm_eval_service_plm_eval_information_get()

Get PLM eval information

Get information about PLM eval datasets and process

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.plm_eval_information_response import PLMEvalInformationResponse
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
    api_instance = biocentral_api._generated.PlmEvalApi(api_client)

    try:
        # Get PLM eval information
        api_response = api_instance.plm_eval_information_api_v1_plm_eval_service_plm_eval_information_get()
        print("The response of PlmEvalApi->plm_eval_information_api_v1_plm_eval_service_plm_eval_information_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PlmEvalApi->plm_eval_information_api_v1_plm_eval_service_plm_eval_information_get: %s\n" % e)
```



### Parameters

This endpoint does not need any parameter.

### Return type

[**PLMEvalInformationResponse**](PLMEvalInformationResponse.md)

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

# **validate_api_v1_plm_eval_service_validate_model_id_post**
> PLMEvalValidateResponse validate_api_v1_plm_eval_service_validate_model_id_post(plm_eval_validate_request)

Validate model ID

Validate if the given model id exists on huggingface and can be used for plm_eval

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.plm_eval_validate_request import PLMEvalValidateRequest
from biocentral_api._generated.models.plm_eval_validate_response import PLMEvalValidateResponse
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
    api_instance = biocentral_api._generated.PlmEvalApi(api_client)
    plm_eval_validate_request = biocentral_api._generated.PLMEvalValidateRequest() # PLMEvalValidateRequest | 

    try:
        # Validate model ID
        api_response = api_instance.validate_api_v1_plm_eval_service_validate_model_id_post(plm_eval_validate_request)
        print("The response of PlmEvalApi->validate_api_v1_plm_eval_service_validate_model_id_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PlmEvalApi->validate_api_v1_plm_eval_service_validate_model_id_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **plm_eval_validate_request** | [**PLMEvalValidateRequest**](PLMEvalValidateRequest.md)|  | 

### Return type

[**PLMEvalValidateResponse**](PLMEvalValidateResponse.md)

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

