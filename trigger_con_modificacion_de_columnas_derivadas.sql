ALTER TABLE orders ADD total DECIMAL(12,2)
UPDATE orders SET total = (SELECT SUM(unit_price*quantity) FROM items i where i.order_num = orders.order_num)
GO

CREATE TRIGGER upd_items_ordenes
ON items
AFTER UPDATE
AS
BEGIN

	DECLARE	@i_prec_del DEC(8,2), @n_orden INT, @i_prec_ins DEC(8,2),
	@quantity_del INT, @quantity_ins INT;

	SELECT @i_prec_del = unit_price, @quantity_del = quantity FROM deleted;

	SELECT @n_orden = order_num, @i_prec_ins = unit_price, @quantity_ins = quantity FROM inserted;

	IF UPDATE(unit_price) OR UPDATE(quantity)
	BEGIN
		UPDATE orders SET total = total - (@quantity_del * @i_prec_del) + (@quantity_ins * @i_prec_ins)
			WHERE order_num = @n_orden;
	END
END

-- EL CAMPO total NO EXISTE PERO SUPONIENDO QUE EXISTIESE SERÍA ASÍ.