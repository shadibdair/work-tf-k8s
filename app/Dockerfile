FROM python:3.12-slim

WORKDIR /app

# Keep runtime behavior deterministic and logs unbuffered in containers.
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

EXPOSE 8080

# Production HTTP server used by Kubernetes Deployment.
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "src.app:app"]