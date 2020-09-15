-- Práctica - Clase 4


-- Crear una consulta que liste todos los clientes que vivan en California ordenados por compañía.

SELECT * FROM customer
WHERE state = 'CA'
ORDER BY company


/*
Obtener un listado de la cantidad de productos únicos comprados a cada fabricante, en donde el total
comprado a cada fabricante sea mayor a 1500. El listado deberá estar ordenado por cantidad de productos
comprados de mayor a menor.
*/

SELECT DISTINCT COUNT(*) AS Quantity, manu_code
FROM products
GROUP BY manu_code
ORDER BY COUNT(*) DESC
 

/*
Obtener un listado con el código de fabricante, nro de producto, la cantidad vendida (quantity), y el total
vendido (quantity x unit_price), para los fabricantes cuyo código tiene una “R” como segunda letra. Ordenar
el listado por código de fabricante y nro de producto.
*/

SELECT manu_code, item_num, quantity, quantity * unit_price AS total_vendido
FROM items
WHERE manu_code LIKE '_R%'
ORDER BY manu_code, item_num


/*Crear una tabla temporal OrdenesTemp que contenga las siguientes columnas: cantidad de órdenes por
cada cliente, primera y última fecha de orden de compra (order_date) del cliente. Realizar una consulta de
la tabla temp OrdenesTemp en donde la primer fecha de compra sea anterior a '2015-05-23 00:00:00.000',
ordenada por fechaUltimaCompra en forma descendente.
*/

SELECT customer_num, (SELECT COUNT(customer_num)) AS quantity, MIN(order_date) AS fst_order, MAX(order_date) AS lst_order
INTO #ordenes_temp
FROM orders
GROUP BY customer_num

SELECT * FROM #ordenes_temp

/*Consultar la tabla temporal del punto anterior y obtener la cantidad de clientes con igual cantidad de
compras. Ordenar el listado por cantidad de compras en orden descendente
*/

SELECT COUNT(customer_num) AS clients, quantity 
FROM #ordenes_temp 
GROUP BY quantity 
ORDER BY COUNT(DISTINCT quantity) DESC

/*Desconectarse de la sesión. Volver a conectarse y ejecutar SELECT * from #ordenesTemp.
Que sucede?
*/

-- RTA: La tabla se borró

/*Se desea obtener la cantidad de clientes por cada state y city, donde los clientes contengan el string
‘ts’ en el nombre de compañía, el código postal este entre 93000 y 94100 y la ciudad no sea 'Mountain View'. Se
desea el listado ordenado por ciudad
*/

SELECT COUNT(customer_num) AS Quantity, state, city
FROM customer
WHERE (company LIKE '%st%') AND (zipcode BETWEEN 93000 AND 94100) AND city != 'Mountain View'
GROUP BY state, city
ORDER BY city

/*
Para cada estado, obtener la cantidad de clientes referidos. Mostrar sólo los clientes que hayan sido
referidos cuya compañía empiece con una letra que este en el rango de ‘A’ a ‘L’.
*/

SELECT state, COUNT(customer_num)
FROM customer
WHERE company LIKE '[A-L]%'
GROUP BY state

/*Se desea obtener el promedio de lead_time por cada estado, donde los Fabricantes tengan una ‘e’ en
manu_name y el lead_time sea entre 5 y 20.*/

SELECT manu_name, AVG(lead_time)
FROM manufact
WHERE manu_name LIKE '%e%'
GROUP BY manu_name
HAVING AVG(lead_time) BETWEEN 5 AND 20


/*Se tiene la tabla units, de la cual se quiere saber la cantidad de unidades que hay por cada tipo (unit) que no
tengan en nulo el descr_unit, y además se deben mostrar solamente los que cumplan que la cantidad
mostrada se superior a 5. Al resultado final se le debe sumar 1*/

SELECT COUNT(unit_code) + 1 AS Quantity, unit
FROM units
WHERE unit_descr IS NOT NULL
GROUP BY unit
HAVING COUNT(unit_code) > 5

