import pytest
from flask import Flask
from backend_api.carAPI import carApi # if not working, add a __init__.py to backend_api



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
        "id": 1,
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
        "id": 1,
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
        {"id": 1, "make": "Toyota", "model": "Corolla", "year": 2021, "horse_power": 130, "fuel_type": "Gas", "cylinders": 4, "displacement": 1800," gear": "Automatic", "description": "Good car"},
        
        {"id": 2, "make": "Honda", "model": "Civic", "year": 2022, "horse_power": 158, "fuel_type": "Gas", "cylinders": 4, "displacement": 2000, "gear": "Automatic", "description": "Good car"}
    ]

    mock_cursor.fetchall.return_value = expected_value

    response = client.get("/api/cars")
    data = response.get_json()

    assert response.status_code == 200
    assert isinstance(data, list)
    assert data[1]["make"] == "Honda"
    assert data == expected_value


