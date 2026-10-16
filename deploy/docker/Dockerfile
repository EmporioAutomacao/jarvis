FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# RealtimeSTT may compile/download sizeable dependencies; keeping this in the
# image makes restarts deterministic and avoids mutating a Portainer host.
COPY server/requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install -r /app/requirements.txt

COPY server /app
RUN mkdir -p /app/logs /app/certs && \
    cp /app/config/server.example.yaml /app/config/server.yaml

EXPOSE 8765

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8765/health', timeout=3)"

ENTRYPOINT ["python", "/app/server.py"]