from typing import Callable, Dict
from biotrainer.bioengineer import BioEngineer
from biotrainer_core.data_classes import ZeroShotMethod
from ..server_management import TaskInterface, TaskDTO, TaskStatus
from ..server_management.shared_endpoint_models import PerplexityResult


class PerplexityTask(TaskInterface):
    """
    Task to compute (pseudo)perplexity of a given set of sequences.
    """

    def __init__(
            self,
            sequence_data: Dict[str, str],
            plm_name: str,
    ):
        self.sequence_data = sequence_data
        self.plm_name = plm_name

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        update_dto_callback(TaskDTO(status=TaskStatus.RUNNING))
        bioengineer = BioEngineer.from_name(self.plm_name)
        result_dict = {}

        supported_methods = bioengineer.model_wrapper.supported_methods()
        if ZeroShotMethod.PERPLEXITY in supported_methods:
            perplexity_method = ZeroShotMethod.PERPLEXITY
            for seq_id, seq in self.sequence_data.items():
                perplexity = bioengineer.model_wrapper._compute_perplexity(seq)
                result_dict[seq_id] = perplexity
        elif ZeroShotMethod.PSEUDOPERPLEXITY in supported_methods:
            perplexity_method = ZeroShotMethod.PSEUDOPERPLEXITY
            for seq_id, seq in self.sequence_data.items():
                pseudoperplexity = bioengineer.model_wrapper._compute_pseudoperplexity(seq)
                result_dict[seq_id] = pseudoperplexity
        else:
            return TaskDTO.errored(error=f"Neither {ZeroShotMethod.PERPLEXITY} nor "
                                         f"{ZeroShotMethod.PSEUDOPERPLEXITY} supported for model: {self.plm_name}!")

        return TaskDTO(status=TaskStatus.FINISHED, perplexity_result=PerplexityResult(method=perplexity_method,
                                                                                      seq2perplexity=result_dict))
