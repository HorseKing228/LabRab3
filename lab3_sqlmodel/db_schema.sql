-- Лабораторная работа №3. Пиццерия
-- СУБД: SQLite (совместимо с PostgreSQL)

CREATE TABLE positions (
    id INTEGER NOT NULL,
    name VARCHAR(80) NOT NULL,
    description VARCHAR(255),
    PRIMARY KEY (id),
    UNIQUE (name)
);

CREATE TABLE payment_methods (
    id INTEGER NOT NULL,
    name VARCHAR(60) NOT NULL,
    description VARCHAR(255),
    PRIMARY KEY (id),
    UNIQUE (name)
);

CREATE TABLE order_statuses (
    id INTEGER NOT NULL,
    name VARCHAR(60) NOT NULL,
    description VARCHAR(255),
    PRIMARY KEY (id),
    UNIQUE (name)
);

CREATE TABLE categories (
    id INTEGER NOT NULL,
    name VARCHAR(60) NOT NULL,
    description VARCHAR(255),
    PRIMARY KEY (id),
    UNIQUE (name)
);

CREATE TABLE sizes (
    id INTEGER NOT NULL,
    name VARCHAR(30) NOT NULL,
    diameter_cm INTEGER NOT NULL,
    description VARCHAR(255),
    PRIMARY KEY (id),
    UNIQUE (name),
    CONSTRAINT ck_size_diameter CHECK (diameter_cm > 0)
);

CREATE TABLE suppliers (
    id INTEGER NOT NULL,
    name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(120),
    phone VARCHAR(30),
    email VARCHAR(100),
    address VARCHAR(255),
    PRIMARY KEY (id),
    UNIQUE (name)
);

CREATE TABLE employees (
    id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    position_id INTEGER NOT NULL,
    hire_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (phone),
    UNIQUE (email),
    CONSTRAINT ck_employee_status CHECK (status IN ('работает','уволен')),
    FOREIGN KEY (position_id) REFERENCES positions (id)
);

CREATE TABLE clients (
    id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    registration_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (phone),
    UNIQUE (email),
    CONSTRAINT ck_client_status CHECK (status IN ('активен','заблокирован'))
);

CREATE TABLE ingredients (
    id INTEGER NOT NULL,
    name VARCHAR(120) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    quantity_in_stock NUMERIC(10,3) NOT NULL,
    minimum_quantity NUMERIC(10,3) NOT NULL,
    purchase_price NUMERIC(10,2) NOT NULL,
    expiration_date DATE,
    PRIMARY KEY (id),
    CONSTRAINT ck_ingredient_stock CHECK (quantity_in_stock >= 0),
    CONSTRAINT ck_ingredient_min CHECK (minimum_quantity >= 0),
    CONSTRAINT ck_ingredient_price CHECK (purchase_price >= 0)
);

CREATE TABLE products (
    id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    name VARCHAR(120) NOT NULL,
    description VARCHAR(255),
    price NUMERIC(10,2) NOT NULL,
    weight NUMERIC(8,3) NOT NULL,
    cooking_time INTEGER NOT NULL,
    is_available BOOLEAN NOT NULL,
    image_url VARCHAR(255),
    PRIMARY KEY (id),
    CONSTRAINT ck_product_price CHECK (price >= 0),
    CONSTRAINT ck_product_weight CHECK (weight > 0),
    CONSTRAINT ck_product_time CHECK (cooking_time > 0),
    FOREIGN KEY (category_id) REFERENCES categories (id)
);

CREATE TABLE product_ingredients (
    product_id INTEGER NOT NULL,
    ingredient_id INTEGER NOT NULL,
    quantity NUMERIC(10,3) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    PRIMARY KEY (product_id, ingredient_id),
    CONSTRAINT ck_pi_quantity CHECK (quantity > 0),
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
);

CREATE TABLE product_sizes (
    product_id INTEGER NOT NULL,
    size_id INTEGER NOT NULL,
    price_delta NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (product_id, size_id),
    CONSTRAINT ck_ps_price_delta CHECK (price_delta >= 0),
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (size_id) REFERENCES sizes (id)
);

CREATE TABLE addresses (
    id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(100) NOT NULL,
    house VARCHAR(10) NOT NULL,
    apartment VARCHAR(10),
    entrance VARCHAR(10),
    floor VARCHAR(10),
    comment VARCHAR(255),
    PRIMARY KEY (id),
    FOREIGN KEY (client_id) REFERENCES clients (id)
);

CREATE TABLE orders (
    id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    order_datetime DATETIME NOT NULL,
    status_id INTEGER NOT NULL,
    order_type VARCHAR(20) NOT NULL,
    address_id INTEGER,
    total_amount NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(12,2) NOT NULL,
    comment VARCHAR(255),
    PRIMARY KEY (id),
    CONSTRAINT ck_order_total CHECK (total_amount >= 0),
    CONSTRAINT ck_order_discount CHECK (discount_amount >= 0),
    CONSTRAINT ck_order_type CHECK (order_type IN ('в зале','доставка','самовывоз')),
    FOREIGN KEY (client_id) REFERENCES clients (id),
    FOREIGN KEY (status_id) REFERENCES order_statuses (id),
    FOREIGN KEY (address_id) REFERENCES addresses (id)
);

CREATE TABLE order_items (
    id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    size_id INTEGER,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    discount NUMERIC(10,2) NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT ck_oi_quantity CHECK (quantity > 0),
    CONSTRAINT ck_oi_price CHECK (unit_price >= 0),
    CONSTRAINT ck_oi_discount CHECK (discount >= 0),
    CONSTRAINT ck_oi_amount CHECK (amount >= 0),
    FOREIGN KEY (order_id) REFERENCES orders (id),
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (size_id) REFERENCES sizes (id)
);

CREATE TABLE payments (
    id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    payment_method_id INTEGER NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    payment_datetime DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,
    transaction_number VARCHAR(60),
    PRIMARY KEY (id),
    UNIQUE (transaction_number),
    CONSTRAINT ck_payment_amount CHECK (amount > 0),
    CONSTRAINT ck_payment_status CHECK (status IN ('проведён','возврат','отменён')),
    FOREIGN KEY (order_id) REFERENCES orders (id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods (id)
);

CREATE TABLE deliveries (
    id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    courier_id INTEGER NOT NULL,
    address_id INTEGER NOT NULL,
    delivery_status VARCHAR(20) NOT NULL,
    pickup_time DATETIME,
    delivery_time DATETIME,
    delivery_cost NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT ck_delivery_cost CHECK (delivery_cost >= 0),
    CONSTRAINT ck_delivery_status CHECK (delivery_status IN ('назначена','в пути','доставлена','отменена')),
    FOREIGN KEY (order_id) REFERENCES orders (id),
    FOREIGN KEY (courier_id) REFERENCES employees (id),
    FOREIGN KEY (address_id) REFERENCES addresses (id)
);

CREATE TABLE purchases (
    id INTEGER NOT NULL,
    supplier_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    purchase_date DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT ck_purchase_total CHECK (total_amount >= 0),
    CONSTRAINT ck_purchase_status CHECK (status IN ('оформлена','получена','отменена')),
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
    FOREIGN KEY (employee_id) REFERENCES employees (id)
);

CREATE TABLE purchase_items (
    id INTEGER NOT NULL,
    purchase_id INTEGER NOT NULL,
    ingredient_id INTEGER NOT NULL,
    quantity NUMERIC(10,3) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT ck_puri_quantity CHECK (quantity > 0),
    CONSTRAINT ck_puri_price CHECK (unit_price >= 0),
    CONSTRAINT ck_puri_amount CHECK (amount >= 0),
    FOREIGN KEY (purchase_id) REFERENCES purchases (id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
);

-- Индексы
CREATE INDEX ix_order_client_date ON orders (client_id, order_datetime);
CREATE INDEX ix_payment_order ON payments (order_id);
CREATE INDEX ix_delivery_order ON deliveries (order_id);