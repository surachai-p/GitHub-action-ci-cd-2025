# Stage 1: Builder - ติดตั้ง dependencies
FROM python:3.9-slim as builder

WORKDIR /app

# Copy requirements และติดตั้ง
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime - สร้าง image สุดท้าย
FROM python:3.9-slim

# ติดตั้ง dependencies ที่จำเป็น
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV PYTHONPATH=/app

# Copy dependencies จาก builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code
COPY backend/app.py .
COPY backend/tests/ tests/

EXPOSE 5000

CMD ["python", "app.py"]
