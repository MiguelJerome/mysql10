-- 1.
SELECT *
FROM products
WHERE id IN (
	SELECT product_id
    FROM order_details
    WHERE order_id = 63
);

-- 2.
SELECT * 
FROM products
WHERE id NOT IN (
	SELECT DISTINCT product_id
    FROM order_details
);

-- 3.
SELECT * 
FROM employees
WHERE id IN (
	SELECT employee_id 
    FROM orders
    WHERE id IN (
		SELECT order_id 
        FROM order_details
        WHERE product_id IN (
			SELECT id 
            FROM products
            WHERE product_name LIKE '%pea%'
        )
    )
);

-- 4.
SELECT * 
FROM products
WHERE standard_cost > (
    SELECT AVG(standard_cost)
    FROM products
);

-- 5.
SELECT o.*
FROM orders o
WHERE o.ship_city = (
    SELECT e.city
    FROM employees e
    WHERE o.employee_id = e.id
);

-- 6.
SELECT AVG(quantity) AS avg_quantity
FROM (
    SELECT order_id, SUM(quantity) AS quantity
    FROM order_details
    GROUP BY order_id
) t_avg;

-- 7.
SELECT o.*, SUM(od.quantity)
FROM orders o
INNER JOIN order_details od ON o.id = od.order_id
GROUP BY o.id
HAVING SUM(quantity) > (
    SELECT AVG(quantity) AS avg_quantity
    FROM (
        SELECT order_id, SUM(quantity) AS quantity
        FROM order_details
        GROUP BY order_id
    ) t_avg
);

-- 8.
SELECT order_id
FROM order_details
WHERE product_id = (
    SELECT id
    FROM products
    ORDER BY list_price - standard_cost DESC
    LIMIT 1
);

-- 9.
SELECT c.* 
FROM customers c 
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN (
	SELECT order_id, SUM(quantity * unit_price) AS prix 
    FROM order_details 
    GROUP BY order_id 
    HAVING prix = (
		SELECT MAX(quantity * unit_price) FROM order_details
	)
) AS order_price ON o.id = order_price.order_id;

-- 10.
SELECT c.*
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN order_details od ON o.id = od.order_id
GROUP BY c.id
HAVING SUM(od.quantity * od.unit_price) = (
    SELECT MAX(achat)
    FROM (
        SELECT o.customer_id, SUM(od.quantity * od.unit_price) AS achat
        FROM order_details od
        INNER JOIN orders o ON od.order_id = o.id
        GROUP BY o.customer_id
    ) emp_achat
);