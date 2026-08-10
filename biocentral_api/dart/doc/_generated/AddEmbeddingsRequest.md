# biocentral_api.model.AddEmbeddingsRequest

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name             | Type       | Description                                    | Notes |
| ---------------- | ---------- | ---------------------------------------------- | ----- |
| **embedderName** | **String** | Name of the embedder model to use              |
| **h5Bytes**      | **String** | Base64 encoded HDF5 file containing embeddings |
| **sequences**    | **String** | JSON string containing sequence data           |
| **reduced**      | **bool**   | Whether these are reduced embeddings           |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
