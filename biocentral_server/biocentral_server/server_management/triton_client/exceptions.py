"""Custom exceptions for Triton Inference Server client."""


class TritonError(Exception):
    """Base exception for all Triton-related errors."""

    pass


class TritonConnectionError(TritonError):
    """Raised when connection to Triton server fails."""

    pass


class TritonTimeoutError(TritonError):
    """Raised when a Triton request times out."""

    pass


class TritonModelError(TritonError):
    """Raised when a model is not found or cannot be loaded."""

    pass


class TritonInferenceError(TritonError):
    """Raised when inference fails."""

    pass


class TritonResourceExhaustionError(TritonError):
    """Raised when Triton resources are exhausted (e.g., connection pool)."""

    pass
