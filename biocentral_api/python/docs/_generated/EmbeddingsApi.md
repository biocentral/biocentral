# biocentral_api._generated.EmbeddingsApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**add_embeddings_api_v1_embeddings_service_add_embeddings_post**](EmbeddingsApi.md#add_embeddings_api_v1_embeddings_service_add_embeddings_post) | **POST** /api/v1/embeddings_service/add_embeddings | Add embeddings
[**embed_api_v1_embeddings_service_embed_post**](EmbeddingsApi.md#embed_api_v1_embeddings_service_embed_post) | **POST** /api/v1/embeddings_service/embed | Calculate embeddings
[**get_missing_embeddings_api_v1_embeddings_service_get_missing_embeddings_post**](EmbeddingsApi.md#get_missing_embeddings_api_v1_embeddings_service_get_missing_embeddings_post) | **POST** /api/v1/embeddings_service/get_missing_embeddings | Check missing embeddings


# **add_embeddings_api_v1_embeddings_service_add_embeddings_post**
> AddEmbeddingsResponse add_embeddings_api_v1_embeddings_service_add_embeddings_post(add_embeddings_request)

Add embeddings

Add pre-computed embeddings from HDF5 file to the embeddings database

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.add_embeddings_request import AddEmbeddingsRequest
from biocentral_api._generated.models.add_embeddings_response import AddEmbeddingsResponse
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
    api_instance = biocentral_api._generated.EmbeddingsApi(api_client)
    add_embeddings_request = biocentral_api._generated.AddEmbeddingsRequest() # AddEmbeddingsRequest | 

    try:
        # Add embeddings
        api_response = api_instance.add_embeddings_api_v1_embeddings_service_add_embeddings_post(add_embeddings_request)
        print("The response of EmbeddingsApi->add_embeddings_api_v1_embeddings_service_add_embeddings_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling EmbeddingsApi->add_embeddings_api_v1_embeddings_service_add_embeddings_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **add_embeddings_request** | [**AddEmbeddingsRequest**](AddEmbeddingsRequest.md)|  | 

### Return type

[**AddEmbeddingsResponse**](AddEmbeddingsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

### HTTP response details

| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | Successful Response |  -  |
**404** | Not found |  -  |
**400** | Bad Request |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **embed_api_v1_embeddings_service_embed_post**
> StartTaskResponse embed_api_v1_embeddings_service_embed_post(embed_request)

Calculate embeddings

Submit sequences for embedding calculation using specified embedder model

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.embed_request import EmbedRequest
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
    api_instance = biocentral_api._generated.EmbeddingsApi(api_client)
    embed_request = biocentral_api._generated.EmbedRequest() # EmbedRequest | 

    try:
        # Calculate embeddings
        api_response = api_instance.embed_api_v1_embeddings_service_embed_post(embed_request)
        print("The response of EmbeddingsApi->embed_api_v1_embeddings_service_embed_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling EmbeddingsApi->embed_api_v1_embeddings_service_embed_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **embed_request** | [**EmbedRequest**](EmbedRequest.md)|  | 

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

# **get_missing_embeddings_api_v1_embeddings_service_get_missing_embeddings_post**
> GetMissingEmbeddingsResponse get_missing_embeddings_api_v1_embeddings_service_get_missing_embeddings_post(get_missing_embeddings_request)

Check missing embeddings

Check which sequences are missing embeddings for a given embedder and reduction setting

### Example


```python
import biocentral_api._generated
from biocentral_api._generated.models.get_missing_embeddings_request import GetMissingEmbeddingsRequest
from biocentral_api._generated.models.get_missing_embeddings_response import GetMissingEmbeddingsResponse
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
    api_instance = biocentral_api._generated.EmbeddingsApi(api_client)
    get_missing_embeddings_request = biocentral_api._generated.GetMissingEmbeddingsRequest() # GetMissingEmbeddingsRequest | 

    try:
        # Check missing embeddings
        api_response = api_instance.get_missing_embeddings_api_v1_embeddings_service_get_missing_embeddings_post(get_missing_embeddings_request)
        print("The response of EmbeddingsApi->get_missing_embeddings_api_v1_embeddings_service_get_missing_embeddings_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling EmbeddingsApi->get_missing_embeddings_api_v1_embeddings_service_get_missing_embeddings_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **get_missing_embeddings_request** | [**GetMissingEmbeddingsRequest**](GetMissingEmbeddingsRequest.md)|  | 

### Return type

[**GetMissingEmbeddingsResponse**](GetMissingEmbeddingsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

### HTTP response details

| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | Successful Response |  -  |
**404** | Not found |  -  |
**400** | Bad Request |  -  |
**422** | Validation Error |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

