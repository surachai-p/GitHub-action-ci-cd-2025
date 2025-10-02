import pytest
import sys
import os

# Add the parent directory to the path so we can import app
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello(client):
    """ทดสอบ endpoint หลัก"""
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert data['message'] == 'Hello World!'
    assert data['status'] == 'running'

def test_health(client):
    """ทดสอบ health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'
    assert 'database' in data
    assert 'redis' in data

def test_math_operations():
    """ทดสอบพื้นฐาน"""
    assert 1 + 1 == 2
    assert 2 * 3 == 6
