# biocentral_api.model.BiocentralServiceStats

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**usableCpuCount** | **int** | Number of usable CPU cores available to the process | 
**embeddingsDatabaseSize** | **String** | Current size of the embeddings database in MB | 
**totalTasks** | **int** | Total number of tasks submitted since server startup | 
**queueLength** | **int** | Current number of tasks queued for execution | 
**cudaAvailable** | **bool** | Whether CUDA GPU acceleration is available | 
**cudaDeviceNames** | **BuiltList&lt;String&gt;** | List of names of available CUDA devices | 
**cudaDeviceCount** | **int** | Number of available CUDA devices | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


