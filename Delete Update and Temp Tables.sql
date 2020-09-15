
-- Práctica de INSERT, UPDATE y DELETE. --

/*Crear una tabla temporal #clientes a partir de la siguiente consulta:

SELECT * FROM customer

*/

SELECT * INTO #clientes FROM customer

/*Insertar el siguiente cliente en la tabla #clientes
Customer_num 144
Fname Agustín
Lname Creevy
Company Jaguares SA
State CA
City Los Angeles*/

INSERT INTO #clientes (customer_num, fname, lname, company, state, city)
VALUES (144, 'Agustín', 'Creevy', 'Jaguares SA', 'CA', 'Los Angeles')

/*Crear una tabla temporal #clientesCalifornia con la misma estructura de la tabla customer.
Realizar un insert masivo en la tabla #clientesCalifornia con todos los clientes de la tabla customer cuyo
state sea CA.*/

CREATE TABLE #clientes_california(
	customer_num SMALLINT PRIMARY KEY,
	fname VARCHAR(15),
	lname VARCHAR(15),
	company VARCHAR(20),
	address1 VARCHAR(20),
	address2 VARCHAR(20),
	city VARCHAR(15),
	state CHAR(2) REFERENCES state,
	zipcode CHAR(5),
	phone VARCHAR(18),
	customer_num_referedBy SMALLINT REFERENCES customer,
	status CHAR(1),
);

INSERT INTO #clientes_california
	SELECT * FROM customer
	WHERE state = 'CA'

SELECT * FROM #clientes_california



/*Insertar el siguiente cliente en la tabla #clientes un cliente que tenga los mismos datos del cliente 103,
pero cambiando en customer_num por 155
Valide lo insertado.*/

INSERT INTO #clientes
	SELECT  155, fname, lname, company, address1, address2, city, state, zipcode, phone, customer_num_referedBy, status 
	FROM #clientes
WHERE customer_num = 103

SELECT * FROM #clientes WHERE customer_num = 155
SELECT * FROM #clientes WHERE customer_num = 103 

/*Borrar de la tabla #clientes los clientes cuyo campo zipcode esté entre 94000 y 94050 y la ciudad
comience con ‘M’. Validar los registros a borrar antes de ejecutar la acción.*/

SELECT * FROM #clientes WHERE (zipcode BETWEEN 94000 AND 94050) AND city LIKE 'M%'
DELETE FROM #clientes 
WHERE (zipcode BETWEEN 94000 AND 94050) AND city LIKE 'M%'


/*Modificar los registros de la tabla #clientes cambiando el campo state por ‘AK’ y el campo address2 por
‘Barrio Las Heras’ para los clientes que vivan en el state 'CO'. Validar previamente la cantidad de
registros a modificar.*/

SELECT * FROM #clientes WHERE state = 'CO'
UPDATE #clientes SET state = 'AK', address2 = 'Barrio Las Heras' WHERE state = 'CO'
SELECT * FROM #clientes WHERE state = 'CO'

/*Modificar todos los clientes de la tabla #clientes, agregando un dígito 1 delante de cada número
telefónico, debido a un cambio de la compañía de teléfonos.*/

SELECT * FROM #clientes
UPDATE #clientes SET phone = '1' + phone 