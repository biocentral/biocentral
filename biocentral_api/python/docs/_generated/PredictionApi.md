# biocentral_server_api._generated.PredictionApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**model_metadata_api_v1_prediction_service_model_metadata_get**](PredictionApi.md#model_metadata_api_v1_prediction_service_model_metadata_get) | **GET** /api/v1/prediction_service/model_metadata | Get predict model metadata
[**predict_api_v1_prediction_service_predict_post**](PredictionApi.md#predict_api_v1_prediction_service_predict_post) | **POST** /api/v1/prediction_service/predict | Submit protein sequence prediction job


# **model_metadata_api_v1_prediction_service_model_metadata_get**
> ModelMetadataResponse model_metadata_api_v1_prediction_service_model_metadata_get()

Get predict model metadata

Get metadata for available prediction models

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.model_metadata_response import ModelMetadataResponse
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
    api_instance = biocentral_server_api._generated.PredictionApi(api_client)

    try:
        # Get predict model metadata
        api_response = api_instance.model_metadata_api_v1_prediction_service_model_metadata_get()
        print("The response of PredictionApi->model_metadata_api_v1_prediction_service_model_metadata_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PredictionApi->model_metadata_api_v1_prediction_service_model_metadata_get: %s\n" % e)
```



### Parameters

This endpoint does not need any parameter.

### Return type

[**ModelMetadataResponse**](ModelMetadataResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

### HTTP response details

| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | Successful Response |  -  |
**404** | Not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **predict_api_v1_prediction_service_predict_post**
> StartTaskResponse predict_api_v1_prediction_service_predict_post(prediction_request)

Submit protein sequence prediction job

Submit sequences for prediction using specified models and receive a task ID for tracking

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.prediction_request import PredictionRequest
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
    api_instance = biocentral_server_api._generated.PredictionApi(api_client)
    prediction_request = biocentral_server_api._generated.PredictionRequest() # PredictionRequest | 

    try:
        # Submit protein sequence prediction job
        api_response = api_instance.predict_api_v1_prediction_service_predict_post(prediction_request)
        print("The response of PredictionApi->predict_api_v1_prediction_service_predict_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling PredictionApi->predict_api_v1_prediction_service_predict_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **prediction_request** | [**PredictionRequest**](PredictionRequest.md)|  | 

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
**404** | Model not found |  -  |
**400** | Bad Request |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

