import random
import threading

from hashlib import md5
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
    async def get_random_user_id(req: Request) -> str:
        """Must only be used to disable rate limiting for debug mode"""
        return md5(
            f"user_id_{random.randint(0, 1000000000)}_{str(req.keys())}".encode()
        ).hexdigest()

    @staticmethod
    async def get_user_id_from_request(req: Request) -> str:
        forwarded = req.headers.get("X-Forwarded-For")
        if forwarded:
            return forwarded.split(",")[0]
        client = req.client.host if req.client else "unknown"
        return client
