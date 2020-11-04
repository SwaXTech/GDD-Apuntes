/*
Listar Número de Cliente, apellido y nombre, Total Comprado por el cliente ‘Total del Cliente’,
Cantidad de Órdenes de Compra del cliente ‘OCs del Cliente’ y la Cant. de Órdenes de Compra
solicitadas por todos los clientes ‘Cant. Total OC’, de todos aquellos clientes cuyo promedio de compra
por Orden supere al promedio de órdenes de compra general, tengan al menos 2 órdenes y cuyo
zipcode comience con 94.
*/


SELECT c.customer_num, lname, fname, SUM(i.unit_price * i.quantity) AS total_del_cliente, COUNT(DISTINCT o.order_num) AS OC_del_cliente, (SELECT COUNT(order_num) FROM orders ) AS cant_total_oc
FROM customer c JOIN orders o ON c.customer_num = o.customer_num
				JOIN items i ON i.order_num = o.order_num
WHERE c.zipcode LIKE '94%' 
GROUP BY c.customer_num, lname, fname
HAVING COUNT(DISTINCT o.order_num) >= 2 AND
	(SUM(i.quantity * i.unit_price) / COUNT(DISTINCT o.order_num) >
	(SELECT SUM(quantity * unit_price) / COUNT(DISTINCT order_num) FROM items))
	
/*
Se requiere crear una tabla temporal #ABC_Productos un ABC de Productos ordenado por cantidad
de venta en u$, los datos solicitados son:
Nro. de Stock, Código de fabricante, descripción del producto, Nombre de Fabricante, Total del producto
pedido 'u$ por Producto', Cant. de producto pedido 'Unid. por Producto', para los productos que
pertenezcan a fabricantes que fabriquen al menos 10 productos diferentes.
*/

DROP TABLE #ABC_productos
SELECT i.stock_num, i.manu_code, pt.description, m.manu_name, SUM(i.unit_price * i.quantity) AS total, SUM(i.quantity) AS cantidad INTO #ABC_Productos
FROM items i JOIN manufact m ON i.manu_code = m.manu_code
			 JOIN product_types pt ON pt.stock_num = i.stock_num
WHERE i.manu_code IN (SELECT manu_code FROM products GROUP BY manu_code HAVING COUNT(DISTINCT stock_num) > 10)
GROUP BY i.stock_num, i.manu_code, pt.description, m.manu_name, i.unit_price

SELECT * FROM #ABC_Productos ORDER BY total

/*
En función a la tabla temporal generada en el punto 2, obtener un listado que detalle para cada tipo
de producto existente en #ABC_Producto, la descripción del producto, el mes en el que fue solicitado, el
cliente que lo solicitó (en formato 'Apellido, Nombre'), la cantidad de órdenes de compra 'Cant OC por
mes', la cantidad del producto solicitado 'Unid Producto por mes' y el total en u$ solicitado 'u$ Producto
por mes'.
Mostrar sólo aquellos clientes que vivan en el estado con mayor cantidad de clientes, ordenado por
mes y descripción del tipo de producto en forma ascendente y por cantidad de productos por mes en
forma descendente.
*/

SELECT t.stock_num, t.description, MONTH(o.order_date), c.lname + ', ' + c.fname, 
		COUNT(DISTINCT i.order_num),
		SUM(i.quantity),
		SUM(i.quantity * i.unit_price)
FROM #ABC_productos t JOIN items i ON i.stock_num = t.stock_num AND i.manu_code = t.manu_code
					  JOIN orders o ON o.order_num = i.order_num
					  JOIN customer c ON c.customer_num = o.customer_num
WHERE c.state = (SELECT TOP 1 state FROM customer GROUP BY state ORDER BY COUNT(customer_num) DESC)
GROUP BY t.stock_num, t.description, MONTH(o.order_date), c.lname + ', ' + c.fname


/*
Dado los productos con número de stock 5, 6 y 9 del fabricante 'ANZ' listar de a pares los clientes que
hayan solicitado el mismo producto, siempre y cuando, el primer cliente haya solicitado más cantidad
del producto que el 2do cliente.
Se deberá informar nro de stock, código de fabricante, Nro de Cliente y Apellido del primer cliente, Nro
de cliente y apellido del 2do cliente ordenado por stock_num y manu_code
*/

SELECT DISTINCT i1.stock_num, i1.manu_code, c1.customer_num, c1.lname, c2.customer_num, c2.lname
FROM items i1 JOIN orders o1 ON i1.order_num = o1.order_num
			  JOIN customer c1 ON o1.customer_num = c1.customer_num
			  JOIN items i2 ON i1.manu_code = i2.manu_code AND i1.stock_num = i2.stock_num
			  JOIN orders o2 ON i2.order_num = o2.order_num
			  JOIN customer c2 ON o2.customer_num = c2.customer_num
WHERE i1.stock_num IN (5, 6, 9) AND i1.manu_code = 'ANZ'
AND ((SELECT SUM(quantity) FROM items i3 JOIN orders o3 ON i3.order_num = o3.order_num WHERE o3.customer_num = c1.customer_num AND i3.stock_num = i1.stock_num AND i3.manu_code = i1.manu_code) >
	 (SELECT SUM(quantity) FROM items i3 JOIN orders o3 ON i3.order_num = o3.order_num WHERE o3.customer_num = c2.customer_num AND i3.stock_num = i1.stock_num AND i3.manu_code = i1.manu_code))
ORDER BY i1.stock_num, i1.manu_code


/*
Se requiere realizar una consulta que devuelva en una fila la siguiente información: La mayor cantidad de
órdenes de compra de un cliente, mayor total en u$ solicitado por un cliente y la mayor cantidad de
productos solicitados por un cliente, la menor cantidad de órdenes de compra de un cliente, el menor total
en u$ solicitado por un cliente y la menor cantidad de productos solicitados por un cliente
Los valores máximos y mínimos solicitados deberán corresponderse a los datos de clientes según todas
las órdenes existentes, sin importar a que cliente corresponda el dato.
*/

SELECT MAX(cantOrd) maxCantOrd, MAX(sumPrecio) maxSumPrecio,
	   MAX(cantItem) maxCantItem, MIN(cantOrd) minCantOrd,
	   MIN(sumPrecio) minSumPrecio, MIN(cantItem) minCantItem
FROM (SELECT o.customer_num, COUNT(DISTINCT o.order_num) cantOrd, SUM(i.quantity * i.unit_price) sumPrecio, SUM(i.quantity) cantItem 
			FROM orders o JOIN items i ON o.order_num = i.order_num
			GROUP BY o.customer_num) AliasDeLaTabla


/*
Seleccionar los número de cliente, número de orden y monto total de la orden de aquellos clientes del
estado California(CA) que posean 4 o más órdenes de compra emitidas en el 2015. Además las órdenes
mostradas deberán cumplir con la salvedad que la cantidad de líneas de ítems de esas órdenes debe ser
mayor a la cantidad de líneas de ítems de la orden de compra con mayor cantidad de ítems del estado AZ
en el mismo año.
*/

SELECT c.customer_num, o.order_num, SUM(i.quantity * i.unit_price) 
FROM customer c JOIN orders o ON c.customer_num = o.customer_num
				JOIN items i ON i.order_num = o.order_num
WHERE 
		c.state = 'CA' 
	AND
		c.customer_num IN (
			SELECT customer_num 
			FROM orders 
			WHERE YEAR(order_date) = 2015 
			GROUP BY customer_num 
			HAVING COUNT(*) >= 4
		) 
GROUP BY c.customer_num, o.order_num
HAVING 
	COUNT(i.item_num) > (
		SELECT TOP 1 COUNT(i2.order_num) 
		FROM customer c3 JOIN orders o2 ON o2.customer_num = c3.customer_num
						 JOIN items i2 ON o2.order_num = i2.order_num
		WHERE YEAR(o2.order_date) = 2015 AND c3.state = 'AZ' 
		GROUP BY o2.order_num 
		ORDER BY COUNT(i2.item_num) DESC
	)

/*
Se requiere listar para el Estado de California el par de clientes que sean los que suman el mayor
monto en dólares en órdenes de compra, con el formato de salida:
'Código Estado', 'Descripción Estado', 'Apellido, Nombre', 'Apellido, Nombre', 'Total Solicitado' (*)
(*) El total solicitado contendrá la suma de los dos clientes.
*/

SELECT TOP 1 s.state, s.sname, c1.lname + ', ' + c1.fname AS cliente1, c2.lname + ', ' + c2.fname AS cliente2,
		SUM(i1.quantity * i1.unit_price) + SUM(i2.quantity * i2.unit_price) AS total
FROM state s JOIN customer c1 ON c1.state = s.state
			 JOIN orders o1 ON c1.customer_num = o1.customer_num
			 JOIN items i1 ON o1.order_num = i1.order_num
			 JOIN customer c2 ON c2.state = s.state
			 JOIN orders o2 ON o2.customer_num = c2.customer_num
			 JOIN items i2 ON o2.order_num = i2.order_num
WHERE s.state = 'CA' AND c1.customer_num != c2.customer_num
GROUP BY s.state, s.sname, c1.lname + ', ' + c1.fname, c2.lname + ', ' + c2.fname
ORDER BY SUM(i1.quantity * i1.unit_price) + SUM(i2.quantity * i2.unit_price) DESC
-- MAL

	