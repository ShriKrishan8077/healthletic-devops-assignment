# Base Image
FROM python:3.13-slim

# Working directory inside container
WORKDIR /app

# Copy requirements first (better Docker caching)
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose Flask port
EXPOSE 5000

# Start application
CMD ["python", "-m", "app.app"]