import pytest
from flask import Flask
from backend_api.carAPI import carApi 



@pytest.fixture
def client():
    with carApi.test_client() as client:
        yield client

@pytest.fixture
def mock_db(mocker):

    mock_cursor = mocker.Mock()

    mock_connection = mocker.Mock()
    mock_connection.cursor.return_value = mock_cursor

    mocker.patch("backend_api.carAPI.get_connection", return_value=mock_connection)

    return mock_cursor, mock_connection


# have all required fields
@pytest.fixture
def all_fields_car():
    return {
        "id": "1",
        "make": "Toyota",
        "model": "Corolla",
        "year": 2021,
        "horse_power": 130,
        "fuel_type": "Gas",
        "cylinders": 4,
        "displacement": 1800,
        "gear": "Automatic",
        "description": "Good car"
    }


# missing model and year fields
@pytest.fixture
def missing_required_fields_car(): 
    return {
        "id": "2",
        "make": "Toyota",
        "horse_power": 130,
        "fuel_type": "Gas",
        "cylinders": 4,
        "displacement": 1800,
        "gear": "Automatic",
        "description": "Good car"
    }




def test_get_all_cars(client, mock_db):
    mock_cursor, mock_connection = mock_db

    expected_value = [
        {"id": "1", "make": "Toyota", "model": "Corolla", "year": 2021, "horse_power": 130, "fuel_type": "Gas", "cylinders": 4, "displacement": 1800,"gear": "Automatic", "description": "Good car"},
        
        {"id": "2", "make": "Honda", "model": "Civic", "year": 2022, "horse_power": 158, "fuel_type": "Gas", "cylinders": 4, "displacement": 2000, "gear": "Automatic", "description": "Good car"}
    ]

    mock_cursor.fetchall.return_value = expected_value

    response = client.get("/api/cars")

    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)
    assert data == expected_value
    assert "image_url" not in data[0]
    mock_cursor.execute.assert_called_once()


def test_get_all_cars_empty_list(client, mock_db):

    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchall.return_value = []

    response = client.get("/api/cars")

    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)
    assert len(data) == 0
    mock_cursor.execute.assert_called_once()


def test_get_all_cars_db_error(client, mock_db):
    
    mock_cursor, mock_connection = mock_db
    mock_cursor.execute.side_effect = Exception("Connection failed")

    response = client.get("/api/cars")

    assert response.status_code == 500
    data = response.get_json()
    assert "error" in data
    assert "Database error" in data["error"]
    mock_cursor.execute.assert_called_once()


def test_get_all_cars_include_image(client, mock_db):
    mock_cursor, mock_connection = mock_db

    expected_value = [
        {"id": "1", "make": "Toyota", "model": "Corolla", "year": 2021, "horse_power": 130, "image_url": "toyota.jpg", "fuel_type": "Gas", "cylinders": 4, "displacement": 1800,"gear": "Automatic", "description": "Good car"},
        
        {"id": "2", "make": "Honda", "model": "Civic", "year": 2022, "horse_power": 158, "image_url": "honda.jpg", "fuel_type": "Gas", "cylinders": 4, "displacement": 2000, "gear": "Automatic", "description": "Good car"}
    ]

    mock_cursor.fetchall.return_value = expected_value

    response = client.get("/api/cars?include=image")

    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)
    assert data == expected_value
    mock_cursor.execute.assert_called_once()


def test_get_all_cars_not_include_image(client, mock_db):
    mock_cursor, mock_connection = mock_db

    # doesnt include "image_url" field
    expected_value = [
        {"id": "1", "make": "Toyota", "model": "Corolla", "year": 2021, "horse_power": 130, "fuel_type": "Gas", "cylinders": 4, "displacement": 1800,"gear": "Automatic", "description": "Good car"},
        
        {"id": "2", "make": "Honda", "model": "Civic", "year": 2022, "horse_power": 158, "fuel_type": "Gas", "cylinders": 4, "displacement": 2000, "gear": "Automatic", "description": "Good car"}
    ]

    mock_cursor.fetchall.return_value = expected_value

    response = client.get("/api/cars?include=image")

    assert response.status_code == 500
    data = response.get_json()
    assert "error" in data
    mock_cursor.execute.assert_called_once()


def test_get_car(client, mock_db, all_fields_car):
    mock_cursor, mock_connection = mock_db

    expected_value = all_fields_car

    mock_cursor.fetchone.return_value = expected_value

    response = client.get(f"/api/cars/{expected_value['id']}")

    assert response.status_code == 200
    data = response.get_json()
    assert data["id"] == expected_value["id"]
    mock_cursor.execute.assert_called_once()


def test_get_car_db_error(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.execute.side_effect = Exception("Connection failed")

    response = client.get("/api/cars/123")

    assert response.status_code == 500
    data = response.get_json()
    assert "error" in data
    mock_cursor.execute.assert_called_once()


def test_get_car_not_found(client, mock_db, all_fields_car):
    mock_cursor, mock_connection = mock_db
    
    expected_value = None
    mock_cursor.fetchone.return_value = expected_value

    response = client.get("/api/cars/123}")
    assert response.status_code == 404
    data = response.get_json()
    assert "error" in data

