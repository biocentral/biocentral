import os
import unittest
from unittest import mock

from biocentral_api import BiocentralAPI, batched
from biocentral_api._generated.rest import should_bypass_proxies


class TestProxyConfig(unittest.TestCase):
    """_make_configuration wires the proxy from the env (the chokepoint both the
    client and health-check paths use)."""

    PROXY = "http://proxy.example:8080"
    cases = [
        ("https from env", {"HTTPS_PROXY": PROXY}, "https://example.org", PROXY),
        ("no env", {}, "https://example.org", None),
        (
            "NO_PROXY bypass",
            {"HTTPS_PROXY": PROXY, "NO_PROXY": "example.org"},
            "https://example.org",
            None,
        ),
        (
            "scheme mismatch (https proxy, http url)",
            {"HTTPS_PROXY": PROXY},
            "http://localhost:9540",
            None,
        ),
    ]

    def test_proxy_from_env(self):
        for name, env, url, expected in self.cases:
            with self.subTest(name), mock.patch.dict(os.environ, env, clear=True):
                configuration = BiocentralAPI._make_configuration(url=url)
                effective_proxy = (
                    configuration.proxy
                    if configuration.proxy
                    and not should_bypass_proxies(
                        configuration.host, configuration.no_proxy or ""
                    )
                    else None
                )

                self.assertEqual(effective_proxy, expected)


class TestBatching(unittest.TestCase):
    def test_batching(self):
        normal_case = [1, 2, 3, 4, 5]
        limit = 2
        batches = list(batched(normal_case, limit))
        self.assertEqual(len(batches), 3)
        self.assertEqual(batches[0], [1, 2])
        self.assertEqual(batches[1], [3, 4])
        self.assertEqual(batches[2], [5])

        empty_case = []
        batches = list(batched(empty_case, limit))
        self.assertEqual(len(batches), 0)

        large_case = list(range(1001))
        limit = 1000
        batches = list(batched(large_case, limit))
        self.assertEqual(len(batches), 2)
        self.assertEqual(len(batches[0]), 501)
        self.assertEqual(len(batches[1]), 500)

        limit = 2000
        batches = list(batched(large_case, limit))
        self.assertEqual(len(batches), 1)
        self.assertEqual(len(batches[0]), 1001)

        single_item_case = [42]
        limit = 1
        batches = list(batched(single_item_case, limit))
        self.assertEqual(len(batches), 1)
        self.assertEqual(batches[0], [42])

        exact_fit_case = [1, 2, 3, 4, 5, 6]
        limit = 3
        batches = list(batched(exact_fit_case, limit))
        self.assertEqual(len(batches), 2)
        self.assertEqual(batches[0], [1, 2, 3])
        self.assertEqual(batches[1], [4, 5, 6])

        small_limit_case = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        limit = 1
        batches = list(batched(small_limit_case, limit))
        self.assertEqual(len(batches), 10)
        self.assertEqual(batches[0], [1])
        self.assertEqual(batches[9], [10])

        large_limit_case = [1, 2, 3]
        limit = 100
        batches = list(batched(large_limit_case, limit))
        self.assertEqual(len(batches), 1)
        self.assertEqual(batches[0], [1, 2, 3])


class TestPerplexityClient(unittest.TestCase):
    def test_perplexity_dto_handler(self):
        from biocentral_api.clients.proteins_client import _PerplexityDTOHandler
        from biocentral_api._generated.models import TaskDTO, TaskStatus, PerplexityResult, ZeroShotMethod

        handler = _PerplexityDTOHandler()
        perp_res = PerplexityResult(method=ZeroShotMethod.PERPLEXITY, seq2perplexity={"seq1": 1.23})
        dtos = [
            TaskDTO(status=TaskStatus.FINISHED, perplexity_result=perp_res)
        ]
        result = handler.handle_result(dtos)
        self.assertEqual(result, perp_res)

        pending_dtos = [TaskDTO(status=TaskStatus.PENDING)]
        self.assertIsNone(handler.handle_result(pending_dtos))

    def test_biocentral_api_perplexity(self):
        from biocentral_api import BiocentralAPI
        api = BiocentralAPI(fixed_server_url="http://localhost:9540", local_only=True)
        with mock.patch("biocentral_api.clients.proteins_client.ProteinsClient.perplexity") as mock_perp:
            mock_perp.return_value = "mock_task"
            task = api.perplexity({"seq1": "MKTL"}, "facebook/esm2_t6_8M_UR50D")
            self.assertEqual(task, "mock_task")
            mock_perp.assert_called_once()


class TestTypeMappings(unittest.TestCase):
    def test_biotrainer_core_type_identity(self):
        import biocentral_api
        import biocentral_api._generated as gen
        import biocentral_api._generated.models as models
        import biotrainer_core.data_classes as core_dc

        # Ensure types exported at top-level biocentral_api match biotrainer_core exactly
        self.assertIs(biocentral_api.SequenceData, core_dc.SequenceData)
        self.assertIs(biocentral_api.Protocol, core_dc.Protocol)
        self.assertIs(biocentral_api.ZeroShotMethod, core_dc.ZeroShotMethod)
        self.assertIs(biocentral_api.BiotrainerModelResult, core_dc.BiotrainerModelResult)
        self.assertIs(biocentral_api.BiotrainerInferenceResult, core_dc.BiotrainerInferenceResult)
        self.assertIs(biocentral_api.BiotrainerModelUpdate, core_dc.BiotrainerModelUpdate)
        self.assertIs(biocentral_api.BiotrainerPrediction, core_dc.BiotrainerPrediction)
        self.assertIs(biocentral_api.TrainingResult, core_dc.TrainingResult)
        self.assertIs(biocentral_api.TestResult, core_dc.TestResult)
        self.assertIs(biocentral_api.DerivedValues, core_dc.DerivedValues)
        self.assertIs(biocentral_api.EpochMetrics, core_dc.EpochMetrics)
        self.assertIs(biocentral_api.BootstrappedMetric, core_dc.BootstrappedMetric)
        self.assertIs(biocentral_api.MetricEstimate, core_dc.MetricEstimate)
        self.assertIs(biocentral_api.EmbeddingStats, core_dc.EmbeddingStats)
        self.assertIs(biocentral_api.Mutation, core_dc.Mutation)

        # Ensure types in models/__init__.py and _generated/__init__.py match
        self.assertIs(models.TrainingResult, core_dc.TrainingResult)
        self.assertIs(models.TestResult, core_dc.TestResult)
        self.assertIs(models.DerivedValues, core_dc.DerivedValues)
        self.assertIs(models.EpochMetrics, core_dc.EpochMetrics)
        self.assertIs(models.BootstrappedMetric, core_dc.BootstrappedMetric)
        self.assertIs(models.MetricEstimate, core_dc.MetricEstimate)
        self.assertIs(models.BiotrainerModelUpdate, core_dc.BiotrainerModelUpdate)
        self.assertIs(models.BiotrainerPrediction, core_dc.BiotrainerPrediction)
        self.assertIs(models.EmbeddingStats, core_dc.EmbeddingStats)
        self.assertIs(models.Mutation, core_dc.Mutation)
        self.assertIs(models.Protocol, core_dc.Protocol)
        self.assertIs(models.SequenceData, core_dc.SequenceData)
        self.assertIs(models.ZeroShotMethod, core_dc.ZeroShotMethod)


if __name__ == "__main__":
    unittest.main()
