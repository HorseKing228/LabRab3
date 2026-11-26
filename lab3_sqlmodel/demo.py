"""demo.py — демонстрация запросов из requests.py."""
from datetime import datetime

import requests as q
from database import engine
from sqlmodel import Session


def show(title: str, rows) -> None:
    print(f"\n=== {title} ===")
    rows = list(rows)
    if not rows:
        print("(нет данных)")
    for row in rows:
        print("  ", tuple(row) if hasattr(row, "_mapping") else row)


with Session(engine) as session:
    show("Заказы клиента №1", q.get_client_orders(session, 1))
    show("Состав заказа №1", q.get_order_composition(session, 1))
    show("Незавершённые заказы", q.get_open_orders(session))
    show("Заказы типа «доставка»", q.get_orders_by_type(session, "доставка"))
    show("Выручка по категориям", q.get_sales_by_category(session))
    show("Меню «пицца»", q.get_products_by_category(session, "пицца"))
    show("Состав блюда №1 (Маргарита)", q.get_product_ingredients(session, 1))
    show("Ингредиенты ниже минимума", q.get_ingredients_below_min(session))
    show("Закупки по поставщикам", q.get_purchases_by_supplier(session))
    show("Доставленные заказы", q.get_deliveries_by_status(session, "доставлена"))
    show("Нагрузка курьеров", q.get_courier_load(session))
    show("Топ клиентов", q.get_top_clients(session))

    new_order = q.create_order(
        session, client_id=2, order_type="доставка",
        items=[(1, 2), (3, 1)], address_id=3,
    )
    show("Создан заказ", [(new_order.id, new_order.total_amount)])
    show("Состав созданного заказа", q.get_order_composition(session, new_order.id))