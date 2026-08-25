from typing import Callable, Dict, List, Tuple, Union
import numpy as np
from scipy import stats


def compute_confidence_interval(
    data: Union[List[float], np.ndarray],
    confidence: float = 0.95,
) -> Tuple[float, float, float]:
    data = np.asarray(data)
    n = len(data)
    if n < 2:
        raise ValueError(f"Need at least 2 data points for CI, got {n}")

    mean = np.mean(data)
    std_err = stats.sem(data)
    t_value = stats.t.ppf((1 + confidence) / 2, df=n - 1)
    margin = t_value * std_err

    return float(mean), float(mean - margin), float(mean + margin)


def compute_cohens_d(
    group1: Union[List[float], np.ndarray],
    group2: Union[List[float], np.ndarray],
) -> float:
    group1 = np.asarray(group1)
    group2 = np.asarray(group2)

    n1, n2 = len(group1), len(group2)
    var1, var2 = np.var(group1, ddof=1), np.var(group2, ddof=1)

    # Pooled standard deviation
    pooled_std = np.sqrt(((n1 - 1) * var1 + (n2 - 1) * var2) / (n1 + n2 - 2))

    if pooled_std == 0:
        return 0.0

    return float((np.mean(group1) - np.mean(group2)) / pooled_std)


def interpret_cohens_d(d: float) -> str:
    abs_d = abs(d)
    if abs_d < 0.2:
        return "negligible"
    elif abs_d < 0.5:
        return "small"
    elif abs_d < 0.8:
        return "medium"
    else:
        return "large"


def derive_significance_threshold(
    null_distances: Union[List[float], np.ndarray],
    k: float = 3.0,
) -> Dict[str, float]:
    null_distances = np.asarray(null_distances)
    null_mean = float(np.mean(null_distances))
    null_std = float(np.std(null_distances, ddof=1))
    threshold = null_mean + k * null_std

    return {
        "threshold": threshold,
        "null_mean": null_mean,
        "null_std": null_std,
        "k": k,
        "n_samples": len(null_distances),
    }


def run_with_replicates(
    fn: Callable[[], float],
    n_replicates: int = 30,
    seed_base: int = 42,
) -> Dict[str, Union[float, List[float], Tuple[float, float, float]]]:
    import random

    values = []
    for i in range(n_replicates):
        # Set seed per replicate for reproducibility
        random.seed(seed_base + i)
        np.random.seed(seed_base + i)
        try:
            import torch

            torch.manual_seed(seed_base + i)
        except ImportError:
            pass

        values.append(fn())

    values_arr = np.array(values)
    mean, ci_lower, ci_upper = compute_confidence_interval(values_arr)

    return {
        "values": values,
        "mean": mean,
        "std": float(np.std(values_arr, ddof=1)),
        "ci_95": (mean, ci_lower, ci_upper),
        "min": float(np.min(values_arr)),
        "max": float(np.max(values_arr)),
    }


def is_significantly_different(
    observed: float,
    null_result: Dict[str, float],
) -> bool:
    return observed > null_result["threshold"]


def mann_whitney_test(
    group1: Union[List[float], np.ndarray],
    group2: Union[List[float], np.ndarray],
    alternative: str = "two-sided",
) -> Dict[str, float]:
    group1 = np.asarray(group1)
    group2 = np.asarray(group2)

    statistic, p_value = stats.mannwhitneyu(group1, group2, alternative=alternative)

    # Rank-biserial correlation as effect size
    n1, n2 = len(group1), len(group2)
    r = 1 - (2 * statistic) / (n1 * n2)

    return {
        "statistic": float(statistic),
        "p_value": float(p_value),
        "effect_size_r": float(r),
    }


def summarize_distribution(
    data: Union[List[float], np.ndarray],
    name: str = "data",
) -> str:
    data = np.asarray(data)
    mean, ci_lower, ci_upper = compute_confidence_interval(data)

    lines = [
        f"{name} distribution (n={len(data)}):",
        f"  Mean: {mean:.6f} (95% CI: [{ci_lower:.6f}, {ci_upper:.6f}])",
        f"  Std:  {np.std(data, ddof=1):.6f}",
        f"  Min:  {np.min(data):.6f}, Max: {np.max(data):.6f}",
        f"  Median: {np.median(data):.6f}",
    ]
    return "\n".join(lines)
