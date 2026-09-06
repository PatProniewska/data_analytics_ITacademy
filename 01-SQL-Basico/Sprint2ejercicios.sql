# NIVEL 1 Ejercicio 2 (JOIN)

# Listado de los países que están realizando compras. 

SELECT DISTINCT company.country 
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
ORDER BY company.country ASC;

# Desde cuántos países se realizan las compras. 

SELECT COUNT(DISTINCT company.country) as numero_paises 
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0;

# Identifica a la compañía con la mayor media de ventas.

SELECT company.company_name, company_id, ROUND(AVG(transaction.amount), 2) as media_de_ventas
FROM company
JOIN transaction
ON company.id = transaction.company_id
GROUP BY company.id
ORDER BY media_de_ventas DESC
LIMIT 1;

# NIVEL 1 Ejercicio 3 (SUBQUERY)

# Muestra todas las transacciones realizadas por empresas de Alemania. (EXISTS --->> SUBQUERY CORELACIONADA/ MIRAR)

SELECT *
FROM transaction
WHERE transaction.company_id IN (
	SELECT company.id
    FROM company
    WHERE company.country = 'Germany')
ORDER BY transaction.amount DESC;

SELECT *
FROM transaction
WHERE EXISTS (
    SELECT transaction.id
    FROM company
    WHERE company.id = transaction.company_id
      AND company.country = 'Germany');

# Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT company.company_name, company.id
FROM company
WHERE company.id IN (
	SELECT transaction.company_id
	FROM transaction
    WHERE declined = 0
    AND transaction.amount > (SELECT AVG(amount) FROM transaction))
ORDER BY company.company_name ASC;

-- DISTINCT  no es necesario porque IN - solo lo incluye una vez?

# Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.

SELECT DISTINCT company.company_name
FROM company
WHERE company.id NOT IN (
	SELECT DISTINCT transaction.company_id
    FROM transaction
    WHERE transaction.company_id IS NOT NULL);

-- Todas las empresas en la base de datos tienen transacciones registradas.

# NIVEL 2

# Ejercicio 1 - Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
# Muestra la fecha de cada transacción junto con el total de las ventas.    

SELECT DATE(transaction.timestamp) as fecha_venta, SUM(transaction.amount) as total_ventas
FROM transaction
GROUP BY fecha_venta
ORDER BY total_ventas DESC
LIMIT 5;

# Ejercicio 2 - ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio. (ROUND)

SELECT company.country, ROUND(AVG(transaction.amount), 2) as media_de_ventas
FROM company
JOIN transaction
ON company.id = transaction.company_id
GROUP BY company.country
ORDER BY media_de_ventas DESC;

# Ejercicio 3
# En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. 
# Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.

# Muestra el listado aplicando JOIN y subconsultas.

SELECT *
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE company.country IN (
	SELECT company.country
    FROM company
    WHERE company.company_name = 'Non Institute')
ORDER BY transaction.timestamp DESC;

# Muestra el listado aplicando solo subconsultas.

SELECT *
FROM transaction
WHERE transaction.company_id IN (
    SELECT company.id
    FROM company
    ## lista de transacciones hecha por companias solo con ID (Subquery 1)
    ## abajo: cuales pais esta igual que el pais de Non Institute (Subquery 2 dentro de Subquery 1)
    WHERE company.country = (
        SELECT company.country
        FROM company
        WHERE company.company_name = 'Non Institute'))
ORDER BY transaction.timestamp DESC;


# NIVEL 3

# Ejercicio 1
# Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 100 y 200 euros 
# y en alguna de estas fechas: 29 de abril de 2021, 20 de julio de 2021 y 13 de marzo de 2022. Ordena los resultados de mayor a menor cantidad.

SELECT company.company_name, company.phone, company.country, DATE(transaction.timestamp) as date, transaction.amount
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE transaction.amount BETWEEN 350 AND 400
AND DATE(transaction.timestamp) IN ('2015-04-29','2018-07-20','2024-03-13')
ORDER BY transaction.amount DESC;

# Ejercicio 2
# Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, 
# por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, 
# pero el departamento de recursos humanos es exigente y quiere un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.


SELECT company.company_name, company.id, COUNT(transaction.id) as numero_transacciones,
   CASE 
        WHEN COUNT(transaction.id) > 4 THEN 'Más de 400'
        ELSE '400 o menos'
    END AS categoria_transacciones
FROM company
JOIN transaction
ON company.id = transaction.company_id
GROUP BY company.id
ORDER BY company.company_name ASC;

-- He utilizado funcion: CASE statement - condicional.
