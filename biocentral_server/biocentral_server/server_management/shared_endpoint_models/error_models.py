from typing import Optional
from pydantic import BaseModel


class ErrorResponse(BaseModel):
    error: str
    error_type: str
    details: Optional[str] = None
    error_code: Optional[int] = None


class NotFoundErrorResponse(ErrorResponse):
    error_type: str = "not_found"
