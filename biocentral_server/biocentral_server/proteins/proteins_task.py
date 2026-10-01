import os
import shutil
import tempfile
from typing import Callable, Dict, List

from pymmseqs.commands import easy_cluster, easy_linclust
from ..server_management import TaskInterface, TaskDTO, TaskStatus

def run_pymmseqs_clustering(
        sequence_data: Dict[str, str], 
        sequence_identity_threshold: float = 0.3, 
) -> Dict[str, List[str]]: 
    """
    Direct synchronous MMseqs2 runner on CPU. "
    Takes sequence dict and threshold, returns rep_id -> [member_ids].
    """
    temp_dir = tempfile.mkdtemp(prefix="mmseqs_direct_")
    try: 
        temp_input_path = os.path.join(temp_dir, "input.fasta")
        temp_output_prefix = os.path.join(temp_dir, "mmseqs_out")

        with open(temp_input_path, "w") as temp_input: 
            for seq_id, seq in sequence_data.items(): 
                temp_input.write(f">{seq_id}\n{seq}\n")

        num_sequences = len(sequence_data)
        use_linclust = num_sequences > 50000

        if use_linclust: 
            easy_linclust(temp_input_path, 
                          temp_output_prefix, 
                          temp_dir, 
                          min_seq_id=sequence_identity_threshold, 
            )

        else: 
            easy_cluster(
                temp_input_path, 
                temp_output_prefix, 
                temp_dir, 
                min_seq_id=sequence_identity_threshold, 
            )
        tsv_file = f"{temp_output_prefix}_cluster.tsv"
        if not os.path.exists(tsv_file): 
            raise FileNotFoundError("MMseqs2 did not generate the expected TSV cluster file.")
        
        clustered_results: Dict[str, List[str]] = {}
        with open(tsv_file, "r") as f: 
            for line in f:
                parts = line.strip().split("\t")
                if len(parts) == 2: 
                    rep_id, member_id = parts[0], parts[1]
                    if rep_id not in clustered_results: 
                        clustered_results[rep_id] = []
                    clustered_results[rep_id].append(member_id)

        return clustered_results

    finally: 
        if os.path.exists(temp_dir): 
            shutil.rmtree(temp_dir, ignore_errors=True)

class ClusterSequencesTask(TaskInterface):
    """
    Task to cluster sequences via pymmseqs by converting an input dictionary
    to a temporary FASTA file, running the alignment, and clean-up.
    """

    def __init__(
        self,
        sequence_data: Dict[str, str],
        sequence_identity_threshold: float = 0.3,
    ):
        self.sequence_data = sequence_data
        self.sequence_identity_threshold = sequence_identity_threshold

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        # Set task status to RUNNING
        update_dto_callback(TaskDTO(status=TaskStatus.RUNNING))

        try: 
            clustered_results = run_pymmseqs_clustering(
                sequence_data=self.sequence_data, 
                sequence_identity_threshold=self.sequence_identity_threshold,
            )
            return TaskDTO(status=TaskStatus.FINISHED, clustered_data=clustered_results)
        except Exception as e: 
            print(f"Error during clustering execution: {str(e)}")
            return TaskDTO.errored(f"Clustering failed: {str(e)}")
                