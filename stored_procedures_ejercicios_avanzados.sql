/*
1.Crear la tabla CustomerStatistics con los siguientes campos customer_num
(entero y pk), ordersQty (entero), maxDate (date), productsQty (entero)

2. Crear un procedimiento �CustomerStatisticsUpdate� que reciba el par�metro
fecha_DES (date) y que en base a los datos de la tabla Customer, inserte (si
no existe) o actualice el registro de la tabla CustomerStatistics con la
siguiente informaci�n:
	ordersqty: cantidad de �rdenes para cada cliente + las nuevas
	�rdenes con fecha mayor o igual a fecha_DES
	maxDate: fecha de la �ltima �rden del cliente.
	productsQty: cantidad �nica de productos adquiridos por cada
	cliente hist�rica
*/

-- 1 

CREATE TABLE customer_statistics(

 customer_num INT PRIMARY KEY,
 orders_qty INT,
 max_date DATE,
 products_qty INT
);
GO

-- 2


/*
1. Crear la tabla informeStock con los siguientes campos: fechaInforme (date),
stock_num (entero), manu_code (char(3)), cantOrdenes (entero), UltCompra
(date), cantClientes (entero), totalVentas (decimal). PK (fechaInforme,
stock_num, manu_code)

2. Crear un procedimiento �generarInformeGerencial� que reciba un par�metro
fechaInforme y que en base a los datos de la tabla PRODUCTS de todos los
productos existentes, inserte un registro de la tabla informeStock con la
siguiente informaci�n:
	fechaInforme: fecha pasada por par�metro
	stock_num: n�mero de stock del producto
	manu_code: c�digo del fabricante
	cantOrdenes: cantidad de �rdenes que contengan el producto.
	UltCompra: fecha de �ltima orden para el producto evaluado.
	cantClientes: cantidad de clientes �nicos que hayan comprado el
	producto.
	totalVentas: Sumatoria de las ventas de ese producto (p x q)
	Validar que no exista en la tabla informeStock un informe con la misma
	fechaInforme recibida por par�metro.
*/

CREATE TABLE informeStock(
	fechaInforme DATE,
	stock_num INT, 
	manu_code CHAR(3),
	cantOrdenes INT,
	ult_compra DATE, 
	cantClientes INT, 
	totalVentas DECIMAL(18,2)
	PRIMARY KEY(fechaInforme, stock_num, manu_code));
GO

DROP PROCEDURE generar_informe_gerencial
CREATE PROCEDURE generar_informe_gerencial @fecha_informe DATETIME AS
BEGIN

	DECLARE @stock_num INT, @manu_code CHAR(3), @cant_ordenes INT, @ult_compra DATE, @cant_clientes INT, @total_ventas DECIMAL(18,2);
	
	IF EXISTS (SELECT fechaInforme FROM informeStock WHERE fechaInforme = @fecha_informe)
		THROW 50000, 'Ya existe', 16
	
	
		SELECT @stock_num = p.stock_num,
			   @manu_code = p.manu_code,
			   @cant_ordenes = COUNT(DISTINCT o.order_num),
			   @ult_compra = MAX(DISTINCT o.order_date),
			   @cant_clientes = COUNT(DISTINCT o.customer_num),
			   @total_ventas = SUM(i.unit_price * i.quantity)
			   FROM orders o JOIN  items i ON o.order_num = i.order_num
							 JOIN products p ON i.stock_num = p.stock_num AND i.manu_code = i.manu_code
			   GROUP BY p.stock_num, p.manu_code

		INSERT INTO informeStock (fechaInforme, stock_num, manu_code, cantOrdenes, ult_compra, cantClientes, totalVentas)
			VALUES (@fecha_informe, @stock_num, @manu_code, @cant_ordenes, @ult_compra, @cant_clientes, @total_ventas)

END
GO
-- No anda --> Hacer sin variables. SOLO INSERT SELECT
EXEC generar_informe_gerencial '2017-02-01';
SELECT * FROM informeStock


/*
Crear un procedimiento �generarInformeVentas� que reciba como par�metros
fechaInforme y codEstado y que en base a los datos de la tabla customer de todos
los clientes que vivan en el estado pasado por par�metro, inserte un registro de la
tabla informeVentas con la siguiente informaci�n:

	fechaInforme: fecha pasada por par�metro
	codEstado: c�digo de estado recibido por par�metro
	customer_num: n�mero de cliente
	cantOrdenes: cantidad de �rdenes del cliente.
	primerVenta: fecha de la primer orden al cliente.
	UltVenta: fecha de �ltima orden al cliente.
	cantProductos: cantidad de tipos de productos �nicos que haya
	comprado el cliente.
	totalVentas: Sumatoria de las ventas de ese producto (p x q)
	Validar que no exista en la tabla informeVentas un informe con la misma
	fechaInforme y estado recibido por par�metro.

*/

CREATE TABLE informe_ventas(

	fecha_informe DATETIME,
	cod_estado INT,
	customer_num INT,
	cant_ordenes INT,
	primer_venta DATETIME,
	ult_venta DATETIME,
	cant_productos INT,
	total_ventas DECIMAL(18,2),
);
GO

-- Cursores --> Solo usar si tengo que hacer algo fila por fila.

CREATE PROCEDURE generar_informe_ventas @fecha_informe DATETIME, @cod_estado INT AS
BEGIN

	IF EXISTS (SELECT fecha_informe, cod_estado FROM informe_ventas WHERE fecha_informe = @fecha_informe AND cod_estado = @cod_estado)
		THROW 50000, 'Ya existe', 16


	INSERT INTO informe_ventas (fecha_informe, cod_estado, customer_num, cant_ordenes, primer_venta, ult_venta, cant_productos, total_ventas)
		SELECT @fecha_informe, @cod_estado, o.customer_num, COUNT(DISTINCT o.order_num), MIN(o.order_date), MAX(o.order_date), COUNT(DISTINCT i.stock_num), SUM(i.unit_price * i.quantity)
		FROM orders o JOIN items i ON o.order_num = i.order_num JOIN customer c ON c.customer_num = o.customer_num
		WHERE c.state = @cod_estado
		GROUP BY  o.customer_num

END
GO