# -------- Stage 1: Build stage --------
FROM python:3.13-slim AS builder



# Set working directory
WORKDIR /install

# Install build dependencies (optional, only needed if you have C extensions to compile)
RUN apt-get update && apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install packages into a temp dir
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --prefix=/install/deps -r requirements.txt

# -------- Stage 2: Final runtime image --------
FROM python:alpine


# Set working directory
WORKDIR /app

# Copy installed dependencies from builder stage
COPY --from=builder /install/deps /usr/local

# Copy application code
COPY . .

# Expose the default Flask port
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]





# # Use official Python image as base
# FROM python:3.11-slim


# # Set working directory
# WORKDIR /app

# # Install dependencies
# COPY requirements.txt .
# RUN pip install --upgrade pip && \
#     pip install -r requirements.txt

# # Copy the rest of the app
# COPY . .

# # Expose port (Flask default is 5000)
# EXPOSE 5000

# # Run the app
# CMD ["python", "app.py"]
