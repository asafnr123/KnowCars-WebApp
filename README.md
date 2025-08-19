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
- [License](#license)

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
MYSQL_USER=your_user
MYSQL_PASSWORD=your_password
DB_HOST=mysql-db
DB_PORT=3306
CARS_DB=knowCarsDB
