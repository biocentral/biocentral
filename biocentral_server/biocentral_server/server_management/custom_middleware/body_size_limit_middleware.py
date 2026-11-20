import os

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse


class BodySizeLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        default_max_body = 50 * 1024 * 1024
        self.max_body = int(os.environ.get("MAX_FILE_SIZE", default_max_body))

    async def dispatch(self, request, call_next):
        content_length = request.headers.get("content-length")
        if content_length is not None:
            try:
                declared_length = int(content_length)
            except ValueError:
                return JSONResponse({"detail": "Invalid Content-Length header"}, status_code=400)
            if declared_length < 0:
                return JSONResponse({"detail": "Invalid Content-Length header"}, status_code=400)
            if declared_length > self.max_body:
                return self._too_large_response()

        body_chunks = []
        body_size = 0
        async for chunk in request.stream():
            body_size += len(chunk)
            if body_size > self.max_body:
                return self._too_large_response()
            body_chunks.append(chunk)

        request._body = b"".join(body_chunks)
        return await call_next(request)

    def _too_large_response(self):
        return JSONResponse(
            {"detail": "Request body too large", "max_body_bytes": self.max_body},
            status_code=413,
        )
