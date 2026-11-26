"""
models.py — модели SQLModel для базы данных пиццерии.

Соответствуют 18 сущностям из лабораторных работ №1–2.
"""
from datetime import date
from decimal import Decimal
from typing import List, Optional

from sqlalchemy import CheckConstraint, Column, ForeignKey, Index, UniqueConstraint
from pydantic import NaiveDatetime
from sqlmodel import Field, Relationship, SQLModel


# ====================================================================
# 1. Справочники
# ====================================================================
class Position(SQLModel, table=True):
    """Должность сотрудника (справочник)."""
    __tablename__ = "positions"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=80, unique=True)
    description: Optional[str] = Field(default=None, max_length=255)


class PaymentMethod(SQLModel, table=True):
    """Способ оплаты (справочник)."""
    __tablename__ = "payment_methods"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=60, unique=True)
    description: Optional[str] = Field(default=None, max_length=255)


class OrderStatus(SQLModel, table=True):
    """Статус заказа (справочник)."""
    __tablename__ = "order_statuses"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=60, unique=True)
    description: Optional[str] = Field(default=None, max_length=255)


class Category(SQLModel, table=True):
    """Категория блюда (справочник)."""
    __tablename__ = "categories"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=60, unique=True)
    description: Optional[str] = Field(default=None, max_length=255)


class Size(SQLModel, table=True):
    """Размер пиццы (справочник)."""
    __tablename__ = "sizes"
    __table_args__ = (
        CheckConstraint("diameter_cm > 0", name="ck_size_diameter"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=30, unique=True)
    diameter_cm: int
    description: Optional[str] = Field(default=None, max_length=255)


class Supplier(SQLModel, table=True):
    """Поставщик (справочник)."""
    __tablename__ = "suppliers"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=150, unique=True)
    contact_person: Optional[str] = Field(default=None, max_length=120)
    phone: Optional[str] = Field(default=None, max_length=30)
    email: Optional[str] = Field(default=None, max_length=100)
    address: Optional[str] = Field(default=None, max_length=255)


# ====================================================================
# 2. Мастер-данные
# ====================================================================
class Employee(SQLModel, table=True):
    """Сотрудник."""
    __tablename__ = "employees"
    __table_args__ = (
        CheckConstraint("status IN ('работает','уволен')", name="ck_employee_status"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    first_name: str = Field(max_length=50)
    last_name: str = Field(max_length=50)
    phone: str = Field(max_length=20, unique=True)
    email: Optional[str] = Field(default=None, max_length=100, unique=True)
    position_id: int = Field(foreign_key="positions.id")
    hire_date: date
    status: str = Field(default="работает", max_length=20)


class Client(SQLModel, table=True):
    """Клиент."""
    __tablename__ = "clients"
    __table_args__ = (
        CheckConstraint("status IN ('активен','заблокирован')", name="ck_client_status"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    first_name: str = Field(max_length=50)
    last_name: str = Field(max_length=50)
    phone: str = Field(max_length=20, unique=True)
    email: Optional[str] = Field(default=None, max_length=100, unique=True)
    registration_date: date
    status: str = Field(default="активен", max_length=20)

    addresses: List["Address"] = Relationship(back_populates="client")
    orders: List["Order"] = Relationship(back_populates="client")


class Ingredient(SQLModel, table=True):
    """Ингредиент."""
    __tablename__ = "ingredients"
    __table_args__ = (
        CheckConstraint("quantity_in_stock >= 0", name="ck_ingredient_stock"),
        CheckConstraint("minimum_quantity >= 0", name="ck_ingredient_min"),
        CheckConstraint("purchase_price >= 0", name="ck_ingredient_price"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=120)
    unit: str = Field(max_length=20)
    quantity_in_stock: Decimal = Field(default=Decimal("0"), max_digits=10, decimal_places=3)
    minimum_quantity: Decimal = Field(default=Decimal("0"), max_digits=10, decimal_places=3)
    purchase_price: Decimal = Field(max_digits=10, decimal_places=2)
    expiration_date: Optional[date] = None


class Product(SQLModel, table=True):
    """Блюдо (позиция меню)."""
    __tablename__ = "products"
    __table_args__ = (
        CheckConstraint("price >= 0", name="ck_product_price"),
        CheckConstraint("weight > 0", name="ck_product_weight"),
        CheckConstraint("cooking_time > 0", name="ck_product_time"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    category_id: int = Field(foreign_key="categories.id")
    name: str = Field(max_length=120)
    description: Optional[str] = Field(default=None, max_length=255)
    price: Decimal = Field(max_digits=10, decimal_places=2)
    weight: Decimal = Field(max_digits=8, decimal_places=3)
    cooking_time: int  # минуты
    is_available: bool = Field(default=True)
    image_url: Optional[str] = Field(default=None, max_length=255)


# ====================================================================
# 3. Связующие таблицы (M:N)
# ====================================================================
class ProductIngredient(SQLModel, table=True):
    """Состав блюда: блюдо ↔ ингредиент."""
    __tablename__ = "product_ingredients"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="ck_pi_quantity"),
    )

    product_id: int = Field(foreign_key="products.id", primary_key=True)
    ingredient_id: int = Field(foreign_key="ingredients.id", primary_key=True)
    quantity: Decimal = Field(max_digits=10, decimal_places=3)
    unit: str = Field(max_length=20)


class ProductSize(SQLModel, table=True):
    """Размеры блюда: блюдо ↔ размер (для пиццы)."""
    __tablename__ = "product_sizes"
    __table_args__ = (
        CheckConstraint("price_delta >= 0", name="ck_ps_price_delta"),
    )

    product_id: int = Field(foreign_key="products.id", primary_key=True)
    size_id: int = Field(foreign_key="sizes.id", primary_key=True)
    price_delta: Decimal = Field(default=Decimal("0"), max_digits=10, decimal_places=2)


class OrderItem(SQLModel, table=True):
    """Позиция заказа: заказ ↔ блюдо."""
    __tablename__ = "order_items"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="ck_oi_quantity"),
        CheckConstraint("unit_price >= 0", name="ck_oi_price"),
        CheckConstraint("discount >= 0", name="ck_oi_discount"),
        CheckConstraint("amount >= 0", name="ck_oi_amount"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    order_id: int = Field(foreign_key="orders.id")
    product_id: int = Field(foreign_key="products.id")
    size_id: Optional[int] = Field(default=None, foreign_key="sizes.id")
    quantity: int
    unit_price: Decimal = Field(max_digits=10, decimal_places=2)
    discount: Decimal = Field(default=Decimal("0"), max_digits=10, decimal_places=2)
    amount: Decimal = Field(max_digits=10, decimal_places=2)


class PurchaseItem(SQLModel, table=True):
    """Позиция закупки: закупка ↔ ингредиент."""
    __tablename__ = "purchase_items"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="ck_puri_quantity"),
        CheckConstraint("unit_price >= 0", name="ck_puri_price"),
        CheckConstraint("amount >= 0", name="ck_puri_amount"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    purchase_id: int = Field(foreign_key="purchases.id")
    ingredient_id: int = Field(foreign_key="ingredients.id")
    quantity: Decimal = Field(max_digits=10, decimal_places=3)
    unit_price: Decimal = Field(max_digits=10, decimal_places=2)
    amount: Decimal = Field(max_digits=12, decimal_places=2)


# ====================================================================
# 4. Транзакционные таблицы
# ====================================================================
class Address(SQLModel, table=True):
    """Адрес клиента (для доставки)."""
    __tablename__ = "addresses"

    id: Optional[int] = Field(default=None, primary_key=True)
    client_id: int = Field(foreign_key="clients.id")
    city: str = Field(max_length=100)
    street: str = Field(max_length=100)
    house: str = Field(max_length=10)
    apartment: Optional[str] = Field(default=None, max_length=10)
    entrance: Optional[str] = Field(default=None, max_length=10)
    floor: Optional[str] = Field(default=None, max_length=10)
    comment: Optional[str] = Field(default=None, max_length=255)

    client: Optional[Client] = Relationship(back_populates="addresses")


class Order(SQLModel, table=True):
    """Заказ."""
    __tablename__ = "orders"
    __table_args__ = (
        CheckConstraint("total_amount >= 0", name="ck_order_total"),
        CheckConstraint("discount_amount >= 0", name="ck_order_discount"),
        CheckConstraint("order_type IN ('в зале','доставка','самовывоз')", name="ck_order_type"),
        Index("ix_order_client_date", "client_id", "order_datetime"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    client_id: int = Field(foreign_key="clients.id")
    order_datetime: NaiveDatetime
    status_id: int = Field(foreign_key="order_statuses.id")
    order_type: str = Field(max_length=20)
    address_id: Optional[int] = Field(default=None, foreign_key="addresses.id")
    total_amount: Decimal = Field(default=Decimal("0"), max_digits=12, decimal_places=2)
    discount_amount: Decimal = Field(default=Decimal("0"), max_digits=12, decimal_places=2)
    comment: Optional[str] = Field(default=None, max_length=255)

    client: Optional[Client] = Relationship(back_populates="orders")
    items: List["OrderItem"] = Relationship()


class Payment(SQLModel, table=True):
    """Оплата заказа (может быть несколько на один заказ)."""
    __tablename__ = "payments"
    __table_args__ = (
        CheckConstraint("amount > 0", name="ck_payment_amount"),
        CheckConstraint("status IN ('проведён','возврат','отменён')", name="ck_payment_status"),
        Index("ix_payment_order", "order_id"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    order_id: int = Field(foreign_key="orders.id")
    payment_method_id: int = Field(foreign_key="payment_methods.id")
    amount: Decimal = Field(max_digits=12, decimal_places=2)
    payment_datetime: NaiveDatetime
    status: str = Field(default="проведён", max_length=20)
    transaction_number: Optional[str] = Field(default=None, max_length=60, unique=True)


class Delivery(SQLModel, table=True):
    """Доставка заказа."""
    __tablename__ = "deliveries"
    __table_args__ = (
        CheckConstraint("delivery_cost >= 0", name="ck_delivery_cost"),
        CheckConstraint("delivery_status IN ('назначена','в пути','доставлена','отменена')",
                        name="ck_delivery_status"),
        Index("ix_delivery_order", "order_id"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    order_id: int = Field(foreign_key="orders.id")
    courier_id: int = Field(foreign_key="employees.id")
    address_id: int = Field(foreign_key="addresses.id")
    delivery_status: str = Field(default="назначена", max_length=20)
    pickup_time: Optional[NaiveDatetime] = None
    delivery_time: Optional[NaiveDatetime] = None
    delivery_cost: Decimal = Field(default=Decimal("0"), max_digits=10, decimal_places=2)


class Purchase(SQLModel, table=True):
    """Закупка ингредиентов."""
    __tablename__ = "purchases"
    __table_args__ = (
        CheckConstraint("total_amount >= 0", name="ck_purchase_total"),
        CheckConstraint("status IN ('оформлена','получена','отменена')", name="ck_purchase_status"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    supplier_id: int = Field(foreign_key="suppliers.id")
    employee_id: int = Field(foreign_key="employees.id")
    purchase_date: date
    total_amount: Decimal = Field(default=Decimal("0"), max_digits=12, decimal_places=2)
    status: str = Field(default="оформлена", max_length=20)