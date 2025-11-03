FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# CPU 전용 PyTorch (CUDA 안받게 인덱스 고정)
RUN pip install --no-cache-dir \
    --index-url https://download.pytorch.org/whl/cpu \
    torch torchvision torchaudio && \
    pip install --no-cache-dir --upgrade pip

COPY requirements-chatbot.txt /app/
# requirements-chatbot.txt 안에서 torch는 제거해 두세요 (중복 설치 방지)
RUN pip install --no-cache-dir -r requirements-chatbot.txt

COPY . /app

ENV PORT=9000
ENV APP_MODULE=src.uosai.chat.chatbot:app

EXPOSE 9000
CMD ["sh", "-c", "python -m uvicorn ${APP_MODULE} --host 0.0.0.0 --port ${PORT}"]