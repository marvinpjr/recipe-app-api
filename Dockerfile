FROM python:3.11-slim
LABEL maintainer="marvinpalmer.com"

# Set environment variable to ensure output is flushed immediately
ENV PYTHONUNBUFFERED 1
ENV PATH="/py/bin:$PATH"

# Copy requirement files to the container
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Set the working directory
WORKDIR /app

# Expose port 8000 for the application
EXPOSE 8000

# ARG to enable dev mode
ARG DEV=false

# Install dependencies and set up the environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client build-essential libpq-dev && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    rm -rf /var/lib/apt/lists/*

# Add non-root user for running the app
RUN adduser --disabled-password --no-create-home django-user && \
    mkdir -p /home/django-user/.vscode-server && \
    chown -R django-user:django-user /home/django-user /app

# Switch to the non-root user
USER django-user
