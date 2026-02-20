FROM python:3.12-slim

# install curl for health check and remove cached packages
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend_api

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONPATH=/app


CMD ["python3", "carAPI.py"]
