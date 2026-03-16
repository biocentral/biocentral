import random

from hashlib import md5
from fastapi import Request


class UserManager:
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
