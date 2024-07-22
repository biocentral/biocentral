import logging
import tempfile
from pathlib import Path
from typing import List

from flask import request, jsonify, Blueprint
from hvi_toolkit.dataset_base_classes import DatasetPPIStandardized
from hvi_toolkit.evaluators import DatasetEvaluator
from hvi_toolkit.importer import get_supported_dataset_formats_with_docs, import_dataset_by_format, auto_detect_format
from hvi_toolkit.taxonomy import Taxonomy

from ..server_management import FileManager, UserManager, StorageFileType

logger = logging.getLogger(__name__)

ppi_service_route = Blueprint("ppi_service", __name__)


def __dataset_bias_test(dataset_evaluator: DatasetEvaluator, interactions: List, id2seq):
    test_statistic_bias, p_value_bias, _ = dataset_evaluator.calculate_dataset_bias(interactions)
    success, information = dataset_evaluator.evaluate_dataset_bias_test_result(test_statistic_bias=test_statistic_bias,
                                                                               p_value_bias=p_value_bias,
                                                                               do_print=False)
    return success, information, "", test_statistic_bias, p_value_bias


def __dataset_sequence_lengths_test(dataset_evaluator: DatasetEvaluator, interactions: List, id2seq):
    (average_length_positive, average_length_negative, positive_sequence_lengths,
     negative_sequence_lengths, test_statistic_length, p_value_length) = dataset_evaluator.check_sequence_lengths(
        interactions=interactions, id2seq=id2seq)
    success, information = dataset_evaluator.evaluate_sequence_length_test_result(average_length_positive,
                                                                                  average_length_negative,
                                                                                  positive_sequence_lengths,
                                                                                  negative_sequence_lengths,
                                                                                  test_statistic_length,
                                                                                  p_value_length, do_print=False)
    return success, information, "", test_statistic_length, p_value_length


def __dataset_bias_prediction(dataset_evaluator: DatasetEvaluator, interactions: List, id2seq):
    _, _, bias_predictor = dataset_evaluator.calculate_dataset_bias(interactions)
    test_metrics = dataset_evaluator.calculate_bias_predictions(bias_predictor, test_dataset=interactions, name="",
                                                                do_print=False)
    return "", "", test_metrics.to_json(), "", ""


def __dataset_contains_hubs(dataset_evaluator: DatasetEvaluator, interactions: List, id2seq):
    protein_hub_interactions, information = dataset_evaluator.check_protein_hubs(interactions=interactions,
                                                                                 do_print=False)
    return len(protein_hub_interactions) > 0, information, "", "", ""


# Test functions all must return success, information, test_metrics, test_statistic, p_value (can be "")
dataset_evaluator_tests = {
    "dataset_bias": {
        "function": __dataset_bias_test,
        "type": "binary",
        "requirements": ["containsPositivesAndNegatives"]
    },
    "sequence_lengths": {
        "function": __dataset_sequence_lengths_test,
        "type": "binary",
        "requirements": ["sequences", "containsPositivesAndNegatives"]
    },
    "bias_prediction": {
        "function": __dataset_bias_prediction,
        "type": "metrics",
        "requirements": ["containsPositivesAndNegatives"]
    },
    "protein_hubs": {
        "function": __dataset_contains_hubs,
        "type": "binary",
        "requirements": ["containsOnlyHVI"]
    }
}


# Endpoint to get available dataset formats from hvi_toolkit
@ppi_service_route.route('/ppi_service/formats', methods=['GET'])
def formats():
    dataset_formats = get_supported_dataset_formats_with_docs()
    return jsonify(dataset_formats)


@ppi_service_route.route('/ppi_service/auto_detect_format', methods=['POST'])
def auto_detect_format_by_header():
    format_data = request.get_json()
    header = format_data.get('header')

    try:
        format_str = auto_detect_format(header)
        return jsonify({"detected_format": format_str})
    except ValueError as e:
        logger.error(e)
        return jsonify({"error": str(e)})


@ppi_service_route.route('/ppi_service/dataset_tests/tests', methods=['GET'])
def tests():
    return jsonify({"dataset_tests":
                        {name: {key: value for key, value in values.items() if key != "function"}
                         for name, values in dataset_evaluator_tests.items()}})


@ppi_service_route.route('/ppi_service/dataset_tests/run_test', methods=['POST'])
def run_test():
    test_data = request.get_json()
    dataset_hash = test_data.get('hash')
    test_name = test_data.get('test')

    try:
        dataset_file_path = FileManager(user_id=UserManager.get_user_id_from_request(req=request)).get_file_path(
            dataset_hash, file_type=StorageFileType.SEQUENCES)
    except FileNotFoundError as e:
        logger.error(e)
        return jsonify({"error": str(e)})

    if test_name not in dataset_evaluator_tests.keys():
        error_message = "Given test is not available!"
        logger.error(error_message)
        return jsonify({"error": error_message})

    try:
        # TODO: Dataset Evaluation Options
        dataset_evaluator: DatasetEvaluator = DatasetEvaluator()
        id2seq, interaction_list, _, _, _ = dataset_evaluator.convert_biotrainer_fasta_to_interaction_list(
            str(dataset_file_path))

        success, information, test_metrics, test_statistic, p_value = map(str, dataset_evaluator_tests[test_name][
            "function"].__call__(dataset_evaluator,
                                 interaction_list, id2seq))

        return jsonify({"test_result": {"success": success, "information": information, "test_metrics": test_metrics,
                                        "test_statistic": test_statistic, "p_value": p_value,
                                        "significance_level": dataset_evaluator.significance}})
    except (ValueError, KeyError) as e:
        logger.error(e)
        return jsonify({"error": str(e)})


# Endpoint to import a dataset
@ppi_service_route.route('/ppi_service/import', methods=['POST'])
def import_dataset():
    import_data = request.get_json()
    # Validate and extract task parameters from the request data
    data_format = import_data.get('format')
    dataset_file = import_data.get('dataset')

    with tempfile.TemporaryDirectory() as tmp_dir_name:
        tmp_dataset_file_path = Path(tmp_dir_name) / data_format
        with open(tmp_dataset_file_path, "w") as tmp_dataset_file:
            tmp_dataset_file.write(dataset_file)

        try:
            ppi_std_dataset: DatasetPPIStandardized = import_dataset_by_format(dataset_path=tmp_dataset_file_path,
                                                                               format_str=data_format,
                                                                               taxonomy=Taxonomy())
            return jsonify({"imported_dataset": ppi_std_dataset.store()})
        except (ValueError, KeyError) as e:
            logger.error(e)
            return jsonify({"error": str(e)})
