import unittest
from importlib import resources

class AutoEvalTests(unittest.TestCase):

    def test_auto_eval_configs_exist(self):
        with resources.open_text('autoeval.configsbank', 'aav.yml') as config_file:
            config_content = config_file.read()

        self.assertTrue(config_content is not None)


if __name__ == '__main__':
    unittest.main()
