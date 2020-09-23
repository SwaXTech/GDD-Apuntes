-- Este INNER JOIN me trae clientes junto con su cantidad de compras, 
-- Solo aquellos que hicieron alguna compra

SELECT c.customer_num, fname, lname, COUNT(order_num) cantOrdenes
FROM customer c INNER JOIN orders o
	ON c.customer_num = o.customer_num
GROUP BY c.customer_num, fname, lname


-- Este OUTER JOIN me trae clientes junto con su cantidad de compras, 
-- Aunque no hayan hecho ninguna compra

SELECT c.customer_num, fname, lname, COUNT(order_num) cantOrdenes
FROM customer c LEFT JOIN orders o
	ON c.customer_num = o.customer_num
GROUP BY c.customer_num, fname, lname
