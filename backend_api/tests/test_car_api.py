import pytest
from flask import Flask
from ../carApi import carApi # maybe wont work



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

    mocker.patch("carAPI.get_connection", return_value=mock_connection)

    return mock_cursor, mock_connection



