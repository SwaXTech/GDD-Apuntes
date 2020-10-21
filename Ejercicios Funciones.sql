/*

Escribir una sentencia SELECT que devuelva el número de orden, fecha de orden y el nombre del
día de la semana de la orden de todas las órdenes que no han sido pagadas.
Si el cliente pertenece al estado de California el día de la semana debe devolverse en inglés, caso
contrario en español. Cree una función para resolver este tema.
Nota: SET @DIA = datepart(weekday,@fecha)
Devuelve en la variable @DIA el nro. de día de la semana , comenzando con 1 Domingo hasta 7
Sábado.

*/

SELECT order_num, order_date, dbo.dia_en_idioma(order_date, state) FROM orders o JOIN customer c ON c.customer_num = o.customer_num WHERE paid_date IS NULL
GO

CREATE FUNCTION dia_en_idioma(@date DATETIME, @state CHAR(2)) RETURNS VARCHAR(15) AS
BEGIN

	DECLARE @day INT;
	SET @day = DATEPART(WEEKDAY, @DATE);

	DECLARE @dia_semana VARCHAR(15);

	IF @state = 'CA'
		SET @dia_semana = CASE @day
						WHEN 2 THEN 'LUNES'
						WHEN 3 THEN 'MARTES'
						WHEN 4 THEN 'MIERCOLES'
						WHEN 5 THEN 'JUEVES'
						WHEN 6 THEN 'VIERNES'
						WHEN 7 THEN 'SABADO'
						WHEN 1 THEN 'DOMINGO'
					  END;
	ELSE
		SET @dia_semana = CASE @day
						WHEN 2 THEN 'MONDAY'
						WHEN 3 THEN 'TUESDAY'
						WHEN 4 THEN 'WEDNESDAY'
						WHEN 5 THEN 'THURSDAY'
						WHEN 6 THEN 'FRIDAY'
						WHEN 7 THEN 'SATURDAY'
						WHEN 1 THEN 'SUNDAY'
					  END;

	RETURN @dia_semana
END
GO

/*
Escribir una sentencia SELECT para los clientes que han tenido órdenes en al menos 2 meses
diferentes, los dos meses con las órdenes con el mayor ship_charge.

Se debe devolver una fila por cada cliente que cumpla esa condición, el formato es:
	Cliente		Año y mes mayor carga		Segundo año mayor carga
	NNNN		YYYY - Total: NNNN.NN		YYYY - Total: NNNN.NN

La primera columna es el id de cliente y las siguientes 2 se refieren a los campos ship_date y ship_charge.
Se requiere crear una función que devuelva la información de 1er o 2do año mes con la orden con mayor Carga
(ship_charge).
*/

SELECT distinct customer_num, dbo.fx_datosporMes(1, customer_num),
	dbo.fx_datosporMes(2, customer_num)
	FROM orders o
	WHERE EXISTS (SELECT 1
	FROM orders o2
	WHERE o2.customer_num = o.customer_num
	AND month(o.order_date) > month(o2.order_date))

DROP FUNCTION fx_datosporMes

CREATE FUNCTION dbo.fx_datosporMes (@ORDEN SMALLINT, @CLIENTE INT) RETURNS VARCHAR(100) AS
BEGIN
	DECLARE @MES VARCHAR(4)
	DECLARE @CARGA VARCHAR(50)
	DECLARE @RETORNO VARCHAR(100)
	IF @ORDEN = 1
	BEGIN
		SELECT TOP 1 @MES = MONTH(order_date),
			@CARGA = MAX(ship_charge)
			FROM orders
			WHERE customer_num = @CLIENTE
			GROUP BY MONTH(order_date)
			ORDER BY 2 DESC
			SET @RETORNO = @MES + ' - Total: ' + @CARGA
	END

	ELSE
	BEGIN
		SELECT TOP 1 @MES = order_date,
			@CARGA = COALESCE(ship_charge,0) FROM
			(SELECT TOP 2 MONTH(order_date) as order_date, MAX(ship_charge) as ship_charge
			FROM orders
			WHERE customer_num = @CLIENTE
			GROUP BY MONTH(order_date)
			ORDER BY 2 DESC) as SQL1 ORDER BY 2 ASC
		SET @RETORNO = @MES + ' - Total: ' + @CARGA
	END
	RETURN @RETORNO
END

/*
Escribir un Select que devuelva para cada producto de la tabla Products que exista en la tabla
Catalog todos sus fabricantes separados entre sí por el caracter pipe (|). Utilizar una función para
resolver parte de la consulta. Ejemplo de la salida
Stock_num Fabricantes
5 NRG | SMT | ANZ
*/

DROP FUNCTION fabricantes 
GO
CREATE FUNCTION fabricantes(@stock_num INT) RETURNS VARCHAR(15) AS
BEGIN

	DECLARE fabricantes_code CURSOR FOR SELECT DISTINCT manu_code FROM catalog WHERE stock_num = @stock_num AND manu_code IS NOT NULL;
	OPEN fabricantes_code;

	DECLARE @string VARCHAR(20);
	SET @string = ''
	DECLARE @code CHAR(3);
	FETCH NEXT FROM fabricantes_code INTO @code;

	SET @string = @string + CAST(@code AS VARCHAR);

	FETCH NEXT FROM fabricantes_code INTO @code;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		SET @string = @string + ' | '+ CAST(@code AS VARCHAR)
		

	FETCH NEXT FROM fabricantes_code INTO @code;
	END

	CLOSE fabricantes_code;
	DEALLOCATE fabricantes_code;

	RETURN @string;
END
GO

SELECT DISTINCT stock_num, dbo.fabricantes(stock_num) FROM catalog

