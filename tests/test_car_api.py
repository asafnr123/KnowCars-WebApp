import pytest
from backend_api.carAPI import carApi


@pytest.fixture
def client():
    carApi.config['TESTING'] = True
    with carApi.test_client() as client:
        yield client


@pytest.fixture
def mock_db(mocker):
    mock_cursor = mocker.Mock()
    mock_connection = mocker.Mock()
    mock_connection.cursor.return_value = mock_cursor
    mocker.patch("backend_api.carAPI.get_connection", return_value=mock_connection)
    return mock_cursor, mock_connection


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


@pytest.fixture
def api_key(mocker):
    mocker.patch("backend_api.carAPI.API_KEY", "test-key")
    return "test-key"


# ── GET /api/cars ─────────────────────────────────────────────────────────────

def test_get_all_cars(client, mock_db):
    mock_cursor, mock_connection = mock_db
    expected_value = [
        {"id": "1", "make": "Toyota", "model": "Corolla", "year": 2021, "horse_power": 130, "fuel_type": "Gas", "cylinders": 4, "displacement": 1800, "gear": "Automatic", "description": "Good car"},
        {"id": "2", "make": "Honda", "model": "Civic", "year": 2022, "horse_power": 158, "fuel_type": "Gas", "cylinders": 4, "displacement": 2000, "gear": "Automatic", "description": "Good car"}
    ]
    mock_cursor.fetchall.return_value = expected_value

    response = client.get("/api/cars")

    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)
    assert len(data) == 2
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
        {"id": "1", "make": "Toyota", "model": "Corolla", "year": 2021, "horse_power": 130, "image_url": "toyota.jpg", "fuel_type": "Gas", "cylinders": 4, "displacement": 1800, "gear": "Automatic", "description": "Good car"},
        {"id": "2", "make": "Honda", "model": "Civic", "year": 2022, "horse_power": 158, "image_url": "honda.jpg", "fuel_type": "Gas", "cylinders": 4, "displacement": 2000, "gear": "Automatic", "description": "Good car"}
    ]
    mock_cursor.fetchall.return_value = expected_value

    response = client.get("/api/cars?include=image")

    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)
    assert data == expected_value
    assert all("image_url" in car for car in data)
    mock_cursor.execute.assert_called_once()


def test_get_all_cars_missing_image_url_returns_500(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchall.return_value = [
        {"id": "1", "make": "Toyota", "model": "Corolla", "year": 2021, "horse_power": 130, "fuel_type": "Gas", "cylinders": 4, "displacement": 1800, "gear": "Automatic", "description": "Good car"},
    ]

    response = client.get("/api/cars?include=image")

    assert response.status_code == 500
    assert "error" in response.get_json()
    mock_cursor.execute.assert_called_once()


# ── GET /api/cars/<car_id> ────────────────────────────────────────────────────

def test_get_car(client, mock_db, all_fields_car):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = all_fields_car

    response = client.get(f"/api/cars/{all_fields_car['id']}")

    assert response.status_code == 200
    data = response.get_json()
    assert data["id"] == all_fields_car["id"]
    assert data["make"] == all_fields_car["make"]
    assert data["model"] == all_fields_car["model"]
    assert data["year"] == all_fields_car["year"]
    mock_cursor.execute.assert_called_once()


def test_get_car_not_found(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = None

    response = client.get("/api/cars/nonexistent-id")

    assert response.status_code == 404
    assert "error" in response.get_json()


def test_get_car_db_error(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.execute.side_effect = Exception("Connection failed")

    response = client.get("/api/cars/123")

    assert response.status_code == 500
    data = response.get_json()
    assert "error" in data
    mock_cursor.execute.assert_called_once()


# ── POST /api/cars ────────────────────────────────────────────────────────────

def test_create_car(client, mock_db, all_fields_car):
    mock_cursor, mock_connection = mock_db

    response = client.post("/api/cars", json=all_fields_car)

    assert response.status_code == 200
    data = response.get_json()
    assert "message" in data
    assert "Successfully added" in data["message"]
    mock_cursor.execute.assert_called_once()
    mock_connection.commit.assert_called_once()


def test_create_car_missing_required_fields(client, mock_db, missing_required_fields_car):
    response = client.post("/api/cars", json=missing_required_fields_car)

    assert response.status_code == 400
    assert "error" in response.get_json()


def test_create_car_invalid_json(client, mock_db):
    response = client.post("/api/cars", data="not json", content_type="application/json")

    assert response.status_code == 400
    assert "error" in response.get_json()


def test_create_car_db_error(client, mock_db, all_fields_car):
    mock_cursor, mock_connection = mock_db
    mock_cursor.execute.side_effect = Exception("DB insert failed")

    response = client.post("/api/cars", json=all_fields_car)

    assert response.status_code == 500
    assert "error" in response.get_json()


# ── PATCH /api/cars/<car_id> ──────────────────────────────────────────────────

def test_update_car(client, mock_db, all_fields_car):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = all_fields_car

    response = client.patch(f"/api/cars/{all_fields_car['id']}", json={"make": "Honda"})

    assert response.status_code == 200
    assert "message" in response.get_json()
    mock_connection.commit.assert_called_once()


def test_update_car_not_found(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = None

    response = client.patch("/api/cars/nonexistent-id", json={"make": "Honda"})

    assert response.status_code == 404
    assert "error" in response.get_json()


def test_update_car_no_valid_fields(client, mock_db, all_fields_car):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = all_fields_car

    response = client.patch(f"/api/cars/{all_fields_car['id']}", json={"unknown_field": "value"})

    assert response.status_code == 400
    assert "error" in response.get_json()


def test_update_car_invalid_json(client, mock_db):
    response = client.patch("/api/cars/1", data="not json", content_type="application/json")

    assert response.status_code == 400
    assert "error" in response.get_json()


def test_update_car_db_error(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.execute.side_effect = Exception("Connection failed")

    response = client.patch("/api/cars/1", json={"make": "Honda"})

    assert response.status_code == 500
    assert "error" in response.get_json()


# ── DELETE /api/cars/<car_id> ─────────────────────────────────────────────────

def test_delete_car(client, mock_db, all_fields_car):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = all_fields_car

    response = client.delete(f"/api/cars/{all_fields_car['id']}")

    assert response.status_code == 200
    assert "message" in response.get_json()
    mock_connection.commit.assert_called_once()


def test_delete_car_not_found(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = None

    response = client.delete("/api/cars/nonexistent-id")

    assert response.status_code == 400
    assert "error" in response.get_json()


def test_delete_car_db_error(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.execute.side_effect = Exception("Connection failed")

    response = client.delete("/api/cars/1")

    assert response.status_code == 500
    assert "error" in response.get_json()


# ── GET /api/car_images ───────────────────────────────────────────────────────

def test_get_all_images(client, mock_db):
    mock_cursor, mock_connection = mock_db
    expected_value = [
        {"car_id": "1", "image_url": "http://example.com/car1.jpg"},
        {"car_id": "2", "image_url": "http://example.com/car2.jpg"}
    ]
    mock_cursor.fetchall.return_value = expected_value

    response = client.get("/api/car_images")

    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)
    assert data == expected_value
    mock_cursor.execute.assert_called_once()


def test_get_all_images_empty(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchall.return_value = []

    response = client.get("/api/car_images")

    assert response.status_code == 200
    assert "alert" in response.get_json()


def test_get_all_images_db_error(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.execute.side_effect = Exception("Connection failed")

    response = client.get("/api/car_images")

    assert response.status_code == 500
    assert "error" in response.get_json()


# ── GET /api/car_images/<car_id> ──────────────────────────────────────────────

def test_get_car_image(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = {"image_url": "http://example.com/car1.jpg"}

    response = client.get("/api/car_images/1")

    assert response.status_code == 200
    assert "image_url" in response.get_json()
    mock_cursor.execute.assert_called_once()


def test_get_car_image_not_found(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchone.return_value = None

    response = client.get("/api/car_images/nonexistent-id")

    assert response.status_code == 404
    assert "alert" in response.get_json()


def test_get_car_image_db_error(client, mock_db):
    mock_cursor, mock_connection = mock_db
    mock_cursor.execute.side_effect = Exception("Connection failed")

    response = client.get("/api/car_images/1")

    assert response.status_code == 500
    assert "error" in response.get_json()


# ── API key tests ─────────────────────────────────────────────────────────────

def test_request_without_api_key_rejected(client, api_key):
    response = client.get("/api/cars")
    assert response.status_code == 401
    assert "error" in response.get_json()


def test_request_with_correct_api_key_allowed(client, mock_db, api_key):
    mock_cursor, mock_connection = mock_db
    mock_cursor.fetchall.return_value = []
    response = client.get("/api/cars", headers={"X-API-Key": "test-key"})
    assert response.status_code == 200


def test_request_with_wrong_api_key_rejected(client, api_key):
    response = client.get("/api/cars", headers={"X-API-Key": "wrong-key"})
    assert response.status_code == 401


def test_cors_preflight_allowed_without_api_key(client, api_key):
    response = client.options("/api/cars", headers={
        "Origin": "http://localhost:3000",
        "Access-Control-Request-Method": "GET",
        "Access-Control-Request-Headers": "X-API-Key"
    })
    assert response.status_code == 200


def test_health_endpoint_no_api_key(client, api_key):
    response = client.get("/api/health")
    assert response.status_code == 200


def test_image_endpoint_no_api_key(client, api_key):
    response = client.get("/api/images/nonexistent.jpg")
    assert response.status_code != 401
