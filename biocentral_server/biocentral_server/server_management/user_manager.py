from typing import Dict
from flask import Request


_user_dict: Dict = {"n_total_requests": 0}


class UserManager:

    @staticmethod
    def check_request(req: Request):
        _user_dict["n_total_requests"] += 1

    @staticmethod
    def get_total_number_of_requests_since_start() -> int:
        return _user_dict["n_total_requests"]

    @staticmethod
    def get_user_id_from_request(req: Request) -> str:
        return str(req.remote_addr)
