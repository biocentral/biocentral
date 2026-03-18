import unittest

from biocentral_api import batched

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


if __name__ == '__main__':
    unittest.main()
