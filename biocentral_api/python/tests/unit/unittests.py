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


if __name__ == "__main__":
    unittest.main()
