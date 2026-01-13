# biocentral_api.api.BiocentralServiceApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**statsApiV1BiocentralServiceStatsGet**](BiocentralServiceApi.md#statsapiv1biocentralservicestatsget) | **GET** /api/v1/biocentral_service/stats/ | Stats
[**taskStatusApiV1BiocentralServiceTaskStatusTaskIdGet**](BiocentralServiceApi.md#taskstatusapiv1biocentralservicetaskstatustaskidget) | **GET** /api/v1/biocentral_service/task_status/{task_id} | Task Status
[**taskStatusResumedApiV1BiocentralServiceTaskStatusResumedTaskIdGet**](BiocentralServiceApi.md#taskstatusresumedapiv1biocentralservicetaskstatusresumedtaskidget) | **GET** /api/v1/biocentral_service/task_status_resumed/{task_id} | Task Status Resumed
[**welcomeMessageApiV1BiocentralServiceWelcomeMessageGet**](BiocentralServiceApi.md#welcomemessageapiv1biocentralservicewelcomemessageget) | **GET** /api/v1/biocentral_service/welcome_message | Welcome Message


# **statsApiV1BiocentralServiceStatsGet**
> JsonObject statsApiV1BiocentralServiceStatsGet()

Stats

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getBiocentralServiceApi();

try {
    final response = api.statsApiV1BiocentralServiceStatsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling BiocentralServiceApi->statsApiV1BiocentralServiceStatsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **taskStatusApiV1BiocentralServiceTaskStatusTaskIdGet**
> TaskStatusResponse taskStatusApiV1BiocentralServiceTaskStatusTaskIdGet(taskId)

Task Status

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getBiocentralServiceApi();
final String taskId = taskId_example; // String | 

try {
    final response = api.taskStatusApiV1BiocentralServiceTaskStatusTaskIdGet(taskId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BiocentralServiceApi->taskStatusApiV1BiocentralServiceTaskStatusTaskIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  | 

### Return type

[**TaskStatusResponse**](TaskStatusResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **taskStatusResumedApiV1BiocentralServiceTaskStatusResumedTaskIdGet**
> TaskStatusResponse taskStatusResumedApiV1BiocentralServiceTaskStatusResumedTaskIdGet(taskId)

Task Status Resumed

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getBiocentralServiceApi();
final String taskId = taskId_example; // String | 

try {
    final response = api.taskStatusResumedApiV1BiocentralServiceTaskStatusResumedTaskIdGet(taskId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BiocentralServiceApi->taskStatusResumedApiV1BiocentralServiceTaskStatusResumedTaskIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taskId** | **String**|  | 

### Return type

[**TaskStatusResponse**](TaskStatusResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **welcomeMessageApiV1BiocentralServiceWelcomeMessageGet**
> JsonObject welcomeMessageApiV1BiocentralServiceWelcomeMessageGet()

Welcome Message

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getBiocentralServiceApi();

try {
    final response = api.welcomeMessageApiV1BiocentralServiceWelcomeMessageGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling BiocentralServiceApi->welcomeMessageApiV1BiocentralServiceWelcomeMessageGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

