FROM python:3.11-slim AS builder
WORKDIR /app
RUN pip install --no-cache-dir flask

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY app.py .

EXPOSE 5000
ENV ENV=Production

USER 1001

CMD ["python", "app.py"]