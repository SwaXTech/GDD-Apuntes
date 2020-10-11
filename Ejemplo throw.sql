-- Ejemplo de THROW


BEGIN
	
	DECLARE @numero INT
	SET @numero = 10;
	PRINT 'Antes del Try'
	BEGIN TRY

		PRINT 'Entra al try'
		SET @numero = @numero / 0 -- Acá tambien puede venir un THROW y pasa directo al catch, un RAISERROR no puedo setear el codigo de error
		PRINT 'Sale del try'

	END TRY

	BEGIN CATCH

		PRINT 'Entra al catch'
		PRINT 'Nro Error: ' + CAST(ERROR_NUMBER() as VARCHAR)
		PRINT 'Mensaje: ' + ERROR_MESSAGE()
		PRINT 'Status: ' + CAST(ERROR_STATE() AS VARCHAR);
		THROW 51099, 'Disparó el throw', 2; -- si hubiese acá un raiserror no interrumpe ningun flujo de ejecución, sigue ejecutando
		PRINT 'Despues del Throw'

	END CATCH

END



-- THROW NUMERROR>50000, MENSAJE, STATE(UN valor de referencia)