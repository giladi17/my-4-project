import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello(client):
    """בודק שנתיב ה-GET מחזיר את התשובה הנכונה"""
    response = client.get('/')
    assert response.data.decode('utf-8') == "Hello, DevOps!"
    assert response.status_code == 200

def test_echo(client):
    """בודק שנתיב ה-POST מחזיר בדיוק את ה-JSON שהוא קיבל"""
    test_data = {"role": "DevOps", "status": "awesome"}
    response = client.post('/echo', json=test_data)
    assert response.get_json() == test_data
    assert response.status_code == 200