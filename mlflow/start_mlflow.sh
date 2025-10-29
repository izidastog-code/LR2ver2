#!/usr/bin/env bash
set -e

# Рабочая директория: ./mlflow
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$THIS_DIR"

export MLFLOW_TRACKING_URI="http://127.0.0.1:5000"

mlflow server \
  --backend-store-uri sqlite:///mlruns.db \
  --registry-store-uri sqlite:///mlruns.db \
  --artifacts-destination ./mlartifacts \
  --host 127.0.0.1 \
  --port 5000
