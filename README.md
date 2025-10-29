
# LR2 — Эксперименты, настройка модели и логирование в MLflow

*(продолжение ЛР1 по датасету “Heart Disease” — задача **классификации**)*

Репозиторий содержит:

* структуру проекта;
* ноутбук `research/research.ipynb` с экспериментами ЛР2;
* локальный запуск **MLflow** (SQLite бэкенд + файловые артефакты);
* зарегистрированную в MLflow модель с версией, помеченной тегом **Production**.


## Датасет

* **Heart Disease** (табличные данные; бинарная классификация).
  Признаки: `age, sex, cp, trestbps, chol, fbs, restecg, thalach, exang, oldpeak, slope, ca, thal`
  Целевая переменная: `target`.
* Очистка и первичная подготовка были выполнены в **ЛР1** и использованы далее в ЛР2.

---

## Структура проекта

```
my_proj/
├─ data/                       # данные (в репозиторий НЕ коммитятся)
├─ eda/                        # ноутбук ЛР1 и графики
├─ research/
│  ├─ research.ipynb           # ноутбук ЛР2 (все эксперименты)
│  ├─ fe_sklearn_columns.txt   # имена столбцов после FE (sklearn)
│  ├─ sfs_feature_names.txt    # имена отобранных SFS
│  ├─ sfs_indices.json         # индексы отобранных SFS
│  ├─ model_runs.png           # скрин с метриками всех прогонов (п.17)
│  ├─ model_versions.png       # скрин с версиями модели (п.17)
│  └─ MLmodel                  # файл MLmodel из артефактов Production (п.17)
├─ mlflow/
│  ├─ start_mlflow.sh          # скрипт запуска MLflow
│  ├─ mlruns.db                # SQLite-база MLflow
│  └─ mlartifacts/             # артефакты прогонов
├─ requirements.txt
├─ .gitignore
└─ README.md
```

---

## Подготовка окружения

```bash
# Python 3.13 (или 3.12)
sudo apt update
sudo apt install -y python3.13-venv

# создать и активировать venv в корне проекта
python3.13 -m venv .venv
source .venv/bin/activate

# обновить pip
pip install -U pip
```

---

## Зависимости

Установил основные зависимости:

```bash
pip install -r requirements.txt
```

> Для совместимости с Python 3.13 используется связка **NumPy 2.x + scikit-learn ≥1.6** и **mlflow-skinny**.
> Чтобы получить **UI** MLflow, дополнительно установлен полноценный пакет **без** зависимостей:

```bash
pip install --no-deps mlflow==2.16
```

`requirements.txt`:

```
numpy>=2.2,<3
scipy>=1.14
pandas>=2.2
scikit-learn>=1.6

mlflow-skinny==2.16
# UI добавляется отдельной командой:
# pip install --no-deps mlflow==2.16

sqlalchemy>=2,<3
alembic>=1.13,<2
category-encoders>=2.6.3
mlxtend>=0.23.1
optuna>=3.6.1
```

---

## Запуск MLflow

`mlflow/start_mlflow.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

export MLFLOW_TRACKING_URI="http://127.0.0.1:5000"

exec mlflow server \
  --backend-store-uri sqlite:///mlruns.db \
  --registry-store-uri sqlite:///mlruns.db \
  --artifacts-destination ./mlartifacts \
  --host 127.0.0.1 \
  --port 5000
```

Запуск:

```bash
cd mlflow
chmod +x start_mlflow.sh
bash start_mlflow.sh
# UI → http://127.0.0.1:5000
```

---

## Как воспроизвести эксперименты ЛР2

Работа ведётся в `research/research.ipynb` (ячейки запускаются по порядку):

1. **Загрузка и сплит** датасета (train/test = 75/25).
   Определены списки `numeric_features` и `categorical_features` (в данном датасете все признаки оказались числовыми).

2. **Baseline**:

   * `ColumnTransformer`: `StandardScaler` для численных, `TargetEncoder` для категориальных (если есть).
   * Модель: `RandomForestClassifier`.
   * Метрики: `precision`, `recall`, `f1`, `roc_auc`.
   * Логирование в MLflow (отдельный Run).

3. **Feature Engineering (sklearn)**:

   * `PolynomialFeatures(degree=2)` для 2–3 числовых;
   * `KBinsDiscretizer` для 2–3 числовых;
   * масштабирование оставшихся числовых;
   * сохранение имён новых признаков;
   * обучение RF, логирование метрик и артефактов.

4. **Отбор признаков (SFS, forward)**:

   * `sklearn.feature_selection.SequentialFeatureSelector` (совместим со sklearn≥1.6);
   * выбрано ~50% признаков;
   * сохранены индексы и имена;
   * обучение RF на выбранных признаках;
   * логирование метрик и артефактов.

5. **Подбор гиперпараметров (Optuna)**:

   * Для лучшего пайплайна (FE + SFS);
   * Подбирались `n_estimators`, `max_depth`, `max_features`;
   * Цель — `f1` (**maximize**);
   * Обучение лучшей модели, логирование и **регистрация** в MLflow (версия 1).

6. **Production-модель**:

   * Обучение лучшей конфигурации на **всей выборке**;
   * Логирование модели + сигнатура, пример входа, списки признаков;
   * Регистрация новой версии (версия 2) и проставление тега **`Production`**.

---

## Что именно сделано в ЛР2

* Эксперименты велись в эксперименте **`LR2_Estate`**.
* Зарегистрированная модель: **`estate_rf_regressor`**
  (историческое имя от регрессии, фактически — **RandomForestClassifier** в sklearn-пайплайне).
* Версия **2** помечена тегом **`Production`**.
* `run_id` Production-прогона: **`3dd1099eae3040e286f0006a0666caa2`**.
* Лучшая конфигурация (Optuna):
  `n_estimators=224`, `max_depth=35`, `max_features≈0.5808`
  (точные значения зафиксированы в карточке прогона в MLflow).

---

## Результаты

Ключевые прогоны (см. вкладку **Runs** в UI):

* `fe_sklearn` — расширение признаков (poly2 + kbins).
* `fe_sklearn + sfs_forward (sklearn SFS)` — отбор ~50% лучших признаков.
* `optuna_tuned_rf` — подбор гиперпараметров по `f1`.
* `production_fullfit` — обучение на всей выборке, публикация в реестр моделей.

На графиках MLflow видно устойчивый рост `f1`, `precision`, `recall`, `roc_auc` после FE, SFS и тюнинга.
CV-значение лучшего `f1` по Optuna ≈ **0.855**; финальные тестовые метрики доступны в UI прогона.

---

## Скриншоты 

Положил и закоммитил в `research/`:

* `model_runs.png` — экран Runs с графиками метрик.
* `model_versions.png` — экран Models с версиями (v1/v2; v2 — Production).
* `MLmodel` — файл из артефактов `production_fullfit`.

---

## .gitignore

```
# данные и модели
data/*.csv
*.pkl

# MLflow локальные артефакты и БД
mlflow/mlartifacts/
mlflow/mlruns.db

# окружения
.venv*
```

---


