FROM python:3.9-slim

# ติดตั้ง dependencies ที่จำเป็น
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV PYTHONPATH=/app
# Copy requirements และติดตั้ง
COPY my-flask-app/backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY my-flask-app/backend/ .

EXPOSE 5000

CMD ["python", "app.py"]