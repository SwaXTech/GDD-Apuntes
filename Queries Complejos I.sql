/*
Crear una vista que devuelva:
a) Código y Nombre (manu_code,manu_name) de los fabricante, posean o no productos
(en tabla Products), cantidad de productos que fabrican (cant_producto) y la fecha de
la última OC que contenga un producto suyo (ult_fecha_orden).

	-  De los fabricantes que fabriquen productos sólo se podrán mostrar los que
	fabriquen más de 2 productos.
	-  No se permite utilizar funciones definidas por usuario, ni tablas temporales, ni
	UNION.

b) Realizar una consulta sobre la vista que devuelva manu_code, manu_name,
cant_producto y si el campo ult_fecha_orden posee un NULL informar ‘No Posee
Órdenes’ si no posee NULL informar el valor de dicho campo.
- No se puede utilizar UNION para el SELECT.

*/

CREATE VIEW vista_fabricantes AS
	SELECT m.manu_code, m.manu_name, COUNT(DISTINCT p.stock_num) AS cant_productos, MAX(o.order_date) AS ultima_orden FROM manufact m
								LEFT JOIN products p ON p.manu_code = m.manu_code
								LEFT JOIN items i ON i.stock_num = p.stock_num AND i.manu_code = p.manu_code
								LEFT JOIN orders o ON i.order_num = o.order_num
	GROUP BY m.manu_code, m.manu_name
	HAVING COUNT(DISTINCT p.stock_num) > 2 OR COUNT(DISTINCT p.stock_num) = 0
GO

SELECT manu_code, manu_name, cant_productos, COALESCE(CAST(ultima_orden AS VARCHAR), 'No posee órdenes') FROM vista_fabricantes

/*
Desarrollar una consulta ABC de fabricantes que:

Liste el código y nombre del fabricante, la cantidad de órdenes de compra que contengan
sus productos y la monto total de los productos vendidos.

Mostrar sólo los fabricantes cuyo código comience con A ó con N y posea 3 letras, y los
productos cuya descripción posean el string “tennis” ó el string “ball” en cualquier parte del
nombre y cuyo monto total vendido sea mayor que el total de ventas promedio de todos
los fabricantes (Cantidad * precio unitario / Cantidad de fabricantes que vendieron sus
productos).

Mostrar los registros ordenados por monto total vendido de mayor a menor.
*/

SELECT m.manu_code, m.manu_name, COUNT(DISTINCT i.order_num), SUM(i.unit_price * i.quantity), pt.description 
	FROM manufact m LEFT JOIN items i ON m.manu_code = i.manu_code
						 JOIN product_types pt ON pt.stock_num = i.stock_num
	WHERE m.manu_code LIKE '[AN]__'	 AND (pt.description LIKE '%tennis%' OR pt.description LIKE '%ball%')
	GROUP BY m.manu_code, m.manu_name, pt.description, i.stock_num
	HAVING SUM(i.unit_price * i.quantity) > (
		SELECT (SUM(i2.unit_price * i2.quantity) / COUNT(DISTINCT i2.manu_code))
		FROM items i2 
		WHERE i2.stock_num = i.stock_num
		GROUP BY i2.stock_num
		)
	ORDER BY SUM(i.unit_price * i.quantity) DESC
GO
/*
Crear una vista que devuelva

Para cada cliente mostrar (customer_num, lname, company), cantidad de órdenes
de compra, fecha de su última OC, monto total comprado y el total general
comprado por todos los clientes.

De los clientes que posean órdenes sólo se podrán mostrar los clientes que tengan
alguna orden que posea productos que son fabricados por más de dos fabricantes y
que tengan al menos 3 órdenes de compra.

Ordenar el reporte de tal forma que primero aparezcan los clientes que tengan
órdenes por cantidad de órdenes descendente y luego los clientes que no tengan
órdenes.

No se permite utilizar funciones, ni tablas temporales.
*/

CREATE VIEW vista_clientes AS
	SELECT c.customer_num, lname, company, COUNT(DISTINCT o.order_num) cant_ordenes, MAX(o.order_date) ult_orden, SUM(i.quantity * i.unit_price) total, 
		(SELECT SUM(i2.unit_price * i2.quantity) FROM ITEMS i2) total_general
	FROM customer c LEFT JOIN orders o ON c.customer_num = o.customer_num
					LEFT JOIN items i ON i.order_num = o.order_num
	GROUP BY c.customer_num, lname, company
	HAVING (COUNT(DISTINCT o.order_num) = 0) 
		OR (COUNT(DISTINCT o.order_num) > 3 AND (
			SELECT COUNT(DISTINCT i.manu_code) 
			FROM orders o2 JOIN items i ON o2.order_num = i.order_num 
			WHERE o2.customer_num = c.customer_num) > 2)
--	ORDER BY COUNT(DISTINCT o.order_num) DESC
GO

CREATE VIEW vista_clientes2 AS
	SELECT 1 orden, c.customer_num, lname, company, COUNT(DISTINCT o.order_num) cant_ordenes, MAX(o.order_date) ult_orden, SUM(i.quantity * i.unit_price) total, 
		(SELECT SUM(i2.unit_price * i2.quantity) FROM ITEMS i2) total_general
	FROM customer c LEFT JOIN orders o ON c.customer_num = o.customer_num
					LEFT JOIN items i ON i.order_num = o.order_num
	GROUP BY c.customer_num, lname, company
	HAVING (COUNT(DISTINCT o.order_num) > 3 AND (
			SELECT COUNT(DISTINCT i.manu_code) 
			FROM orders o2 JOIN items i ON o2.order_num = i.order_num 
			WHERE o2.customer_num = c.customer_num) > 2)
	UNION
	SELECT 2 orden, c.customer_num, lname, company, 0 cant_ordenes, NULL ult_orden, 0 total, (SELECT SUM(i2.unit_price * i2.quantity) FROM ITEMS i2) total_general
	FROM customer c 
	WHERE c.customer_num NOT IN (SELECT customer_num FROM orders)
GO

/*
Crear una consulta que devuelva los 5 primeros estados y el tipo de producto
(description) más comprado en ese estado (state) según la cantidad vendida del tipo
de producto.
Ordenarlo por la cantidad vendida en forma descendente.
Nota: No se permite utilizar funciones, ni tablas temporales.
*/

SELECT TOP 5 c.state, pt.description, SUM(i.quantity) FROM customer c 
	JOIN orders o ON c.customer_num = o.customer_num
	JOIN items i ON o.order_num = i.order_num
	JOIN product_types pt ON pt.stock_num = i.stock_num
	GROUP BY c.state, pt.description
	HAVING SUM(i.quantity) = (SELECT TOP 1 SUM(i2.quantity) FROM customer c2 
								JOIN orders o2 ON c2.customer_num = o2.customer_num
								JOIN items i2 ON o2.order_num = i2.order_num
								WHERE c2.state = c.state
								GROUP BY c2.state, i2.stock_num
								ORDER BY SUM(i2.quantity) DESC)
	ORDER BY SUM(i.quantity) DESC

/*
Listar los customers que no posean órdenes de compra y aquellos cuyas últimas
órdenes de compra superen el promedio de todas las anteriores.
Mostrar customer_num, fname, lname, paid_date y el monto total de la orden que
supere el promedio de las anteriores. Ordenar el resultado por monto total en forma
descendiente.
*/




/*
Se desean saber los fabricantes que vendieron mayor cantidad de un mismo
producto que la competencia según la cantidad vendida. Tener en cuenta que puede
existir un producto que no sea fabricado por ningún otro fabricante y que puede
haber varios fabricantes que tengan la misma cantidad máxima vendida.
Mostrar el código del producto, descripción del producto, código de fabricante,
cantidad vendida, monto total vendido. Ordenar el resultado código de producto, por
cantidad total vendida y por monto total, ambos en forma decreciente.
Nota: No se permiten utilizar funciones, ni tablas temporales.
*/

SELECT i.stock_num, pt.description, m.manu_code, SUM(i.quantity) AS cantidad_vendida, SUM(i.quantity * i.unit_price) as monto_total
FROM manufact m LEFT JOIN items i ON i.manu_code = m.manu_code
				JOIN product_types pt ON pt.stock_num = i.stock_num
GROUP BY i.stock_num, pt.description, m.manu_code
HAVING (SUM(i.quantity) >= (SELECT TOP 1 SUM(i2.quantity) 
							FROM items i2 WHERE i2.manu_code != m.manu_code AND i2.stock_num = i.stock_num
							GROUP BY manu_code 
							ORDER BY SUM(i2.quantity) DESC)) 
		OR (SELECT COUNT(DISTINCT i3.manu_code) FROM items i3 WHERE i3.stock_num = i.stock_num) = 1
ORDER BY i.stock_num, SUM(i.quantity) DESC, SUM(i.quantity * i.unit_price) DESC








	 
