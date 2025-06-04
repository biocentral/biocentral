## API specification

### train_and_inference
url: `POST /bayesian_optimization_service/training`
Launch Bayesian Optimization model training and inference.

This endpoint takes a configuration dictionary, validates it, and starts
    a Bayesian Optimization task that will:
1. Load sequence data from the specified database hash
2. Embed sequences using one-hot encoding
3. Train a Bayesian Optimization model with the specified parameters
4. Return a task ID for tracking progress and retrieving results

#### Request
POST with JSON body containing:
- `database_hash` (str): Identifier for the sequence database
- `model_type` (str): Type of model (currently only `gaussian_process`)
- `coefficient` (float): Non-negative factor controlling exploration vs. exploitation. Larger => more exploration. 
- `discrete` (bool): Whether target is discrete or continuous

Optional Arguments:
- `embedder_name` (str): name of embedder, default: `one_hot_encoding`
- `device` (str): device, option: `cuda`, default: `cpu`
- `feature_name` (str): case insensitive name of feature in description of `.fasta` file, default: `TARGET`

For discrete targets
- `discrete_labels` (list): All possible labels
- `discrete_targets` (list): Subset of labels that are targets

For continuous targets
- `optimization_mode` (str): mode selection 
    - options: `interval`, `value`, `maximize` and `minimize`
- when optimization_mode is `interval`: 
    - at least one of `target_lb :: float`, `target_ub :: float` should be in request
    - `target_lb < target_lb` when both provided
    - For unbounded interval, either set them to `+Infinity` and `-Infinity`, or not set
- when optimization_mode is `value`: 
    - `target_value :: float`


#### Returns
JSON with:
- `task_id` (str): Unique identifier for tracking the task
- `error` (str, optional): Error message if request is invalid
#### Examples
Example for float / bool as string
``` json
{
  "database_hash": "hello",
  "model_type": "gaussian_process",
  "discrete": "false",
  "optimization_mode": "interval",
  "target_lb": "40",
  "target_ub": "50",
  "coefficient": "5"
}
```
Example for regression with interval target:
``` json
{
  "database_hash": "hello",
  "model_type": "gaussian_process",
  "discrete": "false",
  "optimization_mode": "interval",
  "target_lb": 40,
  "target_ub": 50,
  "coefficient": 5
}
```

Example for regression with maximize:
``` json
{
  "database_hash": "hello",
  "model_type": "gaussian_process",
  "discrete": "false",
  "optimization_mode": "maximize",
  "coefficient": 5
}
```

Example for regression with value target:
``` json
{
  "database_hash": "hello",
  "model_type": "gaussian_process",
  "discrete": "false",
  "optimization_mode": "value",
  "target_value": 40,
  "coefficient": 5
}
```
Example for discrete target:
``` json
{
    "database_hash": "hello",
    "model_type": "gaussian_process",
    "discrete": true,
    "discrete_labels": ["red", "green", "blue", "yellow"],
    "discrete_targets": ["red", "yellow"],
    "coefficient": 0.7
}
```
Example response:
``` json
{"task_id": "biocentral-bayesian_optimization-a2ec2679c8b88fa808583ccd39e6adac"}
```
Example error:
``` json
{"error": "[verify_config]: targets should be true subset of labels"}
```
### model_results
url: `POST bayesian_optimization_service/model_results`

Fetch recommendation score for each sequence

This endpoint checks if specified task has completed.
If so, returns sequences ordered descending by its score.

#### Request
POST with JSON body containing:
- `database_hash` (str): Identifier for the sequence database
- `task_id` (str): Task identifier returned from the training endpoint

#### Returns
If successful: JSON array of ranked results, each containing:
- `id` (str): Sequence identifier
- `mean` (float): Optimization score (higher is better)
- `uncertainty` (float): Optimization score (higher is better)
- `score` (float): Optimization score (higher is better)
- `sequence` (str): The sequence data

If fail:
- JSON with error message explaining why results aren't available


#### Examples
Example request
``` json
{
    "database_hash": "hello",
    "task_id": "biocentral-bayesian_optimization-a2ec2679c8b88fa808583ccd39e6adac"
}
```
Example response
``` json
{
    "result": [
        {
            "id": "EJF35357.1",
            "mean": 0.790058,
            "uncertainty": 0.790058,
            "score": 0.790058,
            "sequence": "MSEEIRYLAGVVAELKRRLDAAPS..."
        },
        {
            "id": "YP_096167.1",
            "mean": 0.790058,
            "uncertainty": 0.790058,
            "score": 0.790058,
            "sequence": "MRTLFYSQLMYEAAKRQPHPHRCA..."
        }
    ]
}
```
## Appendix: Regression with Gaussian Process

#### Bayesian Regression
##### Modeling
Suppose we have observation $\mathcal{D}=\{(x_i,y_i)\}_N$, and model the Y as 

$y=x^Tw+\epsilon$, where $\epsilon \sim \mathcal{N}(0,\delta)$

Bayesian approach is about obtaining the weight distribution $p(w|X, Y)$. 

We know from independence of w and X, and bayseian theorem, posterior distribution is propotional to <u>likelihood</u> (observation distribution given weight), and <u>prior</u> belief,


$$
p(w|X, Y) \propto p(Y|X,w)p(w|X)=p(Y|X,w)p(w)
$$


##### Training

To get weight posterior distribution, we need to compute likelihood and combine it with prior.
First, likelihood distribution of vector Y can be derived from distribution of iid. distributed $y_i$ and some vectorization technique.


$$
\begin{aligned}
p(Y|X,w)
&=\prod_{i=0}^N p(y_i|x_i,w)\\
&=\prod_{i=0}^N\frac{1}{\sqrt{2\pi}\sigma}\exp{(-\frac{(y_i-x_i^Tw)^2}{2\sigma^2})}\\
&=\frac{1}{(2\pi)^{N/2}\sigma^N}\exp{(-\sum_{i=1}^N
\frac{(y_i-x_i^Tw)^2}{2\sigma^2})}\\
&=\frac{1}{(2\pi)^{N/2}\sigma^N}\exp{(-\frac{1}{2\sigma^2}\sum_{i=1}^N
(y_i-x_i^Tw)^2)}\\
&=\frac{1}{(2\pi)^{N/2}\sigma^N}\exp{(-\frac{1}{2\sigma^2}
(Y-Xw)^T(Y-Xw)
)}\\
&=\mathcal{N}(Xw,\sigma^2 I)
\end{aligned}
$$


We assume $\mathbf{w}$ also follows multivariate normal distribution $\mathbf{w}\sim \mathcal{N}(0,\Sigma_w)$, and we know production of two gaussian is another gaussian. So posterior distribution is 


$$
w \mid y \sim \mathcal{N}(\mu_{\text{post}}, \Sigma_{\text{post}})
$$
with


$$
\Sigma_{\text{post}} = \left(\frac{1}{\sigma^2}X^\top X + \Sigma_w^{-1}\right)^{-1},\quad \mu_{\text{post}} = \Sigma_{\text{post}}\left(\frac{1}{\sigma^2}X^\top y\right).
$$


##### Inference

We have taken the bayesian approach to model weight as a distribution, so the inference based on weight is also a distribution
p() 
#### More expressiveness: Bayesian regression in feature space
Linear models are unable to fit non-linear target function. Inspired by Taylor's theorem that each continuous function can be approximated by a infinite series of polynomial, non-linear function can be approximated by linear regression on feature space constructed by n-order polynomials. 

As feature mapping depends only on X, all the derivations we made above still hold, except input X is replaced by features $\Phi$.


$$
\begin{aligned}
p(f_x|x_*,X,y) 
\sim \mathcal{N}(
    &\phi^{T}_*\Sigma_p(K+\sigma_n^2I)^ {-1}y, \\
    &\phi_*^T \Sigma_p \phi_* - \phi_*^T \Sigma_p{\phi} (K+\sigma_n^2I)^ {-1} \phi^T \Sigma_p \phi_*)
\end{aligned}
$$


Where $K=\Phi^T\Sigma_p\Phi$. 
Noticed feature space always enter in form of $\phi^T\Sigma_p\phi$, $\phi_*^T\Sigma_p\phi$, or $\phi_*^T\Sigma_p\phi_*$. 
To simplify computation, mapping and dot product can be unified into 
$$k(x,x')=\phi(x)^T\Sigma_p\phi(x')$$
Which is called kernel function. When an algorithm solely rely on terms of inner product in feature space, it can be lifted into feature space by replacing inner products with kernel function call. This is a common approach called kernel trick.

This technique is particularly valuable in situations where it is more convenient to compute the kernel than the feature vectors themselves. 

#### Bayesian Classification