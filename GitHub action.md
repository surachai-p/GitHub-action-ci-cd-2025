# Lab 00: Preparing Knowledge - YAML for Docker Compose & GitHub Actions

## วัตถุประสงค์
เพื่อเตรียมความพร้อมในการเขียนไฟล์ YAML สำหรับ Docker Compose และ GitHub Actions 

---

## ทฤษฎีก่อนการทดลอง
## ส่วนที่ 1: ความรู้พื้นฐาน YAML

### YAML คืออะไร?
- **YAML** = YAML Ain't Markup Language
- เป็นรูปแบบการเก็บข้อมูลที่อ่านได้ง่าย เหมาะสำหรับไฟล์คอนฟิกูเรชัน
- ใช้การเว้นวรรค (indentation) แทนการใช้วงเล็บ
- Case-sensitive (แยกตัวพิมพ์เล็กใหญ่)

### กฎการเขียน YAML
```yaml
# นี่คือ comment (ความคิดเห็น)
key: value                    # คู่ key-value พื้นฐาน
number: 42                    # ตัวเลข
boolean: true                 # boolean (true/false)
list:                         # รายการ (array)
  - item1
  - item2
  - item3
nested:                       # nested object
  child_key: child_value
multiline: |                  # multi-line string
  This is a
  multi-line
  string
```

---

## ส่วนที่ 2: Docker Compose YAML

### ทฤษฎี Docker Compose
Docker Compose เป็นเครื่องมือที่ใช้ในการจัดการแอปพลิเคชันที่ประกอบด้วยหลาย containers โดยใช้ไฟล์ YAML ในการกำหนดค่า

### โครงสร้างพื้นฐาน docker-compose.yml (Modern)
```yaml
# Modern Docker Compose - ไม่ต้องระบุ version
# ใช้ Compose Specification V2 อัตโนมัติ

services:                   # กำหนด services ต่างๆ
  service_name:             # ชื่อ service
    # การกำหนดค่า service
networks:                   # กำหนดเครือข่าย (optional)
volumes:                    # กำหนด volumes (optional)
```


### ตัวอย่างที่ 1: Flask Application พื้นฐาน

สร้างไฟล์ `docker-compose.yml`:

```yaml
# Modern Docker Compose - ไม่ต้องระบุ version

services:
  # Web Application Service
  web:
    build: .
    container_name: flask_app
    ports:
      - "5000:5000"                       #port host:docker
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

### คำอธิบายแต่ละส่วนใน Docker Compose

#### Services
แต่ละ service คือ container หนึ่งตัว:

- **build**: สร้าง image จาก Dockerfile
- **image**: ใช้ image ที่มีอยู่แล้ว (แนะนำใช้ Alpine variants)
- **container_name**: กำหนดชื่อ container
- **ports**: map port จาก host ไป container
- **environment**: ตั้งค่าตัวแปรสภาพแวดล้อม
- **depends_on**: กำหนดลำดับการเริ่มต้น service พร้อมเงื่อนไข
  - `condition: service_healthy` - รอจนกว่า service จะผ่าน healthcheck
  - `condition: service_started` - รอจนกว่า service จะเริ่มต้น
- **volumes**: mount ข้อมูลระหว่าง host กับ container
- **restart**: กำหนด restart policy
- **networks**: เครือข่ายที่ container จะเข้าร่วม
- **healthcheck**: ตรวจสอบสถานะสุขภาพของ service

#### Health Checks (สำคัญมาก!)
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U user"]  # คำสั่งตรวจสอบ
  interval: 10s                               # ตรวจสอบทุก 10 วินาที
  timeout: 5s                                 # timeout 5 วินาที
  retries: 5                                  # ลองใหม่ 5 ครั้ง
  start_period: 30s                          # รอ 30 วินาทีก่อนเริ่มตรวจสอบ
```

#### Networks และ Volumes
- **Networks**: กำหนดเครือข่ายสำหรับให้ containers สื่อสารกัน
- **Volumes**: จัดเก็บข้อมูลแบบถาวร ไม่หายเมื่อ container ปิด

### คำสั่ง Docker Compose V2

```bash
# เริ่มต้น services ทั้งหมด
docker compose up -d

# ดู status ของ services
docker compose ps

# ดู logs
docker compose logs -f

# ดู logs เฉพาะ service
docker compose logs web

# ตรวจสอบ health status
docker compose ps --format json | jq '.[].Health'

# Restart service
docker compose restart web

# หยุด services
docker compose down

# หยุดและลบ volumes
docker compose down -v

# Validate configuration
docker compose config

# ดู services ที่กำหนดไว้
docker compose config --services
```

**หมายเหตุ:** ใช้ `docker compose` (มีช่องว่าง) ไม่ใช่ `docker-compose` (มีขีด)

---

## ส่วนที่ 3: GitHub Actions YAML

### ทฤษฎี GitHub Actions
GitHub Actions เป็นระบบ CI/CD ที่สร้างไว้ใน GitHub ใช้ไฟล์ YAML ในการกำหนด workflows ที่จะทำงานอัตโนมัติ

### โครงสร้างพื้นฐาน .github/workflows/ci.yml
```yaml
name: Workflow Name           # ชื่อ workflow
on:                          # กำหนดว่าเมื่อไหร่จะทำงาน
  push:
  pull_request:

# SECURITY: จำกัดสิทธิ์ (Least Privilege)
permissions:
  contents: read
  packages: write

jobs:                        # กำหนด jobs ต่างๆ
  job_name:
    runs-on: ubuntu-latest
    steps:
      - name: Step name
        uses: action@version
      - name: Another step
        run: command
```

### ตัวอย่างที่ 2: CI/CD Pipeline สำหรับ Flask App

สร้างไฟล์ `.github/workflows/ci-cd.yml`:

```yaml
name: Flask CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  PYTHON_VERSION: '3.9'

# SECURITY: จำกัดสิทธิ์ตาม Least Privilege Principle
permissions:
  contents: read
  packages: write
  security-events: write
  pull-requests: write
  actions: read

jobs:
  # Job ที่ 1: ทดสอบโค้ด
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_PASSWORD: ${{ secrets.POSTGRES_PASSWORD }}
          POSTGRES_USER: ${{ secrets.POSTGRES_USER }}
          POSTGRES_DB: ${{ secrets.POSTGRES_DB }}
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U $POSTGRES_USER "
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

      - name: Set up test environment
        run: |
          echo "DATABASE_URL=postgresql://${{ secrets.POSTGRES_USER }}:${{ secrets.POSTGRES_PASSWORD }}@localhost:5432/${{ secrets.POSTGRES_DB }}" >> $GITHUB_ENV
          echo "REDIS_URL=redis://localhost:6379" >> $GITHUB_ENV
          echo "FLASK_ENV=testing" >> $GITHUB_ENV

      - name: Wait for services
        run: |
          timeout 60 bash -c 'until pg_isready -h localhost -p 5432 -U ${{ secrets.POSTGRES_USER }}; do sleep 2; done'
          echo "✅ PostgreSQL is ready!"
          timeout 60 bash -c 'until redis-cli -h localhost -p 6379 ping | grep -q PONG; do sleep 2; done'
          echo "✅ Redis is ready!"

      - name: Run tests with coverage
        run: |
          cd backend
          pytest tests/ -v --cov=. --cov-report=xml --cov-report=html
        env:
          DATABASE_URL: ${{ env.DATABASE_URL }}
          SECRET_KEY: ${{ secrets.SECRET_KEY }}

      - name: Upload coverage reports
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: backend/htmlcov/
          retention-days: 5

  # Job ที่ 2: Security Scanning ด้วย Snyk
  security-snyk:
    name: Snyk Security Scan
    runs-on: ubuntu-latest
    
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

      # SCA - Dependencies Scan
      - name: Run Snyk Dependencies Scan
        uses: snyk/actions/python@master
        continue-on-error: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high --file=backend/requirements.txt
          command: test

      # SAST - Code Scan
      - name: Run Snyk Code Scan
        uses: snyk/actions/python@master
        continue-on-error: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=medium --sarif-file-output=snyk-code.sarif
          command: code test

      - name: Upload SARIF to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: snyk-code.sarif

      - name: Monitor with Snyk
        if: github.ref == 'refs/heads/main'
        uses: snyk/actions/python@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --file=backend/requirements.txt
          command: monitor

  # Job ที่ 3: Additional Security Scans
  security-additional:
    name: Additional Security Scans
    runs-on: ubuntu-latest
    
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
          pip install bandit[toml]
          cd backend
          bandit -r . -f json -o bandit-report.json -ll || echo "⚠️ Bandit warnings found"
        continue-on-error: true

      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: auto
          generateSarif: "1"
        continue-on-error: true

      - name: Secret Scanning with TruffleHog
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
          extra_args: --only-verified

      - name: Upload security artifacts
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: security-reports
          path: |
            backend/safety-report.json
            backend/bandit-report.json
          retention-days: 30

  # Job ที่ 4: Build Docker Image
  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    needs: [test, security-snyk, security-additional]
    if: |
      always() && 
      needs.test.result == 'success' && 
      (needs.security-snyk.result == 'success' || needs.security-snyk.result == 'skipped')

    env:
      REGISTRY: ghcr.io
      IMAGE_NAME: ${{ github.repository }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Run Trivy container scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  # Job ที่ 5: Notify Results
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
            
            const comment = \`
            ## 🚀 CI/CD Pipeline Results
            
            | Job | Status | Result |
            |-----|--------|---------|
            | Tests | \${statusEmoji[testStatus] || '❓'} | \${testStatus} |
            | Snyk Security | \${statusEmoji[snykStatus] || '❓'} | \${snykStatus} |
            | Additional Security | \${statusEmoji[additionalSecurityStatus] || '❓'} | \${additionalSecurityStatus} |
            | Docker Build | \${statusEmoji[buildStatus] || '❓'} | \${buildStatus} |
            
            **Commit**: \\\`${{ github.sha }}\\\`
            **Branch**: \\\`${{ github.head_ref }}\\\`
            \`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });

      - name: Print summary
        run: |
          echo "=== Pipeline Summary ==="
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
docker compose ps --format "table {{.Name}}\t{{.State}}\t{{.Health}}" #เป็นการจัดรูปแบบการแสดงผลให้อยู่ในรูปแบบตารางที่อ่านง่ายขึ้น โดยจะแสดงข้อมูล 3 คอลัมน์คือ: 1. {{.Name}}: ชื่อของ container ดังนั้น เมื่อรันคำสั่งนี้รวมกัน จะเป็นการแสดงตารางสรุปสถานะและสถานะสุขภาพของทุก service ในโปรเจคของเรา ทำให้เราเห็นภาพรวมของระบบได้อย่างรวดเร็วว่า service ไหนทำงานปกติ, service ไหนมีปัญหา หรือ service ไหนยังไม่พร้อมใช้งาน
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
curl -s http://localhost:5000/ | python -m json.tool


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

- [✅] ไฟล์ทั้งหมดถูกสร้างครบ
- [✅] .env มี passwords ที่ปลอดภัย
- [✅] `docker compose config` ไม่มี error
- [✅] Services ทั้งหมด status เป็น "Up" และ "healthy"
- [✅] API endpoints ตอบกลับถูกต้อง
- [✅] Tests ผ่านทั้งหมด
- [✅] Database และ Redis เชื่อมต่อได้
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
<img width="1919" height="1011" alt="image" src="https://github.com/user-attachments/assets/0507c39f-2313-43ff-9b84-05a0453d7b8e" />
<img width="1919" height="614" alt="image" src="https://github.com/user-attachments/assets/b51ae273-f94b-4be4-b9d4-aa89cea2f4c0" />
<img width="1919" height="620" alt="image" src="https://github.com/user-attachments/assets/6fa7f338-89dd-4feb-82af-d079ea76d183" />

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

<img width="1911" height="917" alt="image" src="https://github.com/user-attachments/assets/7142f771-712e-440e-8173-01470643576b" />

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

<img width="1914" height="926" alt="image" src="https://github.com/user-attachments/assets/b203e674-bcbe-457d-baa4-0b1e30559d91" />

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

# คำตอบคำถามท้ายการทดลอง

## 1. Docker Compose คืออะไร มีความสำคัญอย่างไร

**Docker Compose** คือเครื่องมือสำหรับจัดการและรัน multi-container Docker applications โดยใช้ไฟล์ YAML เพื่อกำหนดค่าและจัดการ services หลายตัวพร้อมกัน

### ความสำคัญ:
- **จัดการ Multi-Service Applications**: สามารถรัน database, web server, cache, และ services อื่นๆ พร้อมกัน
- **Network Management**: สร้าง network ให้ containers สื่อสารกันได้อัตโนมัติ
- **Volume Management**: จัดการ persistent data และ shared storage
- **Environment Configuration**: กำหนด environment variables และ configurations
- **Development Consistency**: ทำให้ development environment เหมือนกับ production
- **Easy Deployment**: deploy และ scale applications ได้ง่าย

### ตัวอย่างการใช้งาน:
```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      - db
      - redis
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
  redis:
    image: redis:7-alpine
```

---

## 2. GitHub Pipeline คืออะไร เกี่ยวข้องกับ CI/CD อย่างไร

**GitHub Pipeline** (GitHub Actions Workflow) คือระบบ automation ที่ทำงานบน GitHub เพื่อสร้าง CI/CD pipeline

### ความเกี่ยวข้องกับ CI/CD:

#### **Continuous Integration (CI)**:
- **Automated Testing**: รัน tests อัตโนมัติเมื่อมี code changes
- **Code Quality Checks**: ตรวจสอบ code style, security vulnerabilities
- **Build Verification**: ตรวจสอบว่า code build ได้สำเร็จ
- **Integration Testing**: ทดสอบการทำงานร่วมกันของ components

#### **Continuous Deployment (CD)**:
- **Automated Deployment**: deploy application อัตโนมัติ
- **Environment Management**: จัดการ staging และ production environments
- **Release Management**: จัดการ versioning และ releases
- **Rollback Capabilities**: สามารถ rollback เมื่อเกิดปัญหา

### ประโยชน์:
- **Fast Feedback**: รู้ผลการทดสอบทันทีเมื่อ push code
- **Quality Assurance**: ป้องกัน bugs เข้า production
- **Automation**: ลดงาน manual และ human errors
- **Collaboration**: ทีมสามารถทำงานร่วมกันได้อย่างมีประสิทธิภาพ

---

## 3. จากไฟล์ Docker Compose ส่วนของ volumes, networks และ healthcheck มีความสำคัญอย่างไร

### **Volumes**:
```yaml
volumes:
  postgres_data:
  redis_data:
services:
  db:
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

**ความสำคัญ**:
- **Data Persistence**: เก็บข้อมูลไว้แม้ container หยุดทำงาน
- **Data Sharing**: แชร์ข้อมูลระหว่าง containers
- **Backup & Recovery**: สามารถ backup และ restore ข้อมูลได้
- **Performance**: เข้าถึงข้อมูลได้เร็วกว่าการ mount จาก host

### **Networks**:
```yaml
networks:
  app-network:
    driver: bridge
services:
  web:
    networks:
      - app-network
  db:
    networks:
      - app-network
```

**ความสำคัญ**:
- **Service Communication**: containers สื่อสารกันได้ผ่าน service names
- **Security Isolation**: แยก network traffic ระหว่าง applications
- **Load Balancing**: กระจาย traffic ระหว่าง containers
- **Service Discovery**: หา services อื่นๆ ได้อัตโนมัติ

### **Health Checks**:
```yaml
services:
  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

**ความสำคัญ**:
- **Service Monitoring**: ตรวจสอบสถานะ service อย่างต่อเนื่อง
- **Automatic Recovery**: restart container เมื่อ unhealthy
- **Dependency Management**: รอให้ dependencies พร้อมก่อน start
- **Load Balancer Integration**: ไม่ส่ง traffic ไป unhealthy containers

---

## 4. อธิบาย Code ของไฟล์ YAML ในส่วนนี้

```yaml
jobs:
  test:                           # ชื่อ job
    name: Run Tests              # ชื่อที่แสดงใน UI
    runs-on: ubuntu-latest       # OS ที่ใช้รัน job
    
    services:                    # Services ที่ต้องการสำหรับ testing
      postgres:                  # ชื่อ service
        image: postgres:16-alpine # Docker image ที่ใช้
        env:                     # Environment variables
          POSTGRES_PASSWORD: testpass
          POSTGRES_USER: testuser
          POSTGRES_DB: testdb
        ports:                   # Port mapping
          - 5432:5432           # host:container
        options: >-              # Docker run options
          --health-cmd "pg_isready -U testuser"  # คำสั่งตรวจสอบสุขภาพ
          --health-interval 10s   # ตรวจสอบทุก 10 วินาที
          --health-timeout 5s     # timeout 5 วินาที
          --health-retries 5      # retry 5 ครั้ง
```

### รายละเอียดแต่ละส่วน:

- **`runs-on: ubuntu-latest`**: ใช้ Ubuntu runner ล่าสุดจาก GitHub
- **`services`**: สร้าง service containers สำหรับ testing
- **`image: postgres:16-alpine`**: ใช้ PostgreSQL version 16 บน Alpine Linux (เบา)
- **`env`**: ตั้งค่า database credentials
- **`ports`**: เปิด port 5432 ให้ test code เข้าถึงได้
- **`health-cmd`**: ใช้ `pg_isready` ตรวจสอบว่า PostgreSQL พร้อมใช้งาน
- **Health check parameters**: ตั้งค่าการตรวจสอบให้รอจนกว่า DB จะพร้อม

---

## 5. จาก Code ในส่วนของ uses: actions/checkout@v4 และ uses: actions/setup-python@v5 คืออะไร

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v4      # Action สำหรับ download source code

  - name: Set up Python
    uses: actions/setup-python@v5  # Action สำหรับติดตั้ง Python
    with:
      python-version: ${{ env.PYTHON_VERSION }}  # Python version ที่ต้องการ
      cache: 'pip'                 # Cache pip dependencies
```

### **actions/checkout@v4**:
- **หน้าที่**: Download source code จาก repository มาใน runner
- **Version v4**: เป็น version ล่าสุดที่มี performance และ security improvements
- **ความจำเป็น**: ต้องมีเพื่อให้ runner เข้าถึง code ได้

### **actions/setup-python@v5**:
- **หน้าที่**: ติดตั้งและตั้งค่า Python environment
- **python-version**: กำหนด Python version (ใช้จาก environment variable)
- **cache: 'pip'**: Cache pip packages เพื่อเพิ่มความเร็วในการ build

### **GitHub Actions Marketplace**:
- **Pre-built Actions**: Actions เหล่านี้เป็น pre-built tools จาก community
- **Reusability**: สามารถใช้ซ้ำได้ในหลาย projects
- **Maintenance**: มี maintainers ดูแลและอัพเดท
- **Security**: ผ่านการตรวจสอบความปลอดภัย

### **Version Pinning**:
- **@v4, @v5**: ระบุ version เพื่อความเสถียร
- **Security**: ป้องกันการใช้ malicious updates
- **Reproducibility**: ทำให้ build results เหมือนเดิม

---

## 6. Snyk คืออะไร มีความสามารถอย่างไรบ้าง

**Snyk** คือ platform สำหรับ security testing และ vulnerability management ที่เน้น developer-first approach

### **ความสามารถหลัก**:

#### **1. Dependency Scanning**:
- **Open Source Vulnerabilities**: ตรวจสอบ vulnerabilities ใน dependencies
- **License Compliance**: ตรวจสอบ license issues
- **Automated Fixes**: แนะนำและสร้าง pull requests สำหรับแก้ไข
- **Database Coverage**: มี vulnerability database ที่ครอบคลุม

#### **2. Code Analysis (SAST)**:
- **Static Analysis**: วิเคราะห์ source code หา security issues
- **Custom Rules**: สร้าง security rules เฉพาะ organization
- **IDE Integration**: ตรวจสอบ real-time ใน IDE
- **Multiple Languages**: รองรับหลายภาษาโปรแกรม

#### **3. Container Security**:
- **Image Scanning**: ตรวจสอบ Docker images
- **Base Image Recommendations**: แนะนำ secure base images
- **Runtime Monitoring**: ตรวจสอบ containers ขณะทำงาน
- **Kubernetes Security**: ตรวจสอบ K8s configurations

#### **4. Infrastructure as Code (IaC)**:
- **Terraform Scanning**: ตรวจสอบ Terraform configurations
- **CloudFormation**: ตรวจสอบ AWS CloudFormation templates
- **Kubernetes YAML**: ตรวจสอบ K8s manifests
- **Misconfiguration Detection**: หา security misconfigurations

### **การใช้งานใน CI/CD**:

```yaml
- name: Run Snyk Dependencies Scan
  uses: snyk/actions/python@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high
    command: test

- name: Run Snyk Code Scan
  uses: snyk/actions/python@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    command: code test
```

### **ประโยชน์**:
- **Early Detection**: หา vulnerabilities ตั้งแต่ development phase
- **Automated Remediation**: แก้ไขปัญหาอัตโนมัติ
- **Developer Friendly**: integrate กับ workflow ที่มีอยู่
- **Continuous Monitoring**: ตรวจสอบอย่างต่อเนื่อง
- **Compliance**: ช่วยให้ comply กับ security standards
- **Risk Prioritization**: จัดลำดับความสำคัญของ vulnerabilities

### **Pricing Models**:
- **Free Tier**: สำหรับ open source projects
- **Team Plans**: สำหรับทีมเล็ก
- **Enterprise**: สำหรับองค์กรใหญ่ที่ต้องการ advanced features

---

## สรุป

การใช้เครื่องมือเหล่านี้ร่วมกันจะช่วยสร้าง **robust, secure, และ maintainable** software development lifecycle ที่มีประสิทธิภาพสูง โดยเฉพาะในยุค DevOps และ Cloud-native applications

