import torch
import gpytorch

from typing import Literal, Optional
from gpytorch.means import LinearMean
from gpytorch.kernels import ScaleKernel, RBFKernel
from gpytorch.likelihoods import DirichletClassificationLikelihood, GaussianLikelihood

from ..utils import get_logger

logger = get_logger(__name__)


class GPModel(gpytorch.models.ExactGP):
    def __init__(
        self,
        train_x: torch.Tensor,
        train_y,
        likelihood,
        num_classes: Optional[int] = None,
    ):
        super().__init__(train_x, train_y, likelihood)

        batch_shape = torch.Size((num_classes,)) if num_classes else torch.Size()

        self.mean_module = LinearMean(train_x.shape[-1], batch_shape=batch_shape)
        self.covar_module = ScaleKernel(
            RBFKernel(batch_shape=batch_shape), batch_shape=batch_shape
        )

    def forward(self, x):
        mean_x = self.mean_module(x)
        covar_x = self.covar_module(x)
        return gpytorch.distributions.MultivariateNormal(mean_x, covar_x)


def create_gp_model_and_likelihood(
    train_set: dict,
    task_type: Literal["classification", "regression"],
    device: torch.device,
):
    """Factory function to create model and likelihood based on task type."""
    if task_type == "classification":
        likelihood = DirichletClassificationLikelihood(
            train_set["y"], learn_additional_noise=True
        ).to(device=device)
        model = GPModel(
            train_set["X"],
            likelihood.transformed_targets,
            likelihood,
            num_classes=likelihood.num_classes,
        ).to(device=device)
        targets = likelihood.transformed_targets
    else:  # regression
        likelihood = GaussianLikelihood().to(device=device)
        model = GPModel(train_set["X"], train_set["y"], likelihood).to(device=device)
        targets = train_set["y"]

    return model, likelihood, targets


def train_gp_model(
    train_set: dict,
    task_type: Literal["classification", "regression"],
    lr: float = 0.3,
    epoch: int = 400,
    device: torch.device = torch.device("cpu"),
    verbose: bool = True,
):
    """Unified training function for GP classification and regression models."""
    logger.info(f"Training GP {task_type} model on device: {device}")

    # Create model and likelihood based on task type
    model, likelihood, targets = create_gp_model_and_likelihood(
        train_set, task_type, device
    )

    # Set to training mode
    model.train()
    likelihood.train()

    # Setup optimizer and loss
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    mll = gpytorch.mlls.ExactMarginalLogLikelihood(likelihood, model)

    # Training loop
    print_interval = max(1, epoch // 10)
    losses = []

    for i in range(epoch):
        optimizer.zero_grad()
        output = model(train_set["X"])

        # Calculate loss (classification needs .sum())
        loss = -mll(output, targets)
        if task_type == "classification":
            loss = loss.sum()

        loss.backward()
        optimizer.step()

        # Store and log
        current_loss = loss.item()
        losses.append(current_loss)

        if verbose and (i % print_interval == 0 or i == epoch - 1):
            log_training_progress(
                i, epoch, current_loss, model, likelihood, train_set, task_type
            )

    # Set to evaluation mode
    model.eval()
    likelihood.eval()

    return model, likelihood


def log_training_progress(
    iteration: int,
    total_epochs: int,
    loss: float,
    model,
    likelihood,
    train_set: dict,
    task_type: str,
):
    """Helper function to log training progress."""
    # Get lengthscale (common to both)
    lengthscale = model.covar_module.base_kernel.lengthscale.mean().item()

    # Get noise (different access patterns)
    if task_type == "classification":
        noise = likelihood.second_noise_covar.noise.mean().item()
        logger.info(
            f"Iter {iteration + 1}/{total_epochs} - Loss: {loss:.3f}   "
            f"lengthscale: {lengthscale:.3f}   noise: {noise:.3f}"
        )
    else:  # regression
        noise = likelihood.noise.item()

        # Calculate MSE for regression
        with torch.no_grad():
            model.eval()
            preds = model(train_set["X"]).mean
            mse = torch.mean((preds - train_set["y"]) ** 2).item()
            model.train()

        logger.info(
            f"Iter {iteration + 1}/{total_epochs} - Loss: {loss:.4f}, MSE: {mse:.4f}, "
            f"lengthscale: {lengthscale:.4f}, noise: {noise:.4f}"
        )


def marginalization(mvn_dist):
    return torch.distributions.Normal(
        mvn_dist.mean, mvn_dist.covariance_matrix.diag().sqrt()
    )


def mc_sampling(mvn_dist, lb, ub, n_samples=100000):
    """
    Calculate probability using Monte Carlo sampling.
    Args:
        mvn_dist: gpytorch.distributions.MultivariateNormal
        lb: torch.Tensor lower bounds
        ub: torch.Tensor upper bounds
        n_samples: Number of samples to use
    Returns:
        probability: (dim,)
    """
    with torch.no_grad():
        samples = mvn_dist.sample(torch.Size([n_samples]))
        prob = ((samples >= lb) & (samples <= ub)).float().mean(dim=0)
    return prob
