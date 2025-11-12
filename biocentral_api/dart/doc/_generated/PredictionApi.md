# biocentral_api.api.PredictionApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**modelMetadataApiV1PredictionServiceModelMetadataGet**](PredictionApi.md#modelmetadataapiv1predictionservicemodelmetadataget) | **GET** /api/v1/prediction_service/model_metadata | Get predict model metadata
[**predictApiV1PredictionServicePredictPost**](PredictionApi.md#predictapiv1predictionservicepredictpost) | **POST** /api/v1/prediction_service/predict | Submit protein sequence prediction job


# **modelMetadataApiV1PredictionServiceModelMetadataGet**
> ModelMetadataResponse modelMetadataApiV1PredictionServiceModelMetadataGet()

Get predict model metadata

Get metadata for available prediction models

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPredictionApi();

try {
    final response = api.modelMetadataApiV1PredictionServiceModelMetadataGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PredictionApi->modelMetadataApiV1PredictionServiceModelMetadataGet: $e\n');
}
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

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **predictApiV1PredictionServicePredictPost**
> StartTaskResponse predictApiV1PredictionServicePredictPost(predictionRequest)

Submit protein sequence prediction job

Submit sequences for prediction using specified models and receive a task ID for tracking

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPredictionApi();
final PredictionRequest predictionRequest = ; // PredictionRequest | 

try {
    final response = api.predictApiV1PredictionServicePredictPost(predictionRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PredictionApi->predictApiV1PredictionServicePredictPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **predictionRequest** | [**PredictionRequest**](PredictionRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

