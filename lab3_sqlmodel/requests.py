"""
requests.py — запросы к БД пиццерии для основных процессов.
"""
from datetime import date, datetime
from decimal import Decimal
from typing import Iterable, Optional

from sqlalchemy import case, desc, func
from sqlmodel import Session, col, select

from models import (
    Address, Category, Client, Delivery, Employee, Ingredient, Order, OrderItem,
    OrderStatus, Payment, PaymentMethod, Product, ProductIngredient, Purchase,
    PurchaseItem, Supplier,
)

OPEN_ORDER_STATUSES = ("Новый", "Подтверждён", "Готовится", "Готов")


# ====================================================================
# 1. Заказы
# ====================================================================
def get_client_orders(session: Session, client_id: int):
    """Все заказы клиента, новые сверху."""
    stmt = (
        select(Order)
        .where(Order.client_id == client_id)
        .order_by(desc(Order.order_datetime))
    )
    return session.exec(stmt).all()


def get_order_composition(session: Session, order_id: int):
    """Состав заказа."""
    stmt = (
        select(OrderItem.id, Product.name, OrderItem.quantity,
               OrderItem.unit_price, OrderItem.discount, OrderItem.amount)
        .select_from(OrderItem)
        .join(Product, Product.id == OrderItem.product_id)
        .where(OrderItem.order_id == order_id)
    )
    return session.exec(stmt).all()


def get_open_orders(session: Session):
    """Незавершённые заказы."""
    stmt = (
        select(Order.id, Client.last_name, Client.first_name,
               Order.order_datetime, OrderStatus.name.label("status"), Order.total_amount)
        .select_from(Order)
        .join(Client, Client.id == Order.client_id)
        .join(OrderStatus, OrderStatus.id == Order.status_id)
        .where(col(OrderStatus.name).in_(OPEN_ORDER_STATUSES))
        .order_by(Order.order_datetime)
    )
    return session.exec(stmt).all()


def get_orders_by_type(session: Session, order_type: str):
    """Заказы по типу получения."""
    stmt = (
        select(Order.id, Client.last_name, Order.order_datetime, Order.total_amount)
        .select_from(Order)
        .join(Client, Client.id == Order.client_id)
        .where(Order.order_type == order_type)
        .order_by(desc(Order.order_datetime))
    )
    return session.exec(stmt).all()


def get_sales_by_category(session: Session):
    """Выручка по категориям блюд."""
    revenue = func.sum(OrderItem.amount)
    stmt = (
        select(Category.name, func.count(OrderItem.id).label("items"),
               revenue.label("revenue"))
        .select_from(OrderItem)
        .join(Product, Product.id == OrderItem.product_id)
        .join(Category, Category.id == Product.category_id)
        .group_by(Category.id, Category.name)
        .order_by(desc(revenue))
    )
    return session.exec(stmt).all()


def create_order(
    session: Session,
    client_id: int,
    order_type: str,
    items: Iterable[tuple[int, int]],
    status_id: int = 1,
    address_id: Optional[int] = None,
) -> Order:
    """Создаёт заказ с позициями. items — пары (product_id, quantity)."""
    order = Order(
        client_id=client_id,
        order_datetime=datetime.now(),
        status_id=status_id,
        order_type=order_type,
        address_id=address_id,
    )
    session.add(order)
    session.flush()
    total = Decimal("0")
    for product_id, quantity in items:
        product = session.get(Product, product_id)
        if product is None:
            raise ValueError(f"Блюдо id={product_id} не найдено")
        amount = product.price * quantity
        session.add(OrderItem(
            order_id=order.id, product_id=product_id, quantity=quantity,
            unit_price=product.price, amount=amount,
        ))
        total += amount
    order.total_amount = total
    session.add(order)
    session.commit()
    session.refresh(order)
    return order


# ====================================================================
# 2. Кухня / склад
# ====================================================================
def get_products_by_category(session: Session, category_name: str):
    """Меню по категории."""
    stmt = (
        select(Product.id, Product.name, Product.price, Product.cooking_time)
        .join(Category, Category.id == Product.category_id)
        .where(Category.name == category_name, Product.is_available == True)
        .order_by(Product.name)
    )
    return session.exec(stmt).all()


def get_product_ingredients(session: Session, product_id: int):
    """Состав блюда."""
    stmt = (
        select(Ingredient.name, ProductIngredient.quantity, ProductIngredient.unit)
        .select_from(ProductIngredient)
        .join(Ingredient, Ingredient.id == ProductIngredient.ingredient_id)
        .where(ProductIngredient.product_id == product_id)
    )
    return session.exec(stmt).all()


def get_ingredients_below_min(session: Session):
    """Ингредиенты ниже минимального запаса."""
    stmt = (
        select(Ingredient.name, Ingredient.quantity_in_stock, Ingredient.minimum_quantity)
        .where(Ingredient.quantity_in_stock < Ingredient.minimum_quantity)
    )
    return session.exec(stmt).all()


def get_purchases_by_supplier(session: Session):
    """Закупки по поставщикам."""
    amount = func.sum(Purchase.total_amount)
    stmt = (
        select(Supplier.name, func.count(Purchase.id).label("deliveries"),
               amount.label("amount"))
        .select_from(Purchase)
        .join(Supplier, Supplier.id == Purchase.supplier_id)
        .group_by(Supplier.id, Supplier.name)
        .order_by(desc(amount))
    )
    return session.exec(stmt).all()


# ====================================================================
# 3. Доставка
# ====================================================================
def get_deliveries_by_status(session: Session, status: str):
    """Доставки по статусу."""
    stmt = (
        select(Delivery.id, Order.id.label("order_id"),
               Employee.last_name.label("courier"),
               Delivery.delivery_status, Delivery.delivery_time)
        .select_from(Delivery)
        .join(Order, Order.id == Delivery.order_id)
        .join(Employee, Employee.id == Delivery.courier_id)
        .where(Delivery.delivery_status == status)
    )
    return session.exec(stmt).all()


def get_courier_load(session: Session):
    """Нагрузка курьеров: число доставок."""
    stmt = (
        select(Employee.last_name, Employee.first_name,
               func.count(Delivery.id).label("deliveries"))
        .select_from(Delivery)
        .join(Employee, Employee.id == Delivery.courier_id)
        .group_by(Employee.id, Employee.last_name, Employee.first_name)
        .order_by(desc(func.count(Delivery.id)))
    )
    return session.exec(stmt).all()


# ====================================================================
# 4. Клиенты
# ====================================================================
def get_top_clients(session: Session):
    """Топ клиентов по сумме заказов."""
    total = func.sum(Order.total_amount)
    stmt = (
        select(Client.last_name, Client.first_name,
               func.count(Order.id).label("orders"), total.label("total"))
        .select_from(Order)
        .join(Client, Client.id == Order.client_id)
        .group_by(Client.id, Client.last_name, Client.first_name)
        .order_by(desc(total))
    )
    return session.exec(stmt).all()