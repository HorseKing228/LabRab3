-- SQL-эквиваленты запросов из requests.py

-- Q01 get_client_orders (клиент 1)
SELECT id, order_datetime, status_id, total_amount
FROM orders WHERE client_id = 1 ORDER BY order_datetime DESC;

-- Q02 get_order_composition (заказ 1)
SELECT oi.id, p.name, oi.quantity, oi.unit_price, oi.discount, oi.amount
FROM order_items oi JOIN products p ON p.id = oi.product_id
WHERE oi.order_id = 1;

-- Q03 get_open_orders
SELECT o.id, c.last_name, c.first_name, o.order_datetime, s.name, o.total_amount
FROM orders o
JOIN clients c ON c.id = o.client_id
JOIN order_statuses s ON s.id = o.status_id
WHERE s.name IN ('Новый','Подтверждён','Готовится','Готов')
ORDER BY o.order_datetime;

-- Q04 get_orders_by_type ('доставка')
SELECT o.id, c.last_name, o.order_datetime, o.total_amount
FROM orders o JOIN clients c ON c.id = o.client_id
WHERE o.order_type = 'доставка' ORDER BY o.order_datetime DESC;

-- Q05 get_sales_by_category
SELECT cat.name, COUNT(oi.id) AS items, SUM(oi.amount) AS revenue
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN categories cat ON cat.id = p.category_id
GROUP BY cat.id, cat.name ORDER BY revenue DESC;

-- Q06 get_products_by_category ('пицца')
SELECT p.id, p.name, p.price, p.cooking_time
FROM products p JOIN categories c ON c.id = p.category_id
WHERE c.name = 'пицца' AND p.is_available = 1 ORDER BY p.name;

-- Q07 get_product_ingredients (блюдо 1)
SELECT i.name, pi.quantity, pi.unit
FROM product_ingredients pi JOIN ingredients i ON i.id = pi.ingredient_id
WHERE pi.product_id = 1;

-- Q08 get_ingredients_below_min
SELECT name, quantity_in_stock, minimum_quantity
FROM ingredients WHERE quantity_in_stock < minimum_quantity;

-- Q09 get_purchases_by_supplier
SELECT s.name, COUNT(p.id) AS deliveries, SUM(p.total_amount) AS amount
FROM purchases p JOIN suppliers s ON s.id = p.supplier_id
GROUP BY s.id, s.name ORDER BY amount DESC;

-- Q10 get_deliveries_by_status ('доставлена')
SELECT d.id, o.id AS order_id, e.last_name AS courier,
       d.delivery_status, d.delivery_time
FROM deliveries d
JOIN orders o ON o.id = d.order_id
JOIN employees e ON e.id = d.courier_id
WHERE d.delivery_status = 'доставлена';

-- Q11 get_courier_load
SELECT e.last_name, e.first_name, COUNT(d.id) AS deliveries
FROM deliveries d JOIN employees e ON e.id = d.courier_id
GROUP BY e.id, e.last_name, e.first_name ORDER BY deliveries DESC;

-- Q12 get_top_clients
SELECT c.last_name, c.first_name, COUNT(o.id) AS orders, SUM(o.total_amount) AS total
FROM orders o JOIN clients c ON c.id = o.client_id
GROUP BY c.id, c.last_name, c.first_name ORDER BY total DESC;