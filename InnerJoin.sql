SELECT c.customer_num, lname, fname, o.order_num, order_date, item_num, i.stock_num, pt.description, i.manu_code, m.manu_name, i.quantity, i.unit_price
FROM customer c 
	JOIN orders o		  ON c.customer_num = o.customer_num
	JOIN items i		  ON o.order_num = i.order_num
	JOIN product_types pt ON i.stock_num = pt.stock_num
	JOIN manufact m		  ON i.manu_code = m.manu_code
ORDER BY 1, 4, 6