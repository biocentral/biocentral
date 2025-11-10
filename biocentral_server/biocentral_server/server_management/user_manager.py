import threading

from typing import Dict
from fastapi import Request

_user_dict: Dict = {"n_total_requests": 0}
_lock = threading.Lock()


class UserManager:
    @staticmethod
    def check_request(req: Request):
        with _lock:
            _user_dict["n_total_requests"] += 1

    @staticmethod
    def get_total_number_of_requests_since_start() -> int:
        with _lock:
            return _user_dict["n_total_requests"]

    @staticmethod
    def get_user_id_from_request(req: Request) -> str:
        forwarded = req.headers.get("X-Forwarded-For")
        if forwarded:
            return forwarded.split(",")[0]
        client = req.client.host if req.client else "unknown"
        return client
