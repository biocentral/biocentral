# biocentral_api.api.EmbeddingsApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addEmbeddingsApiV1EmbeddingsServiceAddEmbeddingsPost**](EmbeddingsApi.md#addembeddingsapiv1embeddingsserviceaddembeddingspost) | **POST** /api/v1/embeddings_service/add_embeddings | Add embeddings
[**commonEmbeddersApiV1EmbeddingsServiceCommonEmbeddersGet**](EmbeddingsApi.md#commonembeddersapiv1embeddingsservicecommonembeddersget) | **GET** /api/v1/embeddings_service/common_embedders | Get a list of common embedder names support by the server
[**embedApiV1EmbeddingsServiceEmbedPost**](EmbeddingsApi.md#embedapiv1embeddingsserviceembedpost) | **POST** /api/v1/embeddings_service/embed | Calculate embeddings
[**getMissingEmbeddingsApiV1EmbeddingsServiceGetMissingEmbeddingsPost**](EmbeddingsApi.md#getmissingembeddingsapiv1embeddingsservicegetmissingembeddingspost) | **POST** /api/v1/embeddings_service/get_missing_embeddings | Check missing embeddings


# **addEmbeddingsApiV1EmbeddingsServiceAddEmbeddingsPost**
> AddEmbeddingsResponse addEmbeddingsApiV1EmbeddingsServiceAddEmbeddingsPost(addEmbeddingsRequest)

Add embeddings

Add pre-computed embeddings from HDF5 file to the embeddings database

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getEmbeddingsApi();
final AddEmbeddingsRequest addEmbeddingsRequest = ; // AddEmbeddingsRequest | 

try {
    final response = api.addEmbeddingsApiV1EmbeddingsServiceAddEmbeddingsPost(addEmbeddingsRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling EmbeddingsApi->addEmbeddingsApiV1EmbeddingsServiceAddEmbeddingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addEmbeddingsRequest** | [**AddEmbeddingsRequest**](AddEmbeddingsRequest.md)|  | 

### Return type

[**AddEmbeddingsResponse**](AddEmbeddingsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **commonEmbeddersApiV1EmbeddingsServiceCommonEmbeddersGet**
> BuiltList<CommonEmbedder> commonEmbeddersApiV1EmbeddingsServiceCommonEmbeddersGet()

Get a list of common embedder names support by the server

Get a list of commonly used embedder names

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getEmbeddingsApi();

try {
    final response = api.commonEmbeddersApiV1EmbeddingsServiceCommonEmbeddersGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling EmbeddingsApi->commonEmbeddersApiV1EmbeddingsServiceCommonEmbeddersGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;CommonEmbedder&gt;**](CommonEmbedder.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **embedApiV1EmbeddingsServiceEmbedPost**
> StartTaskResponse embedApiV1EmbeddingsServiceEmbedPost(embedRequest)

Calculate embeddings

Submit sequences for embedding calculation using specified embedder model

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getEmbeddingsApi();
final EmbedRequest embedRequest = ; // EmbedRequest | 

try {
    final response = api.embedApiV1EmbeddingsServiceEmbedPost(embedRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling EmbeddingsApi->embedApiV1EmbeddingsServiceEmbedPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **embedRequest** | [**EmbedRequest**](EmbedRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMissingEmbeddingsApiV1EmbeddingsServiceGetMissingEmbeddingsPost**
> GetMissingEmbeddingsResponse getMissingEmbeddingsApiV1EmbeddingsServiceGetMissingEmbeddingsPost(getMissingEmbeddingsRequest)

Check missing embeddings

Check which sequences are missing embeddings for a given embedder and reduction setting

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getEmbeddingsApi();
final GetMissingEmbeddingsRequest getMissingEmbeddingsRequest = ; // GetMissingEmbeddingsRequest | 

try {
    final response = api.getMissingEmbeddingsApiV1EmbeddingsServiceGetMissingEmbeddingsPost(getMissingEmbeddingsRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling EmbeddingsApi->getMissingEmbeddingsApiV1EmbeddingsServiceGetMissingEmbeddingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **getMissingEmbeddingsRequest** | [**GetMissingEmbeddingsRequest**](GetMissingEmbeddingsRequest.md)|  | 

### Return type

[**GetMissingEmbeddingsResponse**](GetMissingEmbeddingsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

