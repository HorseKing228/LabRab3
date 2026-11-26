"""database.py — подключение к базе данных SQLite и создание таблиц."""
import warnings
from pathlib import Path

from sqlalchemy import event
from sqlmodel import Session, SQLModel, create_engine

warnings.filterwarnings("ignore", message=".*Decimal objects natively.*")

DB_PATH = Path(__file__).with_name("pizzeria.db")
engine = create_engine(f"sqlite:///{DB_PATH}", echo=False)


@event.listens_for(engine, "connect")
def _enable_foreign_keys(dbapi_connection, _record):
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()


def create_db_and_tables() -> None:
    import models  # noqa: F401
    SQLModel.metadata.create_all(engine)


def get_session():
    with Session(engine) as session:
        yield session