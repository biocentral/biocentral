FROM nvcr.io/nvidia/tritonserver:25.06-py3

# Install transformers and other dependencies needed for tokenizers
RUN pip install transformers torch sentencepiece protobuf

# Set working directory
WORKDIR /opt/tritonserver 