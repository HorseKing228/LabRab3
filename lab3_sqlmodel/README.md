# Лабораторная работа №3. Использование SQLModel

Предметная область: пиццерия.
СУБД: SQLite 3 (файл `pizzeria.db`).

## Состав
| Файл | Назначение |
|---|---|
| `models.py` | 18 моделей SQLModel |
| `requests.py` | Запросы к БД (12 функций) |
| `database.py` | Подключение к SQLite |
| `seed.py`, `seed_data.sql` | Создание и наполнение БД |
| `demo.py` | Демонстрация запросов |
| `db_schema.sql` | DDL-схема |
| `queries.sql` | SQL-эквиваленты запросов |

## Запуск
```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python seed.py
python demo.py
```
## Пошаговый чек-лист действий

1. **Создай папку** `pizzeria_lab3` и перейди в неё.
2. **Скопируй** `requirements.txt` (см. выше).
3. **Создай виртуальное окружение** и установи зависимости:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate        # Windows
   pip install -r requirements.txt