# KnowCars on Kubernetes 

KnowCars is a web application that displays information about cars.  
It consists of a **React frontend** served by **Nginx**, a **Flask API backend**, and a **MySQL database**, all orchestrated with **Kubernetes**.

---

## Table of Contents

- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Kubernetes Resources](#kubernetes-resources)
- [Setup](#setup)
- [Accessing the App](#accessing-the-app)
- [API Endpoints](#api-endpoints)
- [Database](#database)

---

## Architecture
## Features

- Display a list of cars with detailed information.
- Retrieve, create, update, and delete car entries via the Flask API.
- Serve car images alongside car details.
- Fully containerized and image management with docker

---

## Tech Stack

- **Frontend:** React
- **Backend:** Flask (Python)
- **Database:** MySQL
- **Containerization:** Docker & Docker Compose

---

## Setup

### Prerequisites
- [Kubernetes cluster](https://kubernetes.io/docs/setup/) (local via Minikube or remote)  
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed and configured  

### Deploy
Apply the manifests in the correct order:  

```bash
kubectl apply -f k8s/mysql-secret.yaml
kubectl apply -f k8s/mysql-statefulset.yaml
kubectl apply -f k8s/mysql-service.yaml

kubectl apply -f k8s/flask-configmap.yaml
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/flask-service.yaml

```

---


## Kubernetes Resources

### MySQL
- **StatefulSet** → Ensures stable identity and persistent data.  
- **volumeClaimTemplate** → Provides persistent storage.  
- **ClusterIP Service** → Internal communication for the API.  
- **Secret** → Stores MySQL root password, user, and database credentials.  

### Flask API
- **Deployment** → Manages Flask API pods.  
- **ClusterIP Service** → Exposes the API internally to Nginx.  
- **ConfigMap** → Stores database connection settings.  

---

## API-Endpoints

The Flask API exposes multiple endpoints to interact with the cars database.

### Health
- **GET** `/api/health` → Check if the API is running.
- - **GET** `/api/health/ready` → Check for API and Database connection.

### Cars
- **GET** `/api/cars` → Get all cars.  
- **GET** `/api/cars/<car_id>` → Get a specific car by ID.  
- **POST** `/api/cars` → Create a new car (requires JSON body).  
- **PUT** `/api/cars/<car_id>` → Update an existing car.  
- **DELETE** `/api/cars/<car_id>` → Remove a car by ID.  

### Car Images
- **GET** `/api/car_images` → Get all available image URLs.  
- **GET** `/api/car_images/<car_id>` → Get the image URL for a specific car.  
- **GET** `/api/cars_with_images` → Get all cars with their images included.  
- **GET** `/api/images/<filename>` → Serve an image file from the server.

 ---


