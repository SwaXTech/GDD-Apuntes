-- Hay veces que hay que manejar en un solo trigger muchas operaciones.

CREATE TRIGGER prueba_trigger ON state
   INSTEAD OF INSERT, UPDATE, DELETE AS
BEGIN
--
    SET CONCAT_NULL_YIELDS_NULL OFF;  
	--
    DECLARE curInsDel CURSOR FOR
	       SELECT d.state, d.sname, i.state, i.sname
		     FROM deleted d FULL OUTER join inserted i ON d.state = i.state --> Clave primaria 
																			--> FULL OUTER JOIN 
																			--> Si no pongo full outer join solo me trae valores si hago update, pierdo inserts y deletes, si hago update de primary key no matchea
	--
	DECLARE @stateD CHAR(2), @snameD VARCHAR(15), @stateI CHAR(2), @snameI VARCHAR(15)

    OPEN curInsDel
	FETCH NEXT FROM curInsDel INTO @stateD, @snameD, @stateI, @snameI
	WHILE @@FETCH_STATUS = 0 
	BEGIN
	   PRINT @stateD + ':' + @snameD + '-->' + @stateI + ':' + @snameI
	   FETCH NEXT FROM curInsDel INTO @stateD, @snameD, @stateI, @snameI
	END

	--> Supongamos que quiero llevar el stock de mercaderia vendida y quiero tener la info en tiempo real.

	CLOSE curInsDel
	DEALLOCATE curInsDel
--
END
GO

/*
FULL OUTER JOIN

Trae todos los valores, haya match o no


*/

-- Ejemplo de uso

UPDATE state SET sname = 'OtroEstado' WHERE state = 'CA';
DELETE FROM state
UPDATE state SET sname = 'OtroEstado'
