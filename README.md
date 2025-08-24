# KnowCars

KnowCars is a web application that displays information about cars. It consists of a **React frontend** served by **Nginx**, a **Flask API backend**, and a **MySQL database**, all containerized with Docker.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Setup](#setup)
- [Docker Compose](#docker-compose)
- [API Endpoints](#api-endpoints)
- [Database](#database)

---

## Features

- Display a list of cars with detailed information.
- Retrieve, create, update, and delete car entries via the Flask API.
- Serve car images alongside car details.
- Fully containerized and easy to deploy using Docker.

---

## Tech Stack

- **Frontend:** React
- **Backend:** Flask (Python)
- **Database:** MySQL
- **Web Server:** Nginx
- **Containerization:** Docker & Docker Compose

---

## Setup

### Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Add a .env file for environment variables for MySQL and API configuration:

```env
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_USER=regular
MYSQL_PASSWORD=your_password
DB_HOST=mysql-db
DB_PORT=3306
CARS_DB=knowCarsDB
```

---

## Docker-Compose

This project uses **Docker Compose** to orchestrate its services:

- **mysql-db** → Runs a MySQL database with a persistent volume (`db-data`).
- **flask-api** → Flask backend service that exposes a REST API, connects to MySQL, and provides car data.
- **nginx** → Serves the React frontend build and proxies requests to the Flask API if configured.

### Networks

Two Docker networks are defined:

- **backend-net** → Internal communication between Flask and MySQL.
- **frontend-net** → Communication between Flask and Nginx/frontend.

This separation improves security and isolates concerns between services.

---

## API-Endpoints

The Flask API exposes multiple endpoints to interact with the cars database.

### Health
- **GET** `/api/health` → Check if the API is running.

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

 ## Database

 Database

The backend uses MySQL with a connection pool (pool_size=7).
The Flask app reads its configuration from environment variables (DB_HOST, DB_PORT, MYSQL_USER, MYSQL_PASSWORD, CARS_DB).

Tables

cars → Stores main car data (make, model, year, horsepower, etc.).

carImages → Stores image URLs linked to cars via car_id.

The API joins these two tables when fetching cars with images (/api/cars_with_images).

