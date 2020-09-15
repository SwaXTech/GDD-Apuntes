/*
Dada una tabla mergeFuente y una tabla mergeDestino cuyas claves primarias en ambas es el
atributo código:
- Si el código de la tabla mergeFuente existe en la tabla mergeDestino y las direcciones son diferentes entonces actualizar la dirección en la tabla mergeDestino
- Si el código de la tabla mergeFuente NO existe en la tabla mergeDestino entonces insertar en la tabla mergeDestino el registro de la tabla mergeFuente.
- Si el código de la tabla mergeDestino NO existe en la tabla mergeFuente entonces borrar el registro de la tabla mergeDestino
*/

IF OBJECT_ID('mergeFuente', 'U') IS NOT NULL
BEGIN
	PRINT 'La tabla fuente existe, sera Dropeada'
		DROP TABLE mergeFuente;
END

CREATE TABLE mergeFuente
(codigo SMALLINT PRIMARY KEY,
nombre VARCHAR(30) NOT NULL,
direccion VARCHAR(50)
);

IF OBJECT_ID('mergeDestino', 'U') IS NOT NULL
BEGIN
	PRINT 'La tabla Destino existe, sera Dropeada'
	DROP TABLE mergeDestino;
END

CREATE TABLE mergeDestino(
	codigo SMALLINT PRIMARY KEY,
	nombre VARCHAR(30) NOT NULL,
	direccion VARCHAR(50),
	estado CHAR(1) DEFAULT 'A',
	observaciones VARCHAR(50)
);

-- Insertamos filas en la tabla fuente
INSERT INTO mergeFuente (codigo, nombre, direccion) VALUES
(2, 'Ricardo Ruben', 'Paraguay 1888'), -- Modifica la direccion
(3, 'Juan Jose Jacinto', 'Terranova 765'), -- No modificado
(8, 'Carola Sampietro', 'Arenales 1265'); -- Nuevo

-- Insertamos filas en la tabla destino
INSERT INTO mergeDestino (codigo, nombre, direccion) VALUES
(1, 'Pepe', 'Venezuela 3456'),
(2, 'Ricardo Ruben', 'Cucha Cucha 234'),
(3, 'Juan Jose Jacinto', 'Terranova 765'),
(4, 'Violeta Rivarola', 'Quito 2112');

-- Verificamos los datos existentes en ambas tablas
SELECT * FROM mergeFuente;
SELECT * FROM mergeDestino;

MERGE mergeDestino d
USING mergeFuente f
	ON d.codigo = f.codigo
	WHEN MATCHED AND d.direccion <> f.direccion THEN
		UPDATE
			SET d.direccion = f.direccion
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (codigo, nombre, direccion, estado, observaciones)
			VALUES (f.codigo, f.nombre, f.direccion, 'A', 'Nuevo')
	WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

SELECT * FROM mergeDestino;

