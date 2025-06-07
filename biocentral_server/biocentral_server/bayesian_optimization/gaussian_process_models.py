import torch
import gpytorch

from gpytorch.means import ConstantMean, LinearMean
from gpytorch.kernels import ScaleKernel, RBFKernel
from gpytorch.likelihoods import DirichletClassificationLikelihood, GaussianLikelihood

from ..utils import get_logger

logger = get_logger(__name__)


class GPRegressionModel(gpytorch.models.ExactGP):
    def __init__(self, train_x: torch.Tensor, train_y, likelihood):
        super(GPRegressionModel, self).__init__(train_x, train_y, likelihood)
        # self.mean_module = ConstantMean()
        self.mean_module = LinearMean(train_x.shape[-1])
        self.covar_module = ScaleKernel(RBFKernel())

    def forward(self, x):
        mean_x = self.mean_module(x)
        covar_x = self.covar_module(x)
        return gpytorch.distributions.MultivariateNormal(mean_x, covar_x)


class GPClassificationModel(gpytorch.models.ExactGP):
    def __init__(self, train_x: torch.Tensor, train_y, likelihood, num_classes):
        # initialize exactgp
        super(GPClassificationModel, self).__init__(train_x, train_y, likelihood)
        # self.mean_module = ConstantMean(batch_shape=torch.Size((num_classes,)))
        self.mean_module = LinearMean(train_x.shape[-1], batch_shape=torch.Size((num_classes,)))
        self.covar_module = ScaleKernel(
            RBFKernel(batch_shape=torch.Size((num_classes,))),
            batch_shape=torch.Size((num_classes,)),
        )
        # RBFKernel(lengthscale_constraint=gpytorch.constraints.Interval(0.1, 2.0), batch_shape=torch.Size((num_classes,))),

    def forward(self, x: torch.Tensor):
        mean_x = self.mean_module(x)
        covar_x = self.covar_module(x)
        return gpytorch.distributions.MultivariateNormal(mean_x, covar_x)


def train_gp_classification_model(train_set: dict, lr: float = 0.3, epoch: int = 140, device: str = "cpu"):
    device = torch.device(device)
    logger.info(f"Training on device: {device}")
    likelihood = DirichletClassificationLikelihood(
        train_set["y"], learn_additional_noise=True
    ).to(device=device)
    # transform class into num_classes separate GPs
    # shape: (num_classes, num_sample)
    model = GPClassificationModel(train_set["X"], likelihood.transformed_targets, likelihood,
                                  num_classes=likelihood.num_classes).to(device=device)
    model.train()
    likelihood.train()
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    mll = gpytorch.mlls.ExactMarginalLogLikelihood(likelihood, model)
    for i in range(epoch):
        # Zero gradients from previous iteration
        optimizer.zero_grad()
        # Output from model
        output = model(train_set["X"])
        # Calc loss and backprop gradients
        loss = -mll(output, likelihood.transformed_targets).sum()
        loss.backward()
        if i % (epoch // 10) == 0:
            logger.info('Iter %d/%d - Loss: %.3f   lengthscale: %.3f   noise: %.3f' % (
                i + 1, epoch, loss.item(),
                model.covar_module.base_kernel.lengthscale.mean().item(),
                model.likelihood.second_noise_covar.noise.mean().item()
            ))
        optimizer.step()
    model.eval()
    likelihood.eval()
    return model, likelihood


def train_gp_regression_model(train_set: dict, lr: float = 0.3, epoch: int = 400, device: str = "cpu"):
    device = torch.device(device)
    logger.info(f"Training on device: {device}")
    likelihood = GaussianLikelihood().to(device=device)
    model = GPRegressionModel(train_set["X"], train_set["y"], likelihood).to(
        device=device
    )
    model.train()
    likelihood.train()
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    mll = gpytorch.mlls.ExactMarginalLogLikelihood(likelihood, model)
    print_interval = max(1, epoch // 10)  # Print 10 updates during training
    losses = []

    for i in range(epoch):
        optimizer.zero_grad()
        output = model(train_set["X"])
        loss = -mll(output, train_set["y"])
        loss.backward()
        optimizer.step()

        # Store loss
        current_loss = loss.item()
        losses.append(current_loss)

        if i % print_interval == 0 or i == epoch - 1:
            with torch.no_grad():
                model.eval()
                preds = model(train_set["X"]).mean
                mse = torch.mean((preds - train_set["y"]) ** 2).item()
                model.train()
            logger.info(
                f"Iter {i + 1}/{epoch} - Loss: {current_loss:.4f}, MSE: {mse:.4f}, "
                + f"lengthscale: {model.covar_module.base_kernel.lengthscale.item():.4f}, "
                + f"noise: {likelihood.noise.item():.4f}"
            )
    model.eval()
    likelihood.eval()
    return model, likelihood


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
