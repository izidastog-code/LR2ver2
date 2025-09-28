# Heart Disease EDA (ЛР-1)

Этот репозиторий содержит проект по первичной загрузке данных, их очистке и исследовательскому анализу (EDA) 
на примере набора данных о сердечно-сосудистых заболеваниях.


---

## Состав репозитория

- `eda/` — скрипты для EDA.
- `.gitignore` — исключения из Git (виртуальные окружения, кэши и др.).
- `requirements.txt` — список зависимостей.
- `.vscode/` — настройки VS Code.
- `README.md` — этот файл (рекомендуется переименовать текущий `READ.me` → `README.md`).

---

## Быстрый старт

### 1. Установить Python и создать виртуальное окружение

sudo apt update
sudo apt install -y python3.13-venv
python3.13 -m venv .venv
source .venv/bin/activate
### 2. Установить зависимости
pip install -U pip
pip install -r requirements.txt
### 3. Запустить eda
Версия Python: 3.12+ (рекомендуется).
ависимости: см. requirements.txt.
IDE: VS Code. 
Выберите интерпретатор: Ctrl+Shift+P → Python: Select Interpreter → путь к ./.venv/bin/python.
### 3. Структура проекта
LR1/
├─ eda/                 # скрипты EDA
│  └─ 03_eda.ipynb      # визуализация и статистический анализ
├─ requirements.txt     # зависимости
├─ .gitignore           # исключения Git
├─ .vscode/             # настройки VS Code
└─ READ.me            # описание проекта

