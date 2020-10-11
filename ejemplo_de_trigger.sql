CREATE TRIGGER state_update_audit
ON state
AFTER UPDATE
AS 
	BEGIN
		INSERT INTO state_upd
			SELECT state, sname, 'A', GETDATE() FROM deleted

		INSERT INTO state_upd
			SELECT state, sname, 'N', GETDATE() FROM inserted
	END
GO

CREATE TABLE state_upd(
	id_auditoria INT IDENTITY(1,1),
	state CHAR(2) NOT NULL,
	sname VARCHAR(15) NULL,
	accion CHAR,
	fechaYHora DATETIME
)

UPDATE state SET sname='Arizona'
WHERE state = 'AZ'

SELECT * FROM state_upd
SELECT * FROM state_upd WHERE state = 'AZ'

--DROP TABLE state_upd
--DROP TRIGGER state_update_audit
