/* 
Listar fname, lname, customer_num, addres1, city y zipcode 
de los clientes que vivan en el state 'CA', que su zipcode finalice con 025.
El apellido deber� estar en may�sculas y la columna deber� tener el label apellido
*/
SELECT fname, UPPER(lname) apellido, customer_num, address1, city, zipcode 
FROM customer
WHERE state = 'CA' AND zipcode LIKE '%025'


/*
Listar por cada c�digo de fabricante, cantidad de ordenes de compra (ante repetidos contar solo una),
Suma de quantity, suma de unit_price, para los fabricantes que tengan m�s de 5 items comprados (cantidad
de filas en table items > 5).
Ordenado por la suma de unit_price*quantity
*/

SELECT manu_code, COUNT(DISTINCT order_num), SUM(quantity), SUM(unit_price)
FROM items
GROUP BY manu_code
HAVING COUNT(*) > 5 -- es lo mismo que item_num y order_num porque son PK. Sino no ser�a lo mismo
ORDER BY SUM(unit_price * quantity)