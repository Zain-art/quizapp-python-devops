# -------- Stage 1: Builder --------
FROM python:3.13-slim AS builder

# Set working directory
WORKDIR /app

# Install OS-level dependencies
RUN apt-get update && apt-get install -y build-essential gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install packages
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# -------- Stage 2: Runtime --------
FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Copy dependencies and code from builder
# Copy installed Python packages and application code from builder
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /app /app

RUN mkdir -p /app


# Expose the default Flask port
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]
