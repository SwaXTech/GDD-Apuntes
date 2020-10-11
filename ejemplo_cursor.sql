-- Cursores

CREATE TRIGGER elimina_order
ON orders
AFTER DELETE
AS
BEGIN
	DECLARE ordenes_a_descontar CURSOR FOR
		SELECT customer_num, COUNT(order_num) FROM deleted
			GROUP BY customer_num

	DECLARE @customer_num SMALLINT, @cant_a_descontar INTEGER;

	OPEN ordenes_a_descontar
	FETCH NEXT FROM ordenes_a_descontar INTO @customer_num, @cantidad_a_descontar;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE cant_ordenes_cliente SET cant_ordenes = cant_ordenes - @cant_a_descontar
		WHERE customer_num = @customer_num

		FETCH NEXT FROM ordenes_a_descontar INTO @customer_num, @cantidad_a_descontar;
		
	END
	CLOSE ordenes_a_descontar;
	DEALLOCATE ordenes_a_descontar
END