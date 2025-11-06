FROM ubuntu:24.04 AS builder

# Install Python and required packages
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3-pip \
    git \
    curl \
    ca-certificates \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Set environment
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_DEFAULT_TIMEOUT=100 \
    PATH="/app/.venv/bin:$PATH" \
    VIRTUAL_ENV="/app/.venv" \
    LOGGER_DIR="/app/logs" \
    SERVER_DEBUG=0 \
    HOST=0.0.0.0 \
    PORT=9540

# Configure Git to use HTTPS instead of SSH
RUN git config --global url."https://".insteadOf git://
RUN git config --global url."https://github.com/".insteadOf git@github.com:

WORKDIR /app

# Install uv
RUN pip3 install --break-system-packages uv

# Copy only requirements first to leverage Docker caching
COPY pyproject.toml ./
RUN touch README.md

# Add non-root user
RUN useradd --create-home --shell /bin/bash biocentral-server-user

# Create directories
RUN mkdir -p /app/logs /var/log/biocentral-server && \
    chown -R biocentral-server-user:biocentral-server-user /app /var/log/

# Copy application files
COPY --chown=biocentral-server-user:biocentral-server-user ./biocentral_server ./biocentral_server

# Install dependencies
RUN uv sync

# Switch to non-root user
USER biocentral-server-user

# Remove cache
RUN rm -rf ~/.cache/uv

EXPOSE $PORT

CMD ["sh", "-c", "uvicorn biocentral_server.main:app --host $HOST --port $PORT"]
