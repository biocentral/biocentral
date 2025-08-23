FROM python:3.12.11-bookworm AS builder

# Install required packages
RUN apt-get update && apt-get install -y \
    ca-certificates libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Set environment
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_DEFAULT_TIMEOUT=100 \
    PATH="/app/.venv/bin:$PATH" \
    VIRTUAL_ENV="/app/.venv" \
    LOGGER_DIR="/app/logs" \
    SERVER_DEBUG=0

# Configure Git to use HTTPS instead of SSH
RUN git config --global url."https://".insteadOf git://
RUN git config --global url."https://github.com/".insteadOf git@github.com:

WORKDIR /app

# Install uv
RUN pip install uv

# Copy only requirements first to leverage Docker caching
COPY pyproject.toml ./
RUN touch README.md

# Add non-root user
RUN adduser --disabled-password biocentral-server-user

# Creating directories
RUN mkdir -p /app/logs
RUN mkdir -p /app/logs /var/log/biocentral-server && \
    chown -R biocentral-server-user:biocentral-server-user /app /var/log/

# Copy application files with correct ownership
COPY --chown=biocentral-server-user:biocentral-server-user ./biocentral_server ./biocentral_server
COPY --chown=biocentral-server-user:biocentral-server-user ./run-biocentral_server.py ./run-biocentral_server.py
COPY --chown=biocentral-server-user:biocentral-server-user ./gunicorn.conf.py ./gunicorn.conf.py

# Install dependencies
RUN uv pip install --system -e .

# Switch to non-root user
USER biocentral-server-user

# Remove cache to reduce container size
RUN rm -rf ~/.cache/uv

# Expose server port
EXPOSE 9540

# Run
CMD ["gunicorn", "--config", "gunicorn.conf.py", "run-biocentral_server:app"]
