FROM python:3.12-slim

# install curl for health check and remove cached packages
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /backend-API-container

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY carAPI.py .
COPY car.py .	
COPY mysqlConnection.py .




CMD ["python3", "carAPI.py"]
