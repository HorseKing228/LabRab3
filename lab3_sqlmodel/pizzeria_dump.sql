BEGIN TRANSACTION;
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
	FOREIGN KEY(client_id) REFERENCES clients (id)
);
INSERT INTO "addresses" VALUES(1,1,'Санкт-Петербург','Невский пр.','10','12','1','3','Домофон 12');
INSERT INTO "addresses" VALUES(2,1,'Санкт-Петербург','ул. Садовая','5','7','2','4',NULL);
INSERT INTO "addresses" VALUES(3,2,'Санкт-Петербург','ул. Ленина','20','3',NULL,'2','Офис 3');
INSERT INTO "addresses" VALUES(4,3,'Санкт-Петербург','пр. Просвещения','15','45','3','5',NULL);
CREATE TABLE categories (
	id INTEGER NOT NULL, 
	name VARCHAR(60) NOT NULL, 
	description VARCHAR(255), 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO "categories" VALUES(1,'пицца','Основные пиццы');
INSERT INTO "categories" VALUES(2,'напитки','Напитки');
INSERT INTO "categories" VALUES(3,'салаты','Салаты');
INSERT INTO "categories" VALUES(4,'закуски','Закуски');
INSERT INTO "categories" VALUES(5,'десерты','Десерты');
INSERT INTO "categories" VALUES(6,'соусы','Соусы');
CREATE TABLE clients (
	id INTEGER NOT NULL, 
	first_name VARCHAR(50) NOT NULL, 
	last_name VARCHAR(50) NOT NULL, 
	phone VARCHAR(20) NOT NULL, 
	email VARCHAR(100), 
	registration_date DATE NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_client_status CHECK (status IN ('активен','заблокирован')), 
	UNIQUE (phone), 
	UNIQUE (email)
);
INSERT INTO "clients" VALUES(1,'Иван','Иванов','+7 911 111-11-11','ivan@example.com','2024-01-10','активен');
INSERT INTO "clients" VALUES(2,'Пётр','Петров','+7 911 222-22-22','petr@example.com','2024-02-15','активен');
INSERT INTO "clients" VALUES(3,'Ольга','Сидорова','+7 911 333-33-33','olga@example.com','2024-03-20','активен');
INSERT INTO "clients" VALUES(4,'Сергей','Козлов','+7 911 444-44-44','sergey@example.com','2024-04-05','заблокирован');
CREATE TABLE deliveries (
	id INTEGER NOT NULL, 
	order_id INTEGER NOT NULL, 
	courier_id INTEGER NOT NULL, 
	address_id INTEGER NOT NULL, 
	delivery_status VARCHAR(20) NOT NULL, 
	pickup_time DATETIME, 
	delivery_time DATETIME, 
	delivery_cost NUMERIC(10, 2) NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_delivery_cost CHECK (delivery_cost >= 0), 
	CONSTRAINT ck_delivery_status CHECK (delivery_status IN ('назначена','в пути','доставлена','отменена')), 
	FOREIGN KEY(order_id) REFERENCES orders (id), 
	FOREIGN KEY(courier_id) REFERENCES employees (id), 
	FOREIGN KEY(address_id) REFERENCES addresses (id)
);
INSERT INTO "deliveries" VALUES(1,1,4,1,'доставлена','2026-10-01 13:00:00','2026-10-01 13:45:00',0);
INSERT INTO "deliveries" VALUES(2,3,6,4,'доставлена','2026-10-03 19:40:00','2026-10-03 20:20:00',0);
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
	CONSTRAINT ck_employee_status CHECK (status IN ('работает','уволен')), 
	UNIQUE (phone), 
	UNIQUE (email), 
	FOREIGN KEY(position_id) REFERENCES positions (id)
);
INSERT INTO "employees" VALUES(1,'Анна','Смирнова','+7 900 000-00-01','anna@example.com',1,'2022-01-15','работает');
INSERT INTO "employees" VALUES(2,'Игорь','Кузнецов','+7 900 000-00-02','igor@example.com',2,'2021-03-10','работает');
INSERT INTO "employees" VALUES(3,'Мария','Попова','+7 900 000-00-03','maria@example.com',3,'2022-06-01','работает');
INSERT INTO "employees" VALUES(4,'Олег','Волков','+7 900 000-00-04','oleg@example.com',4,'2023-02-20','работает');
INSERT INTO "employees" VALUES(5,'Елена','Морозова','+7 900 000-00-05','elena@example.com',5,'2020-09-05','работает');
INSERT INTO "employees" VALUES(6,'Дмитрий','Лебедев','+7 900 000-00-06','dmitry@example.com',4,'2023-04-12','работает');
CREATE TABLE ingredients (
	id INTEGER NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	unit VARCHAR(20) NOT NULL, 
	quantity_in_stock NUMERIC(10, 3) NOT NULL, 
	minimum_quantity NUMERIC(10, 3) NOT NULL, 
	purchase_price NUMERIC(10, 2) NOT NULL, 
	expiration_date DATE, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_ingredient_stock CHECK (quantity_in_stock >= 0), 
	CONSTRAINT ck_ingredient_min CHECK (minimum_quantity >= 0), 
	CONSTRAINT ck_ingredient_price CHECK (purchase_price >= 0)
);
INSERT INTO "ingredients" VALUES(1,'Мука','кг',50,10,45,'2026-12-31');
INSERT INTO "ingredients" VALUES(2,'Моцарелла','кг',12,5,320,'2026-11-30');
INSERT INTO "ingredients" VALUES(3,'Грибы','кг',8,3,180,'2026-11-20');
INSERT INTO "ingredients" VALUES(4,'Пепперони','кг',6,2,450,'2026-12-15');
INSERT INTO "ingredients" VALUES(5,'Томатный соус','л',20,5,90,'2026-12-01');
INSERT INTO "ingredients" VALUES(6,'Кола','л',30,10,60,'2027-01-01');
CREATE TABLE order_items (
	id INTEGER NOT NULL, 
	order_id INTEGER NOT NULL, 
	product_id INTEGER NOT NULL, 
	size_id INTEGER, 
	quantity INTEGER NOT NULL, 
	unit_price NUMERIC(10, 2) NOT NULL, 
	discount NUMERIC(10, 2) NOT NULL, 
	amount NUMERIC(10, 2) NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_oi_quantity CHECK (quantity > 0), 
	CONSTRAINT ck_oi_price CHECK (unit_price >= 0), 
	CONSTRAINT ck_oi_discount CHECK (discount >= 0), 
	CONSTRAINT ck_oi_amount CHECK (amount >= 0), 
	FOREIGN KEY(order_id) REFERENCES orders (id), 
	FOREIGN KEY(product_id) REFERENCES products (id), 
	FOREIGN KEY(size_id) REFERENCES sizes (id)
);
INSERT INTO "order_items" VALUES(1,1,1,2,2,750,0,1500);
INSERT INTO "order_items" VALUES(2,1,3,NULL,1,150,0,150);
INSERT INTO "order_items" VALUES(3,2,2,3,1,950,0,950);
INSERT INTO "order_items" VALUES(4,2,5,NULL,2,50,0,100);
INSERT INTO "order_items" VALUES(5,3,1,1,1,650,0,650);
INSERT INTO "order_items" VALUES(6,4,1,1,1,650,0,650);
CREATE TABLE order_statuses (
	id INTEGER NOT NULL, 
	name VARCHAR(60) NOT NULL, 
	description VARCHAR(255), 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO "order_statuses" VALUES(1,'Новый','Заказ только что оформлен');
INSERT INTO "order_statuses" VALUES(2,'Подтверждён','Заказ подтверждён оператором');
INSERT INTO "order_statuses" VALUES(3,'Готовится','Заказ на кухне');
INSERT INTO "order_statuses" VALUES(4,'Готов','Заказ готов к выдаче/передаче курьеру');
INSERT INTO "order_statuses" VALUES(5,'Передан курьеру','Курьер забрал заказ');
INSERT INTO "order_statuses" VALUES(6,'Доставляется','Курьер в пути');
INSERT INTO "order_statuses" VALUES(7,'Выполнен','Заказ выдан клиенту');
INSERT INTO "order_statuses" VALUES(8,'Отменён','Заказ отменён');
CREATE TABLE orders (
	id INTEGER NOT NULL, 
	client_id INTEGER NOT NULL, 
	order_datetime DATETIME NOT NULL, 
	status_id INTEGER NOT NULL, 
	order_type VARCHAR(20) NOT NULL, 
	address_id INTEGER, 
	total_amount NUMERIC(12, 2) NOT NULL, 
	discount_amount NUMERIC(12, 2) NOT NULL, 
	comment VARCHAR(255), 
	PRIMARY KEY (id), 
	CONSTRAINT ck_order_total CHECK (total_amount >= 0), 
	CONSTRAINT ck_order_discount CHECK (discount_amount >= 0), 
	CONSTRAINT ck_order_type CHECK (order_type IN ('в зале','доставка','самовывоз')), 
	FOREIGN KEY(client_id) REFERENCES clients (id), 
	FOREIGN KEY(status_id) REFERENCES order_statuses (id), 
	FOREIGN KEY(address_id) REFERENCES addresses (id)
);
INSERT INTO "orders" VALUES(1,1,'2026-10-01 12:30:00',7,'доставка',1,1650,0,'Без лука');
INSERT INTO "orders" VALUES(2,2,'2026-10-02 18:00:00',3,'в зале',NULL,1050,0,NULL);
INSERT INTO "orders" VALUES(3,3,'2026-10-03 19:15:00',7,'доставка',4,650,0,NULL);
INSERT INTO "orders" VALUES(4,1,'2026-10-05 13:00:00',1,'самовывоз',NULL,650,0,NULL);
CREATE TABLE payment_methods (
	id INTEGER NOT NULL, 
	name VARCHAR(60) NOT NULL, 
	description VARCHAR(255), 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO "payment_methods" VALUES(1,'наличные','Оплата наличными');
INSERT INTO "payment_methods" VALUES(2,'банковская карта','Оплата картой в зале');
INSERT INTO "payment_methods" VALUES(3,'онлайн-оплата','Оплата через сайт/приложение');
CREATE TABLE payments (
	id INTEGER NOT NULL, 
	order_id INTEGER NOT NULL, 
	payment_method_id INTEGER NOT NULL, 
	amount NUMERIC(12, 2) NOT NULL, 
	payment_datetime DATETIME NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	transaction_number VARCHAR(60), 
	PRIMARY KEY (id), 
	CONSTRAINT ck_payment_amount CHECK (amount > 0), 
	CONSTRAINT ck_payment_status CHECK (status IN ('проведён','возврат','отменён')), 
	FOREIGN KEY(order_id) REFERENCES orders (id), 
	FOREIGN KEY(payment_method_id) REFERENCES payment_methods (id), 
	UNIQUE (transaction_number)
);
INSERT INTO "payments" VALUES(1,1,3,1650,'2026-10-01 12:35:00','проведён','TX-0001');
INSERT INTO "payments" VALUES(2,2,2,1050,'2026-10-02 18:05:00','проведён','TX-0002');
INSERT INTO "payments" VALUES(3,3,1,750,'2026-10-03 19:20:00','проведён',NULL);
INSERT INTO "payments" VALUES(4,4,3,650,'2026-10-05 13:05:00','проведён','TX-0004');
CREATE TABLE positions (
	id INTEGER NOT NULL, 
	name VARCHAR(80) NOT NULL, 
	description VARCHAR(255), 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO "positions" VALUES(1,'администратор','Управление залом и сменами');
INSERT INTO "positions" VALUES(2,'повар','Приготовление блюд');
INSERT INTO "positions" VALUES(3,'кассир','Приём заказов и оплат');
INSERT INTO "positions" VALUES(4,'курьер','Доставка заказов');
INSERT INTO "positions" VALUES(5,'менеджер','Управление закупками и персоналом');
CREATE TABLE product_ingredients (
	product_id INTEGER NOT NULL, 
	ingredient_id INTEGER NOT NULL, 
	quantity NUMERIC(10, 3) NOT NULL, 
	unit VARCHAR(20) NOT NULL, 
	PRIMARY KEY (product_id, ingredient_id), 
	CONSTRAINT ck_pi_quantity CHECK (quantity > 0), 
	FOREIGN KEY(product_id) REFERENCES products (id), 
	FOREIGN KEY(ingredient_id) REFERENCES ingredients (id)
);
INSERT INTO "product_ingredients" VALUES(1,1,0.2,'кг');
INSERT INTO "product_ingredients" VALUES(1,2,0.15,'кг');
INSERT INTO "product_ingredients" VALUES(1,5,0.1,'л');
INSERT INTO "product_ingredients" VALUES(2,1,0.2,'кг');
INSERT INTO "product_ingredients" VALUES(2,2,0.15,'кг');
INSERT INTO "product_ingredients" VALUES(2,4,0.1,'кг');
INSERT INTO "product_ingredients" VALUES(2,5,0.1,'л');
INSERT INTO "product_ingredients" VALUES(3,6,0.5,'л');
CREATE TABLE product_sizes (
	product_id INTEGER NOT NULL, 
	size_id INTEGER NOT NULL, 
	price_delta NUMERIC(10, 2) NOT NULL, 
	PRIMARY KEY (product_id, size_id), 
	CONSTRAINT ck_ps_price_delta CHECK (price_delta >= 0), 
	FOREIGN KEY(product_id) REFERENCES products (id), 
	FOREIGN KEY(size_id) REFERENCES sizes (id)
);
INSERT INTO "product_sizes" VALUES(1,1,0);
INSERT INTO "product_sizes" VALUES(1,2,100);
INSERT INTO "product_sizes" VALUES(1,3,200);
INSERT INTO "product_sizes" VALUES(1,4,300);
INSERT INTO "product_sizes" VALUES(2,1,0);
INSERT INTO "product_sizes" VALUES(2,2,100);
INSERT INTO "product_sizes" VALUES(2,3,200);
INSERT INTO "product_sizes" VALUES(2,4,300);
CREATE TABLE products (
	id INTEGER NOT NULL, 
	category_id INTEGER NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	description VARCHAR(255), 
	price NUMERIC(10, 2) NOT NULL, 
	weight NUMERIC(8, 3) NOT NULL, 
	cooking_time INTEGER NOT NULL, 
	is_available BOOLEAN NOT NULL, 
	image_url VARCHAR(255), 
	PRIMARY KEY (id), 
	CONSTRAINT ck_product_price CHECK (price >= 0), 
	CONSTRAINT ck_product_weight CHECK (weight > 0), 
	CONSTRAINT ck_product_time CHECK (cooking_time > 0), 
	FOREIGN KEY(category_id) REFERENCES categories (id)
);
INSERT INTO "products" VALUES(1,1,'Маргарита','Классическая пицца с моцареллой и томатами',650,0.5,20,1,NULL);
INSERT INTO "products" VALUES(2,1,'Пепперони','Пицца с пепперони и моцареллой',750,0.55,22,1,NULL);
INSERT INTO "products" VALUES(3,2,'Кола','Газированный напиток',150,0.5,1,1,NULL);
INSERT INTO "products" VALUES(4,3,'Цезарь','Салат с курицей и сухариками',420,0.3,10,1,NULL);
INSERT INTO "products" VALUES(5,6,'Чесночный соус','Соус к пицце',50,0.05,1,1,NULL);
CREATE TABLE purchase_items (
	id INTEGER NOT NULL, 
	purchase_id INTEGER NOT NULL, 
	ingredient_id INTEGER NOT NULL, 
	quantity NUMERIC(10, 3) NOT NULL, 
	unit_price NUMERIC(10, 2) NOT NULL, 
	amount NUMERIC(12, 2) NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_puri_quantity CHECK (quantity > 0), 
	CONSTRAINT ck_puri_price CHECK (unit_price >= 0), 
	CONSTRAINT ck_puri_amount CHECK (amount >= 0), 
	FOREIGN KEY(purchase_id) REFERENCES purchases (id), 
	FOREIGN KEY(ingredient_id) REFERENCES ingredients (id)
);
INSERT INTO "purchase_items" VALUES(1,1,2,25,320,8000);
INSERT INTO "purchase_items" VALUES(2,2,4,10,450,4500);
INSERT INTO "purchase_items" VALUES(3,2,1,33,45,1485);
INSERT INTO "purchase_items" VALUES(4,3,3,16,180,2880);
CREATE TABLE purchases (
	id INTEGER NOT NULL, 
	supplier_id INTEGER NOT NULL, 
	employee_id INTEGER NOT NULL, 
	purchase_date DATE NOT NULL, 
	total_amount NUMERIC(12, 2) NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_purchase_total CHECK (total_amount >= 0), 
	CONSTRAINT ck_purchase_status CHECK (status IN ('оформлена','получена','отменена')), 
	FOREIGN KEY(supplier_id) REFERENCES suppliers (id), 
	FOREIGN KEY(employee_id) REFERENCES employees (id)
);
INSERT INTO "purchases" VALUES(1,1,5,'2026-09-28',8000,'получена');
INSERT INTO "purchases" VALUES(2,2,5,'2026-09-29',6000,'получена');
INSERT INTO "purchases" VALUES(3,3,5,'2026-09-30',3000,'оформлена');
CREATE TABLE sizes (
	id INTEGER NOT NULL, 
	name VARCHAR(30) NOT NULL, 
	diameter_cm INTEGER NOT NULL, 
	description VARCHAR(255), 
	PRIMARY KEY (id), 
	CONSTRAINT ck_size_diameter CHECK (diameter_cm > 0), 
	UNIQUE (name)
);
INSERT INTO "sizes" VALUES(1,'25 см',25,'Маленькая');
INSERT INTO "sizes" VALUES(2,'30 см',30,'Средняя');
INSERT INTO "sizes" VALUES(3,'35 см',35,'Большая');
INSERT INTO "sizes" VALUES(4,'40 см',40,'Очень большая');
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
INSERT INTO "suppliers" VALUES(1,'ООО «Молочный путь»','Иванов И. И.','+7 812 555-10-01','milk@example.com','СПб, ул. Фермерская, 1');
INSERT INTO "suppliers" VALUES(2,'АО «МясоТорг»','Петров П. П.','+7 812 555-10-02','meat@example.com','СПб, пр. Мясной, 2');
INSERT INTO "suppliers" VALUES(3,'ООО «ОвощиОпт»','Сидорова А. В.','+7 812 555-10-03','veg@example.com','СПб, ул. Полевая, 3');
CREATE INDEX ix_order_client_date ON orders (client_id, order_datetime);
CREATE INDEX ix_payment_order ON payments (order_id);
CREATE INDEX ix_delivery_order ON deliveries (order_id);
COMMIT;