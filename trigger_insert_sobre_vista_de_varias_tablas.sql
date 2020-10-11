-- Trigger de INSTEAD OF sobre vista
--DROP VIEW ordenes_por_cliente
GO
CREATE VIEW ordenes_por_cliente (cod_cliente, nombre, apellido, nro_orden, fecha_orden)
AS
SELECT c.customer_num, fname, lname, order_num, order_date
FROM customer c JOIN orders o ON (c.customer_num = o.customer_num)
GO

-- Insertar acá daría error!

--DROP TRIGGER inserta_cliente_y_orden_en_vista
GO
CREATE TRIGGER inserta_cliente_y_orden_en_vista
ON ordenes_por_cliente
INSTEAD OF INSERT
AS
	BEGIN

		INSERT INTO customer (customer_num, fname, lname)
			SELECT cod_cliente, nombre, apellido FROM inserted;

		INSERT INTO orders (order_num, order_date, customer_num)
			SELECT nro_orden, fecha_orden, cod_cliente FROM inserted;
	END
GO