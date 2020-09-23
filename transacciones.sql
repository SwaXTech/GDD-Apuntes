BEGIN TRANSACTION
	INSERT INTO customer (customer_num, lname, fname)
		VALUES (1117, 'Sorlango', 'Mirko')
	INSERT INTO orders (order_num, customer_num)
		VALUES (5252, 1117)
	INSERT INTO products (stock_num, manu_code)
		VALUES (1, 'ANZ')
	INSERT INTO items (order_num, item_num, stock_num, manu_code, quantity, unit_price)
		VALUES (5252, 1, 1, 'ANZ', 10, 150)
COMMIT TRANSACTION

-- Rollback transaction:

CREATE TABLE  #numeros (num INT)

BEGIN TRANSACTION T1

	INSERT INTO #numeros VALUES (1)

	BEGIN TRANSACTION T2
		INSERT INTO #numeros VALUES (2)
	COMMIT TRANSACTION -- Confirma T2

ROLLBACK TRANSACTION -- Deshace T1 que contiene a T2. Entonces también la deshace


-- Punto intermedio de guardado de información:


BEGIN TRANSACTION

	INSERT INTO #numeros VALUES (2)

	SAVE TRAN N2 -- Guardo estado actual a N2

	BEGIN TRANSACTION T2
		INSERT INTO #numeros VALUES(3)
	ROLLBACK TRANSACTION N2 -- Deshago la transaccion actual hasta N2
	
	INSERT INTO #numeros VALUES (4)

COMMIT TRANSACTION

-- Es posible realizar más de un SAVE en cada transacción y se puede elegir a cual se desea volver en cual momento
