FROM python:3.12-slim


WORKDIR /backend-API-container

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY carAPI.py .
COPY car.py .	
COPY mysqlConnection.py .




CMD ["python3", "carAPI.py"]
