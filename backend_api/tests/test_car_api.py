import pytest
from flask import Flask
from backend_api.carAPI import carApi # if not working, add a __init__.py to backend_api



@pytest.fixture
def client():
    app = Flask(__name__)
    app.register_blueprint(carApi)

    with app.test_client() as client:
        yield client


@pytest.fixture
def mock_db(mocker):

    mock_cursor = mocker.Mock()

    mock_connection = mocker.Mock()
    mock_connection.cursor.return_value = mock_cursor

    mocker.patch("carApi.get_connection", return_value=mock_connection)

    return mock_cursor, mock_connection



