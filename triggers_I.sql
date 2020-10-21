/*
Dada la tabla Products de la base de datos stores7 se requiere crear una tabla
Products_historia_precios y crear un trigger que registre los cambios de precios que se hayan
producido en la tabla Products.
*/


CREATE TABLE products_historia_precios(
	stock_historia_Id INT IDENTITY(1,1) PRIMARY KEY,
	stock_num INT,
	manu_code CHAR(3),
	fecha_hora DATETIME DEFAULT GETDATE(),
	usuario VARCHAR(15) DEFAULT CURRENT_USER,
	unit_price_old DECIMAL(18,2),
	unit_price_new DECIMAL(18,2),
	estado char default 'A' check (estado IN ('A','I'))
);
GO

DROP TRIGGER cambios_productos
GO
CREATE TRIGGER cambios_productos ON products AFTER UPDATE AS
BEGIN

	DECLARE 
		@stock_num INT,
		@manu_code CHAR(3),
		@unit_price_new DECIMAL(18,2),
		@estado char;

	DECLARE updated CURSOR FOR SELECT stock_num, manu_code, unit_price FROM inserted;
	OPEN updated
	FETCH NEXT FROM updated INTO @stock_num, @manu_code, @unit_price_new;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		DECLARE @unit_price_old DECIMAL(18,2);
		SELECT @unit_price_old = unit_price FROM deleted WHERE stock_num = @stock_num AND @manu_code = manu_code;
		INSERT INTO products_historia_precios (stock_num, manu_code, unit_price_old, unit_price_new)
			VALUES(@stock_num, @manu_code, @unit_price_old, @unit_price_new);
		FETCH NEXT FROM updated INTO @stock_num, @manu_code, @unit_price_new;
	
	END

	CLOSE updated;
	DEALLOCATE updated;

END
GO

/*
Crear un trigger sobre la tabla Products_historia_precios que ante un delete sobre la misma
realice en su lugar un update del campo estado de ‘A’ a ‘I’ (inactivo).
*/

CREATE TRIGGER inactive_product ON products_historia_precios INSTEAD OF DELETE AS
BEGIN

	DECLARE 
		@stock_num INT,
		@manu_code CHAR(3);

	DECLARE deleted_rows CURSOR FOR SELECT stock_num, manu_code FROM deleted;
	OPEN deleted_rows;
	FETCH NEXT FROM deleted_rows INTO @stock_num, @manu_code;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		UPDATE products_historia_precios SET estado = 'I' WHERE stock_num = @stock_num AND manu_code = @manu_code
		FETCH NEXT FROM deleted_rows INTO @stock_num, @manu_code;

	END

END
GO

/*

Validar que sólo se puedan hacer inserts en la tabla Products en un horario entre las 8:00 AM y
8:00 PM. En caso contrario enviar un error por pantalla.

*/

CREATE TRIGGER inserts_en_horario_valido ON products INSTEAD OF INSERT AS
BEGIN

	DECLARE @stock_num INT, @manu_code CHAR(3), @unit_price DECIMAL(6,2), @unit_code INT;
	SELECT @stock_num = stock_num, @manu_code = manu_code, @unit_price = unit_price, @unit_code = unit_code
		FROM inserted;
		
	IF GETDATE() NOT BETWEEN '8:00' AND '20:00'
		THROW 50001, 'Solo insertar dentro de un horario válido', 1;
	
	INSERT INTO products (stock_num, manu_code, unit_price, unit_code)
		VALUES(@stock_num, @manu_code, @unit_price, @unit_code)



END
GO

/*
Crear un trigger que ante un borrado sobre la tabla ORDERS realice un borrado en cascada
sobre la tabla ITEMS, validando que sólo se borre 1 orden de compra.
Si detecta que están queriendo borrar más de una orden de compra, informará un error y
abortará la operación.
*/

CREATE TRIGGER borrar_items ON orders INSTEAD OF DELETE AS
BEGIN

	DECLARE @orders_to_be_deleted INT;
	SELECT @orders_to_be_deleted = COUNT(*) FROM deleted;
	IF @orders_to_be_deleted > 1
		THROW 50001, 'No se pueden borrar más de 1 orden de compra por vez.', 16

	DECLARE @order_to_be_deleted INT;
	SELECT @order_to_be_deleted = order_num FROM deleted;

	DECLARE deleted_items CURSOR FOR SELECT item_num FROM items WHERE order_num = @order_to_be_deleted;
	OPEN deleted_items;

	DECLARE @item_num INT;

	FETCH NEXT FROM deleted_items INTO @item_num;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE FROM items WHERE item_num = @item_num AND order_num = @order_to_be_deleted;
		FETCH NEXT FROM deleted_items INTO @item_num;	
	END
END
GO 

/*
Crear un trigger de insert sobre la tabla ítems que al detectar que el código de fabricante
(manu_code) del producto a comprar no existe en la tabla manufact, inserte una fila en dicha
tabla con el manu_code ingresado, en el campo manu_name la descripción ‘Manu Orden 999’
donde 999 corresponde al nro. de la orden de compra a la que pertenece el ítem y en el campo
lead_time el valor 1.
*/

CREATE TRIGGER insert_unknown_manufact ON items AFTER INSERT AS 
BEGIN

	DECLARE @manu_code CHAR(3), @order_num INT;

	DECLARE inserted_items CURSOR FOR SELECT DISTINCT manu_code, order_num FROM inserted;
	OPEN inserted_items

	FETCH NEXT FROM inserted_items INTO @manu_code, @order_num
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS (SELECT manu_name FROM manufact WHERE manu_code = @manu_code)
			INSERT INTO manufact (manu_code, manu_name, lead_time)
				VALUES (@manu_code, 'MANU ORDEN ' + CAST(@order_num AS VARCHAR(20)), 1)
	END


END
GO

/*
Crear tres triggers (Insert, Update y Delete) sobre la tabla Products para replicar todas las
operaciones en la tabla Products _replica, la misma deberá tener la misma estructura de la tabla
Products.
*/

CREATE TRIGGER replicar_insert ON products AFTER INSERT AS
BEGIN

	DECLARE @stock_num INT, @manu_code CHAR(3), @unit_price DECIMAL(6,2), @unit_code INT;

	DECLARE inserted_products CURSOR FOR SELECT stock_num, manu_code, unit_price, unit_code FROM INSERTED;
	OPEN inserted_products;
	FETCH NEXT FROM inserted_products INTO @stock_num, @manu_code, @unit_price, @unit_code;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT INTO products_replica (stock_num, manu_code, unit_price, unit_code)
			VALUES (@stock_num, @manu_code, @unit_price, @unit_code)
		FETCH NEXT FROM inserted_products INTO @stock_num, @manu_code, @unit_price, @unit_code;
	END

END
GO 

CREATE TRIGGER replicar_update ON products AFTER UPDATE AS
BEGIN

	DECLARE @stock_num INT, @manu_code CHAR(3), @unit_price DECIMAL(6,2), @unit_code INT;

	DECLARE inserted_products CURSOR FOR SELECT stock_num, manu_code, unit_price, unit_code FROM INSERTED;
	OPEN inserted_products;
	FETCH NEXT FROM inserted_products INTO @stock_num, @manu_code, @unit_price, @unit_code;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		DELETE FROM products_replica WHERE stock_num = @stock_num and manu_code = @manu_code;
		INSERT INTO products_replica (stock_num, manu_code, unit_price, unit_code)
			VALUES (@stock_num, @manu_code, @unit_price, @unit_code)
		FETCH NEXT FROM inserted_products INTO @stock_num, @manu_code, @unit_price, @unit_code;
	END

END
GO

CREATE TRIGGER replicar_delete ON products AFTER DELETE AS
BEGIN

DECLARE @stock_num INT, @manu_code CHAR(3);

	DECLARE inserted_products CURSOR FOR SELECT stock_num, manu_code FROM INSERTED;
	OPEN inserted_products;
	FETCH NEXT FROM inserted_products INTO @stock_num, @manu_code;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		DELETE FROM products_replica WHERE stock_num = @stock_num and manu_code = @manu_code;
		FETCH NEXT FROM inserted_products INTO @stock_num, @manu_code;
	END
END
GO

/*
Se pide: Crear un trigger que valide que ante un insert de una o más filas en la tabla
ítems, realice la siguiente validación:

	- Si la orden de compra a la que pertenecen los ítems ingresados corresponde a
	clientes del estado de California, se deberá validar que estas órdenes puedan tener
	como máximo 5 registros en la tabla ítem.
	
	- Si se insertan más ítems de los definidos, el resto de los ítems se deberán insertar
	en la tabla items_error la cual contiene la misma estructura que la tabla ítems más
	un atributo fecha que deberá contener la fecha del día en que se trató de insertar.

Ej. Si la Orden de Compra tiene 3 items y se realiza un insert masivo de 3 ítems más, el
trigger deberá insertar los 2 primeros en la tabla ítems y el restante en la tabla ítems_error.
Supuesto: En el caso de un insert masivo los items son de la misma orden.
*/

CREATE TABLE items_error(

	 item_num INT,
	 order_num INT,
	 stock_num INT,
	 manu_code CHAR(3),
	 quantity INT,
	 unit_price DECIMAL(8,2),
	 fecha DATETIME DEFAULT GETDATE()
);


CREATE TRIGGER validaciones_items ON items INSTEAD OF INSERT AS
BEGIN

	DECLARE @item_num INT, @order_num INT, @stock_num INT, @manu_code CHAR(3), @quantity INT, @unit_price DECIMAL(8,2);

	DECLARE inserted_items CURSOR FOR SELECT item_num, order_num, stock_num, manu_code, quantity, unit_price FROM inserted;
	OPEN inserted_items;
	FETCH NEXT FROM inserted_items INTO @item_num, @order_num, @stock_num, @manu_code, @quantity, @unit_price;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		DECLARE @state CHAR(2);
		SELECT @state = c.state FROM customer c JOIN orders o ON o.customer_num = c.customer_num WHERE o.order_num = @order_num;

		IF @state = 'CA'
		BEGIN
		
			DECLARE @orders_count INT;
			SELECT @orders_count = COUNT(*) FROM inserted WHERE order_num = @order_num

			DECLARE @table VARCHAR(15);


			IF @orders_count > 5
				INSERT INTO items_error (item_num, order_num, stock_num, manu_code, quantity, unit_price)
					VALUES(@item_num, @order_num, @stock_num, @manu_code, @quantity, @unit_price);
			ELSE
				INSERT INTO items (item_num, order_num, stock_num, manu_code, quantity, unit_price)
					VALUES(@item_num, @order_num, @stock_num, @manu_code, @quantity, @unit_price);

			FETCH NEXT FROM inserted_items INTO @item_num, @order_num, @stock_num, @manu_code, @quantity, @unit_price;
		END
	END
END
GO

/*
Dada la siguiente vista
CREATE VIEW ProdPorFabricante AS
	SELECT m.manu_code, m.manu_name, COUNT(*)
	FROM manufact m INNER JOIN products p
	ON (m.manu_code = p.manu_code)
	GROUP BY manu_code, manu_name;

Crear un trigger que permita ante un insert en la vista ProdPorFabricante insertar una fila
en la tabla manufact.

Observaciones: el atributo leadtime deberá insertarse con un valor default 10
El trigger deberá contemplar inserts de varias filas, por ej. ante un
INSERT / SELECT.
*/

CREATE VIEW ProdPorFabricante AS 
	SELECT m.manu_code, m.manu_name, COUNT(*) AS qty
	FROM manufact m INNER JOIN products p
	ON (m.manu_code = p.manu_code)
	GROUP BY m.manu_code, m.manu_name;
GO

CREATE TRIGGER insert_on_view ON ProdPorFabricante INSTEAD OF INSERT AS
BEGIN

	INSERT INTO manufact (manu_code, manu_name, lead_time)
		SELECT manu_code, manu_name, 10 FROM inserted;

END
GO

/*
Crear un trigger que ante un INSERT o UPDATE de una o más filas de la tabla Customer, realice
la siguiente validación.
	- La cuota de clientes correspondientes al estado de California es de 20, si se supera dicha
	cuota se deberán grabar el resto de los clientes en la tabla customer_pend.

	- Validar que si de los clientes a modificar se modifica el Estado, no se puede superar dicha
	cuota.

Si por ejemplo el estado de CA cuenta con 18 clientes y se realiza un update o insert masivo de 5
clientes con estado de CA, el trigger deberá modificar los 2 primeros en la tabla customer y los
restantes grabarlos en la tabla customer_pend.
La tabla customer_pend tendrá la misma estructura que la tabla customer con un atributo adicional
fechaHora que deberá actualizarse con la fecha y hora del día.
*/

CREATE TABLE customer_pend (

	customer_num INT,
	fname VARCHAR(15),
	lname VARCHAR(15),
	company VARCHAR(20),
	address1 VARCHAR(20),
	city VARCHAR(18),
	state CHAR(2),
	zipcode CHAR(5),
	phone VARCHAR(18),
	customer_num_referedBy INT,
	status char(1),
	fecha DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER customer_cuota ON customer INSTEAD OF INSERT AS
BEGIN

	DECLARE @customer_num INT, @state CHAR(2);
	DECLARE customer_inserted CURSOR FOR SELECT customer_num, state FROM inserted;

	OPEN customer_inserted;
	FETCH NEXT FROM customer_inserted INTO @customer_num, @state;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @state = 'CA'
		BEGIN
			DECLARE @state_cuota INT;
			SELECT @state_cuota = COUNT(*) FROM customer WHERE state = @state;
	
			IF @state_cuota > 20
				INSERT INTO customer_pend SELECT * FROM inserted WHERE customer_num = @customer_num
			ELSE
				INSERT INTO customer SELECT * FROM inserted WHERE customer_num = @customer_num;
		END
		INSERT INTO customer SELECT * FROM inserted WHERE customer_num = @customer_num;
		
	
	END


END
GO

/*
Dada la siguiente vista

Se pide: Crear un trigger que permita ante un DELETE en la vista ProdPorFabricante
borrar los datos en la tabla manufact pero sólo de los fabricantes cuyo campo description
sea NULO (o sea que no tienen stock).
Observaciones: El trigger deberá contemplar borrado de varias filas mediante un DELETE
masivo. En ese caso sólo borrará de la tabla los fabricantes que no tengan productos en
stock, borrando los demás.

*/


CREATE VIEW ProdPorFabricanteDet AS
	SELECT m.manu_code, m.manu_name, pt.stock_num, pt.description
		FROM manufact m LEFT OUTER JOIN products p ON m.manu_code = p.manu_code
						LEFT OUTER JOIN product_types pt ON p.stock_num = pt.stock_num;
GO

CREATE TRIGGER deleting_products_null ON ProdPorFabricanteDet INSTEAD OF DELETE AS
BEGIN

	DECLARE manufact_deleted CURSOR FOR SELECT manu_code, description FROM inserted;
	OPEN manufact_deleted;

	DECLARE @manu_code CHAR(3), @desc VARCHAR(15);
	FETCH NEXT FROM manufact_deleted INTO @manu_code, @desc;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @desc = NULL
			DELETE FROM manufact WHERE manu_code = @manu_code


		FETCH NEXT FROM manufact_deleted INTO @manu_code, @desc;


	END

END
GO

/*
Se pide crear un trigger que permita ante un delete de una sola fila en la vista
ordenesPendientes valide:

	- Si el cliente asociado a la orden tiene sólo esa orden pendiente de pago (paid_date IS
	NULL), no permita realizar la Baja, informando el error.

	- Si la Orden tiene más de un ítem asociado, no permitir realizar la Baja, informando el
	error.

	- Ante cualquier otra condición borrar la Orden con sus ítems asociados, respetando la
	integridad referencial.

Estructura de la vista: customer_num, fname, lname, Company, order_num, order_date
WHERE paid_date IS NULL.
*/

CREATE VIEW ordenes_pendientes AS 
	SELECT c.customer_num, c.fname, c.lname, c.company, o.order_num, o.order_date 
		FROM orders o 
			JOIN customer c ON c.customer_num = o.customer_num
		WHERE paid_date IS NULL
GO

SELECT * FROM ordenes_pendientes
GO

CREATE TRIGGER deleting_ordenes_pendientes ON ordenes_pendientes INSTEAD OF DELETE AS
BEGIN

	DECLARE orders_deleted CURSOR FOR SELECT customer_num, order_num FROM deleted;
	OPEN orders_deleted;

	DECLARE @customer_num INT;
	DECLARE @order_num INT;

	FETCH NEXT FROM orders_deleted INTO @customer_num, @order_num;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		DECLARE @count_ordenes_pendientes INT;
		SELECT @count_ordenes_pendientes = COUNT(*) FROM ordenes_pendientes WHERE customer_num = @customer_num;

		
		IF @count_ordenes_pendientes = 1
			PRINT 'Única orden'
			FETCH NEXT FROM orders_deleted INTO @customer_num, @order_num
			CONTINUE;

		DECLARE @count_items_asociados INT;
		SELECT @count_items_asociados = COUNT(*) FROM items WHERE order_num = @order_num;

		IF @count_ordenes_pendientes = 1
			PRINT 'Multiples items'
			FETCH NEXT FROM orders_deleted INTO @customer_num, @order_num
			CONTINUE;

		DELETE FROM items WHERE order_num = @order_num;
		DELETE FROM orders WHERE order_num = @order_num;

		FETCH NEXT FROM orders_deleted INTO @customer_num, @order_num;
	END

END
GO