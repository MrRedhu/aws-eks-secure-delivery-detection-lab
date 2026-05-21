FROM python:3.11-slim

# Create a non-root user and group with a specific ID
RUN groupadd -g 10001 demo && useradd -u 10001 -g demo -s /bin/bash -m demo

WORKDIR /app

# Install dependencies first (leverage Docker cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/

# Change ownership of the app directory to the non-root user
RUN chown -R demo:demo /app

# Switch to the non-root user
USER 10001

EXPOSE 8000

# Run the FastAPI application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
