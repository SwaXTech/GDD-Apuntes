-- Creamos una tabla temporal de sesión, con aquello que me devuelve el SELECT
SELECT * INTO #customer_california FROM customer WHERE state = 'CA'
SELECT * FROM #customer_california

-- Es una tabla temporal creada en la sesión. En otro archivo no podría acceder a ella.
-- La tabla se borra al cerrar este archivo.

-- Tabla temporal global:

SELECT * INTO ##customer_from_palo_alto FROM customer WHERE city = 'Palo Alto'
SELECT * FROM ##customer_from_palo_alto

INSERT INTO ##customer_from_palo_alto (customer_num, lname, fname) VALUES (111, 'Pepe', 'Perez') 

-- Puedo insertar datos, y la tabla se borra cuando cierran todas las sesiones.