INSERT INTO customer(customer_num, fname, lname) VALUES(1258, 'Jorge', 'Gomez')
DELETE FROM customer WHERE customer_num = 1258
SELECT * FROM customer WHERE customer_num = 1258

INSERT INTO customer (fname, lname) VALUES ('Jorge', 'Gomez') -- No anda, porque customer_num debe ser NOT NULL


INSERT INTO manufact (manu_name, manu_code , lead_time, state) VALUES ('Jorge', 'JOR', 10, 'FL') -- Fecha por defecto (Hoy) y usuario de alta dbo
SELECT * FROM manufact WHERE manu_name = 'Jorge'
DELETE FROM manufact WHERE manu_name = 'Jorge'

-- Para insertarlos con valor NULL: 
INSERT INTO manufact (manu_name, manu_code , lead_time, state, f_alta_audit, d_usualta_audit) VALUES ('Jorge', 'JOR', 10, 'FL', NULL, NULL) -- Fecha por defecto (Hoy) y usuario de alta dbo
SELECT * FROM manufact WHERE manu_name = 'Jorge'




