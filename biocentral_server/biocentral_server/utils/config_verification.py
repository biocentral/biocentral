from biotrainer.config import Configurator, ConfigurationException

from .format_utils import str2bool


def convert_config(config_dict: dict):
    # TODO Improve biotrainer and protspace config option handling to avoid this

    def _apply_config_conversion(v: str):
        import ast

        try:
            return ast.literal_eval(v)
        except Exception:
            if v.lower() in ["true", "false"]:
                return str2bool(v)
            return v

    config = {k: _apply_config_conversion(v) for k, v in config_dict.items()}
    return config


def verify_biotrainer_config(config_dict: dict):
    """Verify biotrainer configuration dict"""
    try:
        config = convert_config(config_dict)
        configurator = Configurator.from_config_dict(config)
        configurator.verify_config(ignore_file_checks=True)
        return config, ""
    except ConfigurationException as config_exception:
        return None, str(config_exception)
