# -------- Stage 1: Builder --------
FROM python:3.13-slim AS builder

# Set working directory
WORKDIR /app

# Install OS-level dependencies
RUN apt-get update && apt-get install -y build-essential gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install packages
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy application code
COPY . .

# -------- Stage 2: Runtime --------
FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Copy dependencies and code from builder

COPY --from=builder /app /app

# Ensure the installed packages are found
ENV PATH=/root/.local/bin:$PATH

# Expose the default Flask port
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]
