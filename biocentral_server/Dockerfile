FROM python:3.12.11-bookworm AS builder

# Install required packages
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install poetry==1.8.3
ENV POETRY_NO_INTERACTION=1

# Configure Git to use HTTPS instead of SSH
RUN git config --global url."https://".insteadOf git://
RUN git config --global url."https://github.com/".insteadOf git@github.com:

# Create and activate virtual environment
RUN python -m venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Copying and installing dependencies
WORKDIR /app
COPY pyproject.toml ./
# TODO RUN pip install --user poetry-export-plugin
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes
RUN pip install -r requirements.txt --timeout 100 --retries 10

FROM python:3.12.11-slim-bookworm AS runner

RUN adduser --disabled-password biocentral-server-user

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/logs /var/log/biocentral-server && \
    chown -R biocentral-server-user:biocentral-server-user /app /var/log/

# Set environment variables
ENV PATH="/app/.venv/bin:$PATH" \
    VIRTUAL_ENV="/app/.venv" \
    LOGGER_DIR="/app/logs" \
    SERVER_DEBUG=0

# Copy virtual environment with correct ownership
COPY --from=builder --chown=biocentral-server-user:biocentral-server-user ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Switch to app directory
WORKDIR /app

# Copy application files with correct ownership
COPY --chown=biocentral-server-user:biocentral-server-user ./biocentral_server ./biocentral_server
COPY --chown=biocentral-server-user:biocentral-server-user ./run-biocentral_server.py ./run-biocentral_server.py
COPY --chown=biocentral-server-user:biocentral-server-user ./gunicorn.conf.py ./gunicorn.conf.py

# Switch to non-root user
USER biocentral-server-user

EXPOSE 9540

# Run
CMD ["gunicorn", "--config", "gunicorn.conf.py", "run-biocentral_server:app"]
