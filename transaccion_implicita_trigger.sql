-- Transacciones evento-acción implícitas en Triggers

DROP TRIGGER state_update_audit
CREATE TRIGGER state_update_audit
ON state
AFTER UPDATE
AS
	BEGIN
		INSERT INTO state_upd
		SELECT state, sname, 'A', GETDATE() FROM deleted

		INSERT INTO state_upd
		SELECT NULL, sname, 'N', GETDATE() FROM inserted -- FUERZO UN ERROR A PROPÓSITO

	END
GO


UPDATE state SET sname = 'AZ...' WHERE state = 'AZ' -- SE DESHIZO GRACIAS AL TRIGGER
