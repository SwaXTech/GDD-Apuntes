--  Obtener un listado de todos los clientes y sus direcciones --

SELECT fname + ', ' + lname AS cliente, address1, address2
FROM customer


-- Obtener el listado anterior pero sólo los clientes que viven en el estado de California "CA" --

SELECT fname + ', ' + lname AS cliente, address1, address2
FROM customer
WHERE state = 'CA'


-- Listar todas las ciudades de la tabla clientes que pertenecen al estado de "CA", mostrar solo una vez cada ciudad --

SELECT DISTINCT city 
FROM customer
WHERE state = 'CA'

-- Ordenar la lista anterior alfabéticamente

SELECT DISTINCT city 
FROM customer
WHERE state = 'CA'
ORDER BY city

-- Mostrar la direccion sólo del cliente 103 --

SELECT address1
FROM customer
WHERE customer_num = 103

-- Mostrar la lista de productos que fabrica el fabricante "ANZ" ordenada por el campo Código de Unidad de Medida (unit_code) --

SELECT *
FROM products
WHERE manu_code = 'ANZ'
ORDER BY unit_code

-- Listar los códigos de fabricantes que tengan alguna orden de pedido ingresada, ordenados alfabéticamente y no repetidos

SELECT DISTINCT manu_code
FROM items
ORDER BY manu_code

/* 
Escribir una sentencia SELECT que devuelva el número de orden, fecha de orden, número de cliente y
fecha de embarque de todas las órdenes que no han sido pagadas (paid_date es nulo), pero fueron
embarcadas (ship_date) durante los primeros seis meses de 2015.*/

SELECT order_num, order_date, customer_num, ship_date
FROM orders
WHERE paid_date IS NULL AND YEAR(ship_date) = 2015 AND MONTH(ship_date) <=6

/*
Obtener de la tabla cliente (customer) los número de clientes y nombres de las compañías, cuyos
nombres de compañías contengan la palabra “town”.
*/

SELECT customer_num, company
FROM customer
WHERE company LIKE '%town%'


/*
Obtener el precio máximo, mínimo y precio promedio pagado (ship_charge) por todos los embarques.
Se pide obtener la información de la tabla ordenes (orders).
*/

SELECT MAX(ship_charge) AS Max, MIN(ship_charge) AS Min, AVG(ship_charge) AS Avg
FROM ORDERS


/*
Realizar una consulta que muestre el número de orden, fecha de orden y fecha de embarque de todas
que fueron embarcadas (ship_date) en el mismo mes que fue dada de alta la orden (order_date).
*/

SELECT order_num, order_date, ship_date
FROM ORDERS
WHERE MONTH(ship_date) = MONTH(order_date)


/*
Obtener la Cantidad de embarques y Costo total (ship_charge) del embarque por número de cliente y
por fecha de embarque. Ordenar los resultados por el total de costo en orden inverso
*/

SELECT customer_num, ship_date, COUNT(*) AS embarques, SUM(ship_charge) AS total
FROM orders
WHERE ship_date IS NOT NULL
GROUP BY customer_num, ship_date
ORDER BY SUM(ship_charge) DESC


/*
Mostrar fecha de embarque (ship_date) y cantidad total de libras (ship_weight) por día, de aquellos
días cuyo peso de los embarques superen las 30 libras. Ordenar el resultado por el total de libras en
orden descendente.
*/

SELECT ship_date, SUM(ship_weight)
FROM orders
WHERE ship_date IS NOT NULL
GROUP BY ship_date
HAVING SUM(ship_weight) > 30
ORDER BY SUM(ship_weight) DESC
