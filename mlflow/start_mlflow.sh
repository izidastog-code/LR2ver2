#!/bin/bash
# === start_mlflow.sh ===
# Скрипт запуска MLflow UI для локального проекта

# Папка для логов и артефактов (тот же путь, что в ноутбуке)
BACKEND_STORE_URI="./mlflow"
PORT=5000

echo "Запуск MLflow UI..."
echo "URI: ${BACKEND_STORE_URI}"
echo "Открой в браузере: http://127.0.0.1:${PORT}"

# Если нужно — можно сменить порт, например, на 5001
mlflow ui --backend-store-uri "${BACKEND_STORE_URI}" --port ${PORT}
