# biocentral_server_api._generated.ProteinsApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**taxonomy_api_v1_protein_service_taxonomy_post**](ProteinsApi.md#taxonomy_api_v1_protein_service_taxonomy_post) | **POST** /api/v1/protein_service/taxonomy/ | Retrieve taxonomy data


# **taxonomy_api_v1_protein_service_taxonomy_post**
> TaxonomyResponse taxonomy_api_v1_protein_service_taxonomy_post(taxonomy_request)

Retrieve taxonomy data

Retrieve taxonomy data for a list of taxonomy ids

### Example


```python
import biocentral_server_api._generated
from biocentral_server_api._generated.models.taxonomy_request import TaxonomyRequest
from biocentral_server_api._generated.models.taxonomy_response import TaxonomyResponse
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
    api_instance = biocentral_server_api._generated.ProteinsApi(api_client)
    taxonomy_request = biocentral_server_api._generated.TaxonomyRequest() # TaxonomyRequest | 

    try:
        # Retrieve taxonomy data
        api_response = api_instance.taxonomy_api_v1_protein_service_taxonomy_post(taxonomy_request)
        print("The response of ProteinsApi->taxonomy_api_v1_protein_service_taxonomy_post:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling ProteinsApi->taxonomy_api_v1_protein_service_taxonomy_post: %s\n" % e)
```



### Parameters


Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taxonomy_request** | [**TaxonomyRequest**](TaxonomyRequest.md)|  | 

### Return type

[**TaxonomyResponse**](TaxonomyResponse.md)

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

