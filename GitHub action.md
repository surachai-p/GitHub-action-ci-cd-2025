# Lab 00: Preparing Knowledge - YAML for Docker Compose & GitHub Actions

## วัตถุประสงค์
เพื่อเตรียมความพร้อมในการเขียนไฟล์ YAML สำหรับ Docker Compose และ GitHub Actions 
  PYTHON_VERSION: '3.9'

#### Step-by-step สำหรับ Windows (PowerShell)

**ขั้นตอนที่ 1: เตรียมโครงสร้างโปรเจค**
> โครงสร้างและไฟล์ทั้งหมดใน `my-flask-app` ของคุณถูกสร้างครบแล้ว

**ขั้นตอนที่ 2: ตั้งค่า Environment Variables**
1. คัดลอกไฟล์ template:
```powershell
Copy-Item .\my-flask-app\.env.example .\my-flask-app\.env
```
2. สร้างรหัสผ่านที่ปลอดภัย (ใน PowerShell):
```powershell
python -c "import secrets; print('POSTGRES_PASSWORD=' + secrets.token_urlsafe(24)); print('SECRET_KEY=' + secrets.token_urlsafe(32))"
```
นำค่าที่ได้ไปแก้ไขในไฟล์ `.env` ด้วย Notepad หรือ VS Code:
```powershell
notepad .\my-flask-app\.env
# หรือ
code .\my-flask-app\.env
```

**ขั้นตอนที่ 3: ตรวจสอบและ Validate docker-compose.yml**
```powershell
cd .\my-flask-app
docker compose config
```
ถ้าไม่มี error แสดงว่า YAML ถูกต้อง

**ขั้นตอนที่ 4: สร้างและเริ่มต้น Services ด้วย Docker Compose**
```powershell
docker compose up -d --build
```
รอประมาณ 30 วินาทีให้ services พร้อม:
```powershell
Start-Sleep -Seconds 30
```

**ขั้นตอนที่ 5: ตรวจสอบสถานะและ logs**
```powershell
docker compose ps
docker compose logs
docker compose logs web
docker compose logs db
docker compose logs redis
docker compose ps --format "table {{.Name}}\t{{.State}}\t{{.Health}}"
```

**ขั้นตอนที่ 6: ทดสอบ API Endpoints**
```powershell
curl http://localhost:5000/
          echo "=== Pipeline Summary ==="
```
หรือเปิดใน browser:  
- http://localhost:5000/
- http://localhost:5000/health

**ขั้นตอนที่ 7: ทดสอบ Database และ Redis**
เข้าไปใน PostgreSQL container:
```powershell
docker compose exec db psql -U user
```
ตัวอย่างคำสั่งใน psql:
- `SELECT version();`
- `\l`
- `\q`

เข้าไปใน Redis container:
```powershell
docker compose exec redis redis-cli
```
ตัวอย่างคำสั่งใน redis-cli:
- `PING`
- `SET test "Hello Redis"`
- `GET test`
- `exit`

ทดสอบจาก web container:
```powershell
docker compose exec web bash
python3 -c "import psycopg2; print('PostgreSQL OK')"
python3 -c "import redis; print('Redis OK')"
exit
```

**ขั้นตอนที่ 8: Run Tests ใน container**
```powershell
docker compose exec web pytest tests/ -v
docker compose exec web pytest tests/ -v --cov=. --cov-report=term
```

**ขั้นตอนที่ 9: Debugging (ถ้ามีปัญหา)**
```powershell
docker compose logs --tail=50 web
docker compose exec web bash
# ตรวจสอบไฟล์และ environment
env | findstr "DATABASE REDIS FLASK"
exit
docker compose restart web
docker compose up -d --build web
```

**ขั้นตอนที่ 10: Stop/Remove Services**
```powershell
docker compose stop
docker compose start
docker compose down
docker compose down -v
docker compose down -v --rmi all
docker system prune -f
```

**Checklist ก่อนจบการทดลอง**
- [x] ไฟล์ทั้งหมดถูกสร้างครบ
- [x] .env มี passwords ที่ปลอดภัย
- [x] `docker compose config` ไม่มี error
- [x] Services ทั้งหมด status เป็น "Up" และ "healthy"
- [x] API endpoints ตอบกลับถูกต้อง
- [x] Tests ผ่านทั้งหมด
- [x] Database และ Redis เชื่อมต่อได้
          echo "Test: ${{ needs.test.result }}"
          echo "Snyk: ${{ needs.security-snyk.result }}"
          echo "Security: ${{ needs.security-additional.result }}"
          echo "Build: ${{ needs.build.result }}"
```

### คำอธิบายแต่ละส่วนใน GitHub Actions

#### Permissions (สำคัญ!)
```yaml
permissions:
  contents: read          # อ่าน repository
  packages: write         # เขียน packages
  security-events: write  # เขียน security events
```

#### Jobs
- **runs-on**: ระบบปฏิบัติการที่ใช้
- **needs**: รอ job อื่นเสร็จก่อน
- **if**: เงื่อนไขในการทำงาน
- **services**: services สำหรับทดสอบ

#### Steps
- **uses**: ใช้ action ที่มีอยู่แล้ว
- **run**: รันคำสั่งโดยตรง
- **with**: พารามิเตอร์สำหรับ action
- **env**: ตัวแปรสภาพแวดล้อม

---

#ขั้นตอนการทดลอง

### การทดลองที่ 1: สร้าง Docker Compose Project

#### ขั้นตอนที่ 1: เตรียมโครงสร้างโปรเจค

```bash
# สร้างโฟลเดอร์โปรเจค
mkdir my-flask-app
cd my-flask-app

# สร้างโครงสร้างโฟลเดอร์
mkdir -p backend/tests
mkdir -p .github/workflows

# สร้างไฟล์ว่างๆ จากคำสั่ง หรือจาก VSCode
touch docker-compose.yml
touch Dockerfile
touch backend/app.py
touch backend/requirements.txt
touch backend/tests/test_app.py
touch .env.example
touch .gitignore
touch README.md
```

#### ขั้นตอนที่ 2: สร้างไฟล์ Docker Compose

**สร้างไฟล์ `docker-compose.yml` ในโฟลเดอร์หลัก:**

```yaml
# Modern Docker Compose - ไม่ต้องระบุ version

services:
  # Web Application Service
  web:
    build: .
    container_name: flask_app
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=development
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy        # รอจนกว่า db จะ healthy
      redis:
        condition: service_healthy        # รอจนกว่า redis จะ healthy
    volumes:
      - .:/app
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Database Service
  db:
    image: postgres:16-alpine             # PostgreSQL 16 Alpine
    container_name: postgres_db
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass             # ในการใช้งานจริงใช้ secrets
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  # Redis Service
  redis:
    image: redis:7-alpine                 # Redis 7 Alpine
    container_name: redis_cache
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 20s

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
```

#### ขั้นตอนที่ 3: สร้างไฟล์โปรเจค

**สร้างไฟล์ `Dockerfile` ในโฟลเดอร์หลัก:**

```dockerfile
FROM python:3.9-slim

# ติดตั้ง dependencies ที่จำเป็น
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV PYTHONPATH=/app
# Copy requirements และติดตั้ง
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY backend/ .

EXPOSE 5000

CMD ["python", "app.py"]
```

**สร้างไฟล์ `backend/app.py`:**

```python
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        "message": "Hello World!",
        "status": "running"
    })

@app.route('/health')
def health():
    db_status = "connected" if os.getenv('DATABASE_URL') else "not configured"
    redis_status = "connected" if os.getenv('REDIS_URL') else "not configured"
    
    return jsonify({
        "status": "healthy",
        "database": db_status,
        "redis": redis_status
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

**สร้างไฟล์ `backend/requirements.txt`:**

```txt
# Web Framework
Flask==3.0.3

# Testing
pytest==8.3.3
pytest-cov==5.0.0

# Database
psycopg2-binary==2.9.9

# Cache
redis==5.1.1

# Additional
python-dotenv==1.0.1
```

**สร้างไฟล์ `backend/tests/test_app.py`:**

```python
import pytest
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
```

**สร้างไฟล์ `.env.example`:**

```bash
# Database Configuration
POSTGRES_DB=mydb
POSTGRES_USER=user
POSTGRES_PASSWORD=your_password_here

# Application Configuration
FLASK_ENV=development
SECRET_KEY=your_secret_key_here

# Optional: Snyk Token (for security scanning)
SNYK_TOKEN=your_snyk_token_here
```

**สร้างไฟล์ `.gitignore`:**

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
pip-log.txt
.tox/
.coverage
.pytest_cache/
htmlcov/
*.egg-info/

# Environment variables
.env
.env.local
.env.production

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Database
*.db
*.sqlite3

# Docker
.dockerignore
```

**สร้างไฟล์ `README.md`:**

```markdown
# Flask CI/CD Demo

Demo project สำหรับ Lab 00 - Docker Compose และ GitHub Actions

## Requirements

- Docker Desktop
- Git

## Quick Start

1. Clone repository:
\`\`\`bash
git clone <your-repo-url>
cd my-flask-app
\`\`\`

2. Setup environment:
\`\`\`bash
cp .env.example .env
# แก้ไขค่าใน .env
\`\`\`

3. Start services:
\`\`\`bash
docker compose up -d
\`\`\`

4. Test API:
\`\`\`bash
curl http://localhost:5000/
curl http://localhost:5000/health
\`\`\`

## Project Structure

\`\`\`
my-flask-app/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── tests/
│       └── test_app.py
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── docker-compose.yml
├── Dockerfile
├── .env.example
├── .gitignore
└── README.md
\`\`\`
```

#### ขั้นตอนที่ 4: ตั้งค่า Environment Variables

```bash
# 1. คัดลอกไฟล์ template
cp .env.example .env

# 2. Generate secure passwords
python3 << 'EOF'
import secrets
print("# Generated Secure Values")
print(f"POSTGRES_PASSWORD={secrets.token_urlsafe(24)}")
print(f"SECRET_KEY={secrets.token_urlsafe(32)}")
EOF

# 3. แก้ไขไฟล์ .env ด้วย text editor นำค่ารหัสผ่านที่ได้ในขั้นตอนก่อนหน้านี้ ไปบันทึกใน .env
# Linux/Mac
nano .env
# หรือ
vim .env
# หรือ
code .env  # ถ้าใช้ VS Code

# Windows
notepad .env
```

**ตัวอย่างไฟล์ `.env` ที่แก้ไขแล้ว:**
```bash
# Database Configuration
POSTGRES_DB=mydb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=Xy7zABc123DEfghIJklMNopqRStuVWxyz

# Application Configuration
FLASK_ENV=development
SECRET_KEY=AbC123dEf456GhI789JkL012MnO345PqR678StU901VwX234YzA567BcD890
```

#### ขั้นตอนที่ 5: ทดสอบ Docker Compose

```bash
# ตรวจสอบว่าไฟล์ทั้งหมดพร้อมแล้ว
ls -la
# ควรเห็น: docker-compose.yml, Dockerfile, backend/, .env

# Validate docker-compose.yml
docker compose config
# ถ้าไม่มี error แสดงว่า YAML ถูกต้อง

# เริ่มต้น services (build และ start)
docker compose up -d --build

# รอสักครู่ให้ services เริ่มต้น (ประมาณ 30 วินาที)
echo "Waiting for services to be ready..."
sleep 30

# ตรวจสอบ status ของ services
docker compose ps

# ควรเห็นผลลัพธ์แบบนี้:
# NAME            IMAGE              STATUS          PORTS
# flask_app       my-flask-app-web   Up 30 seconds   0.0.0.0:5000->5000/tcp
# postgres_db     postgres:16-alpine Up 30 seconds   0.0.0.0:5432->5432/tcp
# redis_cache     redis:7-alpine     Up 30 seconds   0.0.0.0:6379->6379/tcp

# ดู logs ของทุก services
docker compose logs

# ดู logs แบบ follow (real-time)
docker compose logs -f

# กด Ctrl+C เพื่อหยุดดู logs

# ดู logs เฉพาะ service
docker compose logs web
docker compose logs db
docker compose logs redis

# ตรวจสอบ health status
docker compose ps --format "table {{.Name}}\t{{.State}}\t{{.Health}}"
```

#### ขั้นตอนที่ 6: ทดสอบ API Endpoints

```bash
# ทดสอบ root endpoint
curl http://localhost:5000/
# Expected output:
# {"message":"Hello World!","status":"running"}

# ทดสอบ health endpoint
curl http://localhost:5000/health
# Expected output:
# {"status":"healthy","database":"connected","redis":"connected"}

# ทดสอบด้วย curl แบบ pretty print
curl -s http://localhost:5000/ | python3 -m json.tool


# ทดสอบด้วย browser
# เปิด http://localhost:5000/
# เปิด http://localhost:5000/health
```

#### ขั้นตอนที่ 7: ทดสอบ Database และ Redis

```bash
# เข้าไปใน PostgreSQL container
docker compose exec db psql -U user

```sql
# ทดสอบคำสั่ง SQL
psql> SELECT version();
psql> \l          (list databases)
psql> \q          (quit)
```

# เข้าไปใน Redis container
docker compose exec redis redis-cli

```sql
# ทดสอบคำสั่ง Redis
 redis> PING        (should return PONG)
 redis> SET test "Hello Redis"
 redis> GET test
 redis> exit
```
```bash
# ทดสอบจาก web container
docker compose exec web bash
# ใน container:
python3 -c "import psycopg2; print('PostgreSQL OK')"
python3 -c "import redis; print('Redis OK')"
exit
```

#### ขั้นตอนที่ 8: Run Tests

```bash
# Run tests ใน container
docker compose exec web pytest tests/ -v


# Run tests with coverage
docker compose exec web pytest tests/ -v --cov=. --cov-report=term

# Expected output:
# ======================== test session starts =========================
# test_app.py::test_hello PASSED                                 [ 33%]
# test_app.py::test_health PASSED                                [ 66%]
# test_app.py::test_math_operations PASSED                       [100%]
# ========================= 3 passed in 0.05s =========================
```

#### ขั้นตอนที่ 9: Debugging (ถ้ามีปัญหา)

```bash
# ตรวจสอบ logs รายละเอียด
docker compose logs --tail=50 web

# เข้าไปใน web container เพื่อ debug
docker compose exec web bash
# ls -la
# pwd
# cat app.py
# exit


# ตรวจสอบ environment variables
docker compose exec web env | grep -E "(DATABASE|REDIS|FLASK)"

# Restart service เดียว
docker compose restart web

# Rebuild และ restart
docker compose up -d --build web
```

#### ขั้นตอนที่ 10: Stop Service

```bash
# หยุด services (แต่เก็บ data)
docker compose stop

# เริ่มต้นใหม่
docker compose start

# หยุดและลบ containers (แต่เก็บ volumes)
docker compose down

# หยุด ลบ containers และ volumes (⚠️ จะลบข้อมูลด้วย!)
docker compose down -v

# ลบทุกอย่างรวม images
docker compose down -v --rmi all

# ลบ system cache (optional)
docker system prune -f
```

### Checklist ก่อนไปขั้นตอนถัดไป:

- [ ] ไฟล์ทั้งหมดถูกสร้างครบ
- [ ] .env มี passwords ที่ปลอดภัย
- [ ] `docker compose config` ไม่มี error
- [ ] Services ทั้งหมด status เป็น "Up" และ "healthy"
- [ ] API endpoints ตอบกลับถูกต้อง
- [ ] Tests ผ่านทั้งหมด
- [ ] Database และ Redis เชื่อมต่อได้
```
## บันทึกรูปผลการทดลอง หน้าจอของ docker และหน้าเว็บ


### การทดลองที่ 2: สร้าง GitHub Actions Workflow

#### ขั้นตอนที่ 1: สร้าง GitHub Repository

```bash
# Initial commit
git init
git add .
git commit -m "Initial commit: Flask app setup"

# สร้าง repository บน GitHub แล้วเชื่อมต่อ
git remote add origin https://github.com/YOUR_USERNAME/flask-ci-cd-demo-2025.git
git branch -M main
git push -u origin main
```

#### ขั้นตอนที่ 2: ตั้งค่า GitHub Secrets

1. ไปที่ GitHub Repository > **Settings**
2. คลิก **Secrets and variables** > **Actions**
3. คลิก **New repository secret** แล้วเพิ่ม key ต่าง ๆ ตามข้อมูลด้านล่าง:

|      Name*   | Secret*     |
|-------------|----------------|
| `POSTGRES_PASSWORD` | `python -c "import secrets; print(secrets.token_urlsafe(24))"` |
| `POSTGRES_USER` | `postgres` |
| `POSTGRES_DB` | `test_db` |
| `SECRET_KEY` | `python -c "import secrets; print(secrets.token_urlsafe(32))"` |
| `JWT_SECRET` | `python -c "import secrets; print(secrets.token_urlsafe(24))"` |
| `SNYK_TOKEN` | ไปที่ https://snyk.io > Account Settings > Auth Token |

#### ขั้นตอนที่ 3: สร้าง Workflow File

```bash
mkdir -p .github/workflows
# สร้างไฟล์ .github/workflows/ci-cd.yml
```yaml
name: Flask CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  PYTHON_VERSION: '3.9'

permissions:
  contents: read
  packages: write
  security-events: write
  pull-requests: write
  actions: read

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_PASSWORD: testpass
          POSTGRES_USER: testuser
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U testuser"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
          
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          cd backend
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest-cov

      - name: Install Redis CLI
        run: |
          sudo apt-get update
          sudo apt-get install -y redis-tools

      - name: Wait for services
        run: |
          echo "Waiting for PostgreSQL..."
          timeout 60 bash -c 'until pg_isready -h localhost -p 5432 -U testuser; do sleep 2; done'
          echo "✅ PostgreSQL is ready!"
          
          echo "Waiting for Redis..."
          timeout 60 bash -c 'until redis-cli -h localhost -p 6379 ping | grep -q PONG; do sleep 2; done'
          echo "✅ Redis is ready!"

      - name: Run tests with coverage
        run: |
          cd backend
          export PYTHONPATH=.
          export DATABASE_URL="postgresql://testuser:testpass@localhost:5432/testdb"
          export REDIS_URL="redis://localhost:6379"
          export FLASK_ENV=testing
          pytest tests/ -v --cov=. --cov-report=xml --cov-report=html --cov-report=term
        env:
          SECRET_KEY: test-secret-key

      - name: Upload coverage reports
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: backend/htmlcov/
          retention-days: 5

      - name: Upload coverage XML
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-xml
          path: backend/coverage.xml
          retention-days: 5

  security-snyk:
    name: Snyk Security Scan
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          cd backend
          pip install -r requirements.txt

      - name: Run Snyk Dependencies Scan
        uses: snyk/actions/python@master
        continue-on-error: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high --file=backend/requirements.txt
          command: test

      - name: Run Snyk Code Scan
        uses: snyk/actions/python@master
        continue-on-error: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=medium
          command: code test

      - name: Monitor with Snyk
        if: github.ref == 'refs/heads/main'
        uses: snyk/actions/python@master
        continue-on-error: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --file=backend/requirements.txt
          command: monitor

  security-additional:
    name: Additional Security Scans
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Run Safety check
        run: |
          pip install safety
          cd backend
          safety check --json --output safety-report.json || echo "⚠️ Safety warnings found"
        continue-on-error: true

      - name: Run Bandit SAST
        run: |
          pip install bandit
          cd backend
          bandit -r . -f json -o bandit-report.json -ll || echo "⚠️ Bandit warnings found"
        continue-on-error: true

      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: auto
        continue-on-error: true

      - name: Secret Scanning with TruffleHog
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
          extra_args: --only-verified
        continue-on-error: true

      - name: Upload security artifacts
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: security-reports
          path: |
            backend/safety-report.json
            backend/bandit-report.json
          retention-days: 30

  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    needs: [test, security-snyk, security-additional]
    if: |
      always() && 
      needs.test.result == 'success'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Prepare Docker metadata
        id: meta
        run: |
          REPO_LOWER=$(echo "${{ github.repository }}" | tr '[:upper:]' '[:lower:]')
          IMAGE_NAME="ghcr.io/${REPO_LOWER}"
          
          # Generate tags
          TAGS="${IMAGE_NAME}:sha-${{ github.sha }}"
          
          if [ "${{ github.event_name }}" == "pull_request" ]; then
            TAGS="${TAGS},${IMAGE_NAME}:pr-${{ github.event.pull_request.number }}"
          elif [ "${{ github.ref }}" == "refs/heads/main" ]; then
            TAGS="${TAGS},${IMAGE_NAME}:latest"
          elif [ "${{ github.ref }}" == "refs/heads/develop" ]; then
            TAGS="${TAGS},${IMAGE_NAME}:develop"
          fi
          
          echo "tags=${TAGS}" >> $GITHUB_OUTPUT
          echo "image_name=${IMAGE_NAME}" >> $GITHUB_OUTPUT
          
          echo "🏷️ Tags: ${TAGS}"

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Run Trivy container scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ steps.meta.outputs.image_name }}:sha-${{ github.sha }}
          format: 'table'
          exit-code: '0'
          severity: 'CRITICAL,HIGH'
        continue-on-error: true

  notify:
    name: Notify Results
    runs-on: ubuntu-latest
    needs: [test, security-snyk, security-additional, build]
    if: always()
    
    steps:
      - name: Create PR comment
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const testStatus = '${{ needs.test.result }}';
            const snykStatus = '${{ needs.security-snyk.result }}';
            const additionalSecurityStatus = '${{ needs.security-additional.result }}';
            const buildStatus = '${{ needs.build.result }}';
            
            const statusEmoji = {
              'success': '✅',
              'failure': '❌',
              'cancelled': '⏹️',
              'skipped': '⏭️'
            };
            
            const comment = `
            ## 🚀 CI/CD Pipeline Results
            
            | Job | Status | Result |
            |-----|--------|---------|
            | Tests | ${statusEmoji[testStatus] || '❓'} | ${testStatus} |
            | Snyk Security | ${statusEmoji[snykStatus] || '❓'} | ${snykStatus} |
            | Additional Security | ${statusEmoji[additionalSecurityStatus] || '❓'} | ${additionalSecurityStatus} |
            | Docker Build | ${statusEmoji[buildStatus] || '❓'} | ${buildStatus} |
            
            **Commit**: \`${{ github.sha }}\`
            **Branch**: \`${{ github.head_ref }}\`
            **Triggered by**: @${{ github.actor }}
            
            ---
            📊 [View detailed results](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }})
            `;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });

      - name: Print summary
        run: |
          echo "=== 🎯 Pipeline Summary ==="
          echo "✓ Test: ${{ needs.test.result }}"
          echo "✓ Snyk: ${{ needs.security-snyk.result }}"
          echo "✓ Security: ${{ needs.security-additional.result }}"
          echo "✓ Build: ${{ needs.build.result }}"
          echo "=========================="


```


#### ขั้นตอนที่ 4: Push และทดสอบ

```bash
git add .github/workflows/ci-cd.yml
git commit -m "Add CI/CD pipeline"
git push origin main

# ตรวจสอบผลลัพธ์ใน GitHub Actions 
```
## บันทึกรูปผลการทดลอง หน้า GitHub Actions
```bash


```

#### ขั้นตอนที่ 5: ทดสอบ Pull Request

```bash
git checkout -b feature/test-pr
echo "# Test PR" >> README.md
git add README.md
git commit -m "Test PR workflow"
git push origin feature/test-pr

# สร้าง Pull Request บน GitHub
# ตรวจสอบ workflow การทำงานและ comment ที่ถูกสร้าง
```
## บันทึกรูปผลการทดลอง 
```bash


```


---


## Resources และเอกสารอ้างอิง

### Official Documentation
- 📖 [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)
- 📖 [Docker Compose CLI](https://docs.docker.com/compose/cli-command/)
- 📖 [GitHub Actions Documentation](https://docs.github.com/en/actions)
- 📖 [GitHub Actions Security](https://docs.github.com/en/actions/security-guides)
- 📖 [Snyk Documentation](https://docs.snyk.io/)

### Security Resources
- 🔒 [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- 🔒 [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- 🔒 [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- 🔒 [DevSecOps Best Practices](https://www.devsecops.org/)

### Learning Resources
- 🎓 [Docker Compose Tutorial](https://docs.docker.com/compose/gettingstarted/)
- 🎓 [GitHub Actions Learning Lab](https://lab.github.com/)
- 🎓 [YAML Tutorial](https://yaml.org/spec/1.2.2/)

### Tools
- 🛠️ [YAML Validator](https://yamllint.com/)
- 🛠️ [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- 🛠️ [act - Run GitHub Actions locally](https://github.com/nektos/act)
- 🛠️ [dive - Docker image analyzer](https://github.com/wagoodman/dive)

---

## คำถามท้ายการทดลอง
1. docker compose คืืออะไร มีความสำคัญอย่างไร
- Docker Compose คือเครื่องมือสำหรับกำหนดและจัดการ multi-container application ด้วยไฟล์ YAML เดียว เช่น web, database, cache ฯลฯ สามารถสั่ง build, start, stop ทุก service พร้อมกันได้ง่าย ช่วยให้การพัฒนาและทดสอบแอปพลิเคชันที่มีหลายส่วนสะดวกและเป็นระบบมากขึ้น
2. GitHub pipeline คืออะไร เกี่ยวข้องกับ CI/CD อย่างไร
- GitHub pipeline (หรือ GitHub Actions workflow) คือกระบวนการอัตโนมัติที่กำหนดขั้นตอนการ build, test, deploy โค้ดทุกครั้งที่มีการเปลี่ยนแปลงใน repository โดยเป็นหัวใจของ CI/CD (Continuous Integration/Continuous Delivery) ช่วยให้โค้ดถูกตรวจสอบและนำขึ้น production ได้อย่างปลอดภัยและรวดเร็ว
3. จากไฟล์ docker compose  ส่วนของ volumes networks และ healthcheck มีความสำคัญอย่างไร
- volumes: ใช้สำหรับเก็บข้อมูลถาวรหรือแชร์ไฟล์ระหว่าง host กับ container เช่น ฐานข้อมูล
networks: กำหนด network เฉพาะสำหรับ container ในโปรเจค ให้แต่ละ service ติดต่อกันได้อย่างปลอดภัย
healthcheck: ใช้ตรวจสอบสุขภาพของ service ว่าพร้อมใช้งานหรือไม่ เช่น ตรวจสอบว่า web หรือ database ตอบสนองปกติ
4. อธิบาย Code ของไฟล์ yaml ในส่วนนี้ 
```yaml
jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_PASSWORD: testpass
          POSTGRES_USER: testuser
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U testuser"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
```
- กำหนด job ชื่อ test ให้รันบน VM ที่ใช้ Ubuntu ล่าสุด
สร้าง service ชื่อ postgres โดยใช้ image postgres:16-alpine
กำหนด environment variables สำหรับ database
เปิด port 5432 เพื่อให้ workflow เข้าถึงฐานข้อมูล
options กำหนด healthcheck ให้ตรวจสอบว่า postgres พร้อมใช้งานก่อนรันขั้นตอนถัดไป

5. จาก Code ในส่วนของ uses: actions/checkout@v4  และ uses: actions/setup-python@v5 คืออะไร 
```yaml
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'
```
- actions/checkout@v4: เป็น GitHub Action สำหรับ clone โค้ดจาก repository มายัง runner เพื่อให้ workflow สามารถเข้าถึงไฟล์ทั้งหมด
actions/setup-python@v5: เป็น Action สำหรับติดตั้ง Python version ที่ต้องการบน runner และตั้งค่า cache สำหรับ pip เพื่อเร่งความเร็วในการติดตั้ง dependencies

6. Snyk คืออะไร มีความสามารถอย่างไรบ้าง
- Snyk คือเครื่องมือสำหรับตรวจสอบช่องโหว่ด้านความปลอดภัยใน dependencies และ source code ของโปรเจค สามารถสแกนหา vulnerabilities, แนะนำวิธีแก้ไข, ตรวจสอบโค้ด, และ monitor ความปลอดภัยอย่างต่อเนื่อง ทั้งในขั้นตอนพัฒนาและ CI/CD pipeline