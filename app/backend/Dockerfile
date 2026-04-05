FROM python:3.13-bookworm

WORKDIR /app

COPY ./ /app

RUN python -m pip install -r requirements.txt

EXPOSE 8000

CMD ["python3", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
