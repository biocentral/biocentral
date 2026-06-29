import json

from biocentral_api import Prediction, ProjectionResult
from biotrainer_core.input_files import read_FASTA
from biotrainer_core.data_classes import BiotrainerModelResult

from biocentral_vis import BiocentralChart, BiocentralHighlight

assets_path = "../../../flutter/example/assets/"

dataset_path = "scl.fasta"
model_result_path = "scl_out.yml"
projection_result_path = "projection_result_scl.json"

### DATASET ###
scl_dataset = read_FASTA(dataset_path)

label_distribution_chart = BiocentralChart.label_distribution(read_FASTA(dataset_path))
label_distribution_chart.save("scl_label_distribution.svg")
label_distribution_chart.save_export(assets_path + "scl_label_distribution.json")


### Projections ###
with open(projection_result_path, "r") as f:
    projection_result = json.load(f)
    projection_result = ProjectionResult.model_validate(projection_result)
projection_result_chart = BiocentralChart.projection_result(projection_result, scl_dataset)
projection_result_chart.save("projection_result_scl.svg")

### MODEL ###

model_result = BiotrainerModelResult.from_file(model_result_path)

loss_curves_chart = BiocentralChart.model_loss_curve(model_result)
loss_curves_chart.save("scl_loss_curves.svg")
loss_curves_chart.save_export(assets_path + "scl_loss_curves.json")


model_test_set_performance_chart = BiocentralChart.model_test_set_performance(
    model_result,
    "accuracy"
)
model_test_set_performance_chart.save("scl_model_test_set_performance.svg")
model_test_set_performance_chart.save_export(assets_path + "scl_model_test_set_performance.json")

### PREDICTIONS ###

# Your data
sequence = "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKMKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKMKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEK"
prediction = Prediction(
    model_name="ProtT5-SecondaryStructure",
    prediction_name="Secondary Structure",
    value="CCCCHHHHHHHHHHHHHCCCEEEEECCCCCCCCCCCCCCCCHHHHHHHHHHHHCCCCHHHHHHHHHHHHHCCCEEEEECCCCCCCCCCCCCCCCHHHHHHHHHHHHCCCCHHHHHHHHHHHHHCCCEEEEECCCCCCCCCCCCCCCCHHHHHHHHHHHH",
    protocol="residue_to_class",
)

# Create and export
highlight = BiocentralHighlight.from_prediction(
    sequence=sequence,
    prediction=prediction,
    residues_per_line=60
)

highlight.save("sequence_highlight.svg")
highlight.save_export(assets_path + "sequence_highlight.json")