from typing import Optional

from pydantic import BaseModel, Field


class PLMEvalTaskInformation(BaseModel):
    name: str = Field(description="Name of the task")
    description: str = Field(description="Description of the task")


class PLMEvalInformation(BaseModel):
    n_tasks: int = Field(description="Number of tasks", gt=0)
    tasks: list[PLMEvalTaskInformation] = Field(
        description="List of tasks", min_length=1
    )


class PLMEvalInformationResponse(BaseModel):
    info: PLMEvalInformation = Field(
        description="Information about the PLM evaluation process"
    )


class PLMEvalValidateRequest(BaseModel):
    model_id: str = Field(description="Huggingface model identifier")


class PLMEvalValidateResponse(BaseModel):
    valid: bool = Field(description="Whether the model is valid for PLM evaluation")
    error: Optional[str] = Field(description="Error message if the model is invalid")


class PLMEvalAutoevalRequest(BaseModel):
    model_id: str = Field(description="Huggingface model identifier")
    onnx_file: Optional[str] = Field(description="Optional base64 encoded ONNX file")
    tokenizer_config: Optional[str] = Field(description="Optional tokenizer config")
