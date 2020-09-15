INSERT INTO customer(customer_num, fname, lname) VALUES(1258, 'Jorge', 'Gomez')
DELETE FROM customer WHERE customer_num = 1258

-- Si hiciese
DELETE FROM customer -- SIN WHERE

-- No rompe porque hay referencias en otra tabla.