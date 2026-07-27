# biocentral_api.model.ResearchStats

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**totalSequencesToday** | **int** | Total number of sequences uploaded in the last 24 hours | 
**totalSequencesAllTime** | **int** | Total number of sequences uploaded in all time | 
**avgSequenceLength** | **num** | Average length of sequences uploaded | 
**aaDistribution** | **BuiltMap&lt;String, int&gt;** | Distribution of amino acids in the sequences | 
**topEmbedders** | **BuiltMap&lt;String, num&gt;** | Top embedders based on usage | 
**topPredictors** | **BuiltMap&lt;String, num&gt;** | Top prediction models based on usage | 
**updatedAt** | [**DateTime**](DateTime.md) | Timestamp of the last update | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


