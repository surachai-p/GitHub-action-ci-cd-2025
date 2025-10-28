# ---------------- Base Image ----------------
FROM python:3.9-slim

# ---------------- System Dependencies ----------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ---------------- Working Directory ----------------
WORKDIR /app
ENV PYTHONPATH=/app

# ---------------- Install Python Dependencies ----------------
# แยกขั้นตอนนี้เพื่อลด build cache invalidation
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---------------- Copy Application Code ----------------
COPY backend/ .

# ---------------- Expose Port ----------------
EXPOSE 5000

# ---------------- Run App ----------------
CMD ["python", "app.py"]
