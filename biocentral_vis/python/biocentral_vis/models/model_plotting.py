import altair
import pandas as pd

from biotrainer_core.data_classes import BiotrainerModelResult


def plot_test_set_performance(model_result: BiotrainerModelResult, metric_name: str):
    test_results = model_result.test_results
    if len(test_results) == 0:
        raise ValueError("No test results found in the model result.")

    plot_data = []
    for test_set_name, test_result in test_results.items():
        btms = test_result.bootstrapped_metrics or []
        if len(btms) == 0:
            continue

        for bootstrapped_metric in btms:
            if bootstrapped_metric.name == metric_name:
                plot_data.append({
                    "test_set_name": test_set_name,
                    "metric_name": bootstrapped_metric.name,
                    "mean": bootstrapped_metric.mean,
                    "lower": bootstrapped_metric.lower,
                    "upper": bootstrapped_metric.upper,
                    "iterations": bootstrapped_metric.iterations,
                    "sample_size": bootstrapped_metric.sample_size,
                    "confidence_level": bootstrapped_metric.confidence_level,
                })

    if len(plot_data) == 0:
        raise ValueError(f"No bootstrapped metric named '{metric_name}' found in the model result.")

    df = pd.DataFrame(plot_data)
    df = df.sort_values("mean", ascending=True)

    chart = altair.Chart(
        data=df,
        title=f"Test Set Performance for {metric_name}",
    ).mark_bar().encode(
        x=altair.X("mean:Q", title=f"Mean {metric_name}"),
        y=altair.Y("test_set_name:N", title="Test Set", sort=list(df["test_set_name"])),
        color=altair.Color("test_set_name:N", legend=None),
        xError=altair.XError("lower:Q"),
        xError2="upper:Q",
        tooltip=[
            altair.Tooltip("test_set_name:N", title="Test Set"),
            altair.Tooltip("metric_name:N", title="Metric"),
            altair.Tooltip("mean:Q", title="Mean", format=".4f"),
            altair.Tooltip("lower:Q", title="Lower CI", format=".4f"),
            altair.Tooltip("upper:Q", title="Upper CI", format=".4f"),
            altair.Tooltip("sample_size:Q", title="Sample Size"),
            altair.Tooltip("iterations:Q", title="Bootstrap Iterations"),
        ],
    )

    metadata = {"metric_name": metric_name}
    return chart, metadata


def plot_loss_curves(model_result: BiotrainerModelResult, cv_split: str = "hold_out"):
    training_result = model_result.training_results.get(cv_split)
    if not training_result:
        raise ValueError(f"No training result found for CV split '{cv_split}'.")
    training_losses = training_result.training_losses
    validation_losses = training_result.validation_losses

    # Prepare data for both training and validation losses
    training_df = pd.DataFrame({
        'epoch': range(len(training_losses)),
        'loss': training_losses,
        'type': 'Training'
    })

    validation_df = pd.DataFrame({
        'epoch': range(len(validation_losses)),
        'loss': validation_losses,
        'type': 'Validation'
    })

    # Combine both datasets
    combined_df = pd.concat([training_df, validation_df], ignore_index=True)

    chart = altair.Chart(combined_df).mark_line().encode(
        x=altair.X("epoch:O", title="Epoch"),
        y=altair.Y("loss:Q", title="Loss"),
        color=altair.Color("type:N", title="Loss Type"),
        tooltip=[
            altair.Tooltip("epoch:O", title="Epoch"),
            altair.Tooltip("loss:Q", title="Loss"),
            altair.Tooltip("type:N", title="Type"),
        ],
    )

    metadata = {"cv_split": cv_split}
    return chart, metadata
    