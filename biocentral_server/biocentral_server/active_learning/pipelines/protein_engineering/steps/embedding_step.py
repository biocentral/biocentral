from junban import PipelineStep
from biotrainer_core.data_classes import SequenceData

from ..engineering_pipeline_context import EngineeringPipelineContext


class EmbeddingStep(PipelineStep[EngineeringPipelineContext]):
    def _check_entry_assumptions(self, context: EngineeringPipelineContext) -> bool:
        assert len(context.mutations or []) > 0
        assert context.embedding_subtask_wrapper is not None
        return True

    def _check_exit_assumptions(self, context: EngineeringPipelineContext) -> bool:
        assert context.training_data is not None
        assert context.inference_data is not None
        return True

    def get_start_message(self) -> str:
        return "Embedding mutations..."

    def get_end_message(self) -> str:
        return "Mutations embedded."

    def _execute(
        self, context: EngineeringPipelineContext
    ) -> EngineeringPipelineContext:
        mutations = context.mutations
        mutations_seq_data = [
            SequenceData(seq_id=f"mutation_{idx}", seq=mutation)
            for idx, mutation in enumerate(mutations)
        ]
        mutation_data_hashed = {
            data_point.get_hash(): data_point for data_point in mutations_seq_data
        }
        training_data = context.al_training_data
        training_data_hashed = {
            data_point.get_hash(): data_point for data_point in training_data
        }

        data_to_embed = mutations_seq_data + training_data

        # TODO: Check that there is no overlap between training data and mutations_seq_data

        embedding_wrapper = context.embedding_subtask_wrapper
        error_dto, embedding_result = embedding_wrapper(data_to_embed)
        if error_dto:
            raise Exception(error_dto.error)

        model_training_data = {
            data_point.seq_id: data_point.set_attribute(key="set", value="train")
            for data_point in embedding_result
            if data_point.get_hash() in training_data_hashed
        }
        if len(model_training_data) == 1:
            # Edge case for minimal input: Add a dummy sequence
            first_value = list(model_training_data.values())[0]
            dummy_seq_data = SequenceData(
                seq_id="dummy_train_1",
                seq="PRTEIN",
                set="train",
                label=first_value.label,
                embedding=first_value.embedding,
            )
            model_training_data[dummy_seq_data.get_hash()] = dummy_seq_data

        model_inference_data = {
            data_point.seq_id: data_point.set_attribute(key="set", value="pred")
            for data_point in embedding_result
            if data_point.get_hash() in mutation_data_hashed
        }
        context.training_data = model_training_data
        context.inference_data = model_inference_data

        return context
