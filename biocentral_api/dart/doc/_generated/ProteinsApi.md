# biocentral_api.api.ProteinsApi

## Load the API package

```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

| Method                                                                                                                              | HTTP request                               | Description            |
| ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ | ---------------------- |
| [**taxonomyApiV1ProteinServiceTaxonomyPost**](ProteinsApi.md#taxonomyapiv1proteinservicetaxonomypost)                               | **POST** /api/v1/protein_service/taxonomy/ | Retrieve taxonomy data |
| [**triggerProteinClusteringApiV1ProteinServiceClusterPost**](ProteinsApi.md#triggerproteinclusteringapiv1proteinserviceclusterpost) | **POST** /api/v1/protein_service/cluster/  | Calculate clustering   |

# **taxonomyApiV1ProteinServiceTaxonomyPost**

> TaxonomyResponse taxonomyApiV1ProteinServiceTaxonomyPost(taxonomyRequest)

Retrieve taxonomy data

Retrieve taxonomy data for a list of taxonomy ids

### Example

```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getProteinsApi();
final TaxonomyRequest taxonomyRequest = ; // TaxonomyRequest |

try {
    final response = api.taxonomyApiV1ProteinServiceTaxonomyPost(taxonomyRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProteinsApi->taxonomyApiV1ProteinServiceTaxonomyPost: $e\n');
}
```

### Parameters

| Name                | Type                                      | Description | Notes |
| ------------------- | ----------------------------------------- | ----------- | ----- |
| **taxonomyRequest** | [**TaxonomyRequest**](TaxonomyRequest.md) |             |

### Return type

[**TaxonomyResponse**](TaxonomyResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **triggerProteinClusteringApiV1ProteinServiceClusterPost**

> StartTaskResponse triggerProteinClusteringApiV1ProteinServiceClusterPost(clusteringRequest)

Calculate clustering

Submit sequences for clustering with pymmseqs

### Example

```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getProteinsApi();
final ClusteringRequest clusteringRequest = ; // ClusteringRequest |

try {
    final response = api.triggerProteinClusteringApiV1ProteinServiceClusterPost(clusteringRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProteinsApi->triggerProteinClusteringApiV1ProteinServiceClusterPost: $e\n');
}
```

### Parameters

| Name                  | Type                                          | Description | Notes |
| --------------------- | --------------------------------------------- | ----------- | ----- |
| **clusteringRequest** | [**ClusteringRequest**](ClusteringRequest.md) |             |

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
