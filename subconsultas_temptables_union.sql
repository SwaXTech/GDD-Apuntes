/*
Mostrar el Código del fabricante, nombre del fabricante, tiempo de entrega y monto
Total de productos vendidos, ordenado por nombre de fabricante. En caso que el
fabricante no tenga ventas, mostrar el total en NULO.
*/

SELECT m.manu_code, m.manu_name, m.lead_time, SUM(i.quantity * i.unit_price) AS MontoTotal
FROM manufact m LEFT JOIN items i ON m.manu_code = i.manu_code
GROUP BY m.manu_code, m.manu_name, m.lead_time
ORDER BY m.manu_name


/*
Mostrar una lista de a pares, de todos los fabricantes que fabriquen el mismo producto.
En el caso que haya un único fabricante deberá mostrar el Código de fabricante 2 en
nulo.
*/

SELECT p.stock_num, pt.description, m1.manu_code AS CodFab1, m2.manu_code AS CodFab2
FROM products p INNER JOIN product_types pt ON (p.stock_num = pt.stock_num)
				INNER JOIN manufact m1 ON (p.manu_code = m1.manu_code)
				LEFT JOIN manufact m2 ON (p.manu_code != m2.manu_code)


/*
Listar todos los clientes que hayan tenido más de una orden.
a) En primer lugar, escribir una consulta usando una subconsulta.
b) Reescribir la consulta usando dos sentencias SELECT y una tabla temporal.
c) Reescribir la consulta utilizando GROUP BY y HAVING.*/

--a)
SELECT c.customer_num, fname, lname FROM customer c
WHERE EXISTS (SELECT o.customer_num, COUNT(o.customer_num) FROM orders o WHERE c.customer_num = o.customer_num GROUP BY customer_num HAVING COUNT(customer_num) > 1)

-- Subquery correlacionado
SELECT customer_num, lname, fname FROM customer c WHERE EXISTS (SELECT 0 FROM orders o WHERE o.customer_num = c.customer_num)

-- b)


SELECT customer_num, COUNT(customer_num) AS cantidad INTO #clientes_con_ordenes FROM orders GROUP BY customer_num
SELECT c.customer_num, fname, lname FROM customer c INNER JOIN #clientes_con_ordenes co ON c.customer_num = co.customer_num WHERE co.cantidad > 1

-- c)

SELECT c.customer_num, fname, lname FROM customer c INNER JOIN orders o ON c.customer_num = o.customer_num
GROUP BY c.customer_num, fname, lname 
HAVING COUNT(o.customer_num) > 1


/*
Seleccionar todas las Órdenes de compra cuyo Monto total (Suma de p x q de sus items)
sea menor al precio total promedio (avg p x q) de todos los ítems de todas las ordenes.
*/

SELECT o.order_num, SUM(i.quantity * i.unit_price) AS monto_total FROM orders o INNER JOIN items i ON o.order_num = i.order_num
GROUP BY o.order_num
HAVING SUM(i.quantity * i.unit_price)  > AVG(unit_price * quantity)


/*
Obtener por cada fabricante, el listado de todos los productos de stock con precio
unitario (unit_price) mayor que el precio unitario promedio para dicho fabricante.
Los campos de salida serán: manu_code, manu_name, stock_num, description,
unit_price.

Por ejemplo:
	El precio unitario promedio de los productos fabricados por ANZ es $180.23. se
	debe incluir en su lista todos los productos de ANZ que tengan un precio unitario
	superior a dicho importe.
*/

SELECT manu_code, AVG(unit_price) AS promedio INTO #precios_promedio FROM products GROUP BY manu_code
SELECT * from #precios_promedio

SELECT p.manu_code, manu_name, p.stock_num, description, unit_price 
FROM products p JOIN manufact m ON m.manu_code = p.manu_code
				JOIN product_types pt ON p.stock_num = pt.stock_num
WHERE unit_price > (SELECT promedio FROM #precios_promedio pp WHERE p.manu_code = pp.manu_code)


/*
Usando el operador NOT EXISTS listar la información de órdenes de compra que NO
incluyan ningún producto que contenga en su descripción el string ‘ baseball gloves’.
Ordenar el resultado por compañía del cliente ascendente y número de orden
descendente.
*/

SELECT p.stock_num INTO #no_baseball_gloves FROM products p JOIN product_types pt ON p.stock_num = pt.stock_num WHERE pt.description NOT LIKE '%baseball gloves%'
SELECT * FROM #no_baseball_gloves

SELECT c.customer_num, company, o.order_num, order_date FROM customer c JOIN orders o ON c.customer_num = o.customer_num JOIN items i ON (i.order_num = o.order_num)
WHERE NOT EXISTS (SELECT stock_num FROM #no_baseball_gloves WHERE i.stock_num = #no_baseball_gloves.stock_num)
ORDER BY company ASC, order_num DESC


/*
Reescribir la siguiente consulta utilizando el operador UNION:*/

SELECT * FROM products
WHERE manu_code = 'HRO' OR stock_num = 1

SELECT * FROM products
WHERE manu_code = 'HRO' 
UNION 
SELECT * FROM products
WHERE stock_num = 1


