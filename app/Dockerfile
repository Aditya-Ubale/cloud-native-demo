# ---------- Base image ----------
FROM python:3.11-slim

# Avoid .pyc files and enable unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_VERSION=1.0.0

# ---------- Working directory ----------
WORKDIR /app

# ---------- Install dependencies first (better layer caching) ----------
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---------- Copy application source ----------
COPY app.py .

# ---------- Run as non-root user ----------
RUN useradd -m appuser
USER appuser

# ---------- Networking ----------
EXPOSE 5000

# ---------- Start the app with gunicorn ----------
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
