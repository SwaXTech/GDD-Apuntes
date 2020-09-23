SELECT 
	c2.lname + ', ' + c2.fname AS Padrino,
	c1.lname + ', ' + c1.fname AS Referido

FROM customer c1 JOIN customer c2
	ON c1.customer_num_referedBy = c2.customer_num