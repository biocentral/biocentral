import os

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse


class BodySizeLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        default_max_body = 2 * 1024 * 1024 * 1024  # 2 GB
        self.max_body = int(os.environ.get("MAX_FILE_SIZE", default_max_body))

    async def dispatch(self, request, call_next):
        body = await request.body()
        len_body = len(body)
        if len_body > self.max_body:
            return JSONResponse(
                {
                    "detail": f"Request body too large ({len_body}), maximum: {self.max_body}"
                },
                status_code=413,
            )
        return await call_next(request)
