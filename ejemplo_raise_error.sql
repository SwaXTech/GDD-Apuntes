-- Ejemplo de RaiseError


BEGIN
	
	DECLARE @numero INT
	SET @numero = 10;
	PRINT 'Antes del Try'
	BEGIN TRY

		PRINT 'Entra al try'
		SET @numero = @numero / 0
		PRINT 'Sale del try'

	END TRY

	BEGIN CATCH

		PRINT 'Entra al catch'
		PRINT 'Nro Error: ' + CAST(ERROR_NUMBER() as VARCHAR)
		PRINT 'Mensaje: ' + ERROR_MESSAGE()
		PRINT 'Status: ' + CAST(ERROR_STATE() AS VARCHAR)
		RAISERROR('ERROR EN EL CATCH', 16, 1);
		PRINT 'Despues del RaiseError'

	END CATCH

END

-- RAISERROR --> Mensaje, severidad (16, se atrapa el error), STATE
