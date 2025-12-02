
# =========================================================
# NIVEL 1
# =======================================================

# Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga, 
# al menos 4 tablas de las que puedas realizar las siguientes consultas:

-- crear base de datos:
CREATE DATABASE transactions_sprint;
USE trannsactions_sprint;

-- crear tabla 'company':
CREATE TABLE company (
  company_id VARCHAR(15) PRIMARY KEY,
  company_name VARCHAR(150),
  phone VARCHAR(15),
  email VARCHAR(100) UNIQUE,
  country VARCHAR(100),
  website VARCHAR(150)
);

-- importar datos del archivo companies.csv en la tabla company mediante el comando SQL LOAD DATA LOCAL INFILE:
LOAD DATA LOCAL INFILE '/Users/patrycjaproniewska/Documents/companies.csv'
INTO TABLE company
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(company_id, company_name, phone, email, country, website);

-- verificar:
SELECT *
FROM company;

-- crear tabla 'credit_card':
CREATE TABLE credit_card (
  id VARCHAR(20) PRIMARY KEY,
  user_id VARCHAR(20),
  iban VARCHAR(50),
  pan VARCHAR(20),
  pin VARCHAR(4),
  cvv VARCHAR(4),
  track1 VARCHAR(100),
  track2 VARCHAR(100),
  expiring_date VARCHAR(20)
);

-- importar datos del archivo companies.csv en la tabla company mediante el comando SQL LOAD DATA LOCAL INFILE:
LOAD DATA LOCAL INFILE '/Users/patrycjaproniewska/Documents/credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date);

-- verificar:
SELECT *
FROM credit_card;

-- crear tabla 'european_users'
-- he añadido la columna 'continent' para conservar la información geográfica 
-- y poder realizar posteriormente una unión (UNION) con la tabla 'american_users':
CREATE TABLE european_users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255),
    continent VARCHAR(50) DEFAULT 'Europe'
);

-- importar datos del archivo european_users.csv en la tabla european_users mediante el comando SQL LOAD DATA LOCAL INFILE:
LOAD DATA LOCAL INFILE '/Users/patrycjaproniewska/Documents/european_users.csv'
INTO TABLE european_users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

-- verificar:
SELECT * 
FROM european_users;

-- crear tabla 'american_users':
-- he añadido la columna 'continent' para conservar la información geográfica 
-- y poder realizar posteriormente una unión (UNION) con la tabla 'european_users':
CREATE TABLE american_users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255),
    continent VARCHAR(50) DEFAULT 'America'
);

-- importar datos del archivo american_users.csv en la tabla american_users
-- mediante el comando SQL LOAD DATA LOCAL INFILE:
LOAD DATA LOCAL INFILE '/Users/patrycjaproniewska/Documents/american_users.csv'
INTO TABLE american_users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

-- verificar:
SELECT * 
FROM american_users;


-- crear tabla users (union entre 2 tablas de users existentes):

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255),
    continent VARCHAR(50)
);

-- unir tablas: 'european_user' y 'american_user':
INSERT INTO users
SELECT * FROM european_users
UNION ALL
SELECT * FROM american_users;

-- verificar:
SELECT continent, COUNT(*) 
FROM users 
GROUP BY continent;

SELECT *
FROM users;


-- borrar tablas 'european_user' y 'american_user':
DROP TABLE IF EXISTS european_users;
DROP TABLE IF EXISTS american_users;

SHOW TABLES;

-- crear tabla 'transactions':
CREATE TABLE transactions (
    id VARCHAR(255) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(15),
    timestamp DATETIME,
    amount DECIMAL(10,2),
    declined TINYINT(1),
    product_ids VARCHAR(100),
    user_id INT,
    lat FLOAT,
    longitude FLOAT
);

LOAD DATA LOCAL INFILE '/Users/patrycjaproniewska/Documents/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);

SELECT *
FROM transactions;

USE transactions_sprint;

-- crear relación entre transactions y company (FK constraint)
ALTER TABLE `transactions`
ADD CONSTRAINT fk_transactions_company
FOREIGN KEY (business_id)
REFERENCES company(company_id)
ON UPDATE CASCADE;

-- crear relacion entre transactions y credit_card (FK constraint)
ALTER TABLE `transactions`
ADD CONSTRAINT fk_transactions_credit_card
FOREIGN KEY (card_id)
REFERENCES credit_card(id)
ON UPDATE CASCADE;

-- crear relación entre transactions y users
ALTER TABLE `transactions`
ADD CONSTRAINT fk_transactions_user
FOREIGN KEY (user_id)
REFERENCES users(id)
ON UPDATE CASCADE;


# Ejercicio 1
# Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.

-- Muestra a todos los usuarios con más de 80 transacciones
-- Utiliza EXISTS y alias para las tablas

SELECT u.name, u.surname, u.email
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM transactions AS t
    WHERE t.user_id = u.id
    GROUP BY t.user_id
    HAVING COUNT(t.id) > 80
);


# Ejercicio 2
# Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.

SELECT company_name
FROM company
ORDER BY company_name ASC;


SELECT cc.iban, AVG(t.amount) AS average_amount
FROM transactions AS t
JOIN credit_card AS cc 
ON t.card_id = cc.id
JOIN company AS co 
ON t.business_id = co.company_id
WHERE co.company_name = 'Donec Ltd'
GROUP BY cc.iban;


# =========================================================
# NIVEL 2
# =======================================================
-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito
-- Basado en las tres últimas transacciones:
-- Si las tres han sido declinadas → "Inactivo"
-- Si al menos una no ha sido rechazada → "Activo"

-- 1️Crear la tabla donde guardaremos el estado de cada tarjeta
CREATE TABLE credit_card_status (
    card_id VARCHAR(20) PRIMARY KEY,
    status VARCHAR(10)
);

-- Usamos una función de ventana (ROW_NUMBER()) 
-- para numerar las transacciones de cada tarjeta (card_id), 
-- ordenadas por fecha (timestamp) de más reciente a más antigua.
-- despues tendremos que hacer un filtro WHERE para. mostrar ultimas 3
SELECT t.card_id, t.declined,
ROW_NUMBER() OVER (PARTITION BY t.card_id ORDER BY t.timestamp DESC) AS ranking_transaccion
FROM transactions AS t;


-- insertamos datos con CASE/condicion & Window function:
-- ROW_NUMBER() para numerar transacciones,
-- solo las 3 últimas (WHERE numero_de_veces <= 3),
-- Agrupamos por tarjeta (GROUP BY card_id),
--  Clasificamos como “Inactivo” si las tres fueron rechazadas y “Activo” si al menos una no 

INSERT INTO credit_card_status (card_id, status)
SELECT 
    card_id,
    CASE
		WHEN COUNT(*) >= 3 AND SUM(declined) = COUNT(*) THEN 'Inactivo'
		ELSE 'Activo'
    END AS status
FROM (
	SELECT t.card_id, t.declined,
	ROW_NUMBER() OVER (PARTITION BY t.card_id ORDER BY t.timestamp DESC) AS ranking_transaccion
	FROM transactions AS t) AS ultimas_transacciones
WHERE ranking_transaccion <= 3
GROUP BY card_id;


-- relacionamos la tabla nueva con tabla credit_card:
ALTER TABLE credit_card_status
ADD CONSTRAINT fk_credit_card_status_card_id
FOREIGN KEY (card_id)
REFERENCES credit_card(id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- CASCADE automaticamente borra o camiba datos en credit_card_status
-- cuando cambian en credit_card


-- Ejercicio 1

-- ¿Cuántas tarjetas están activas?

SELECT COUNT(ccs.card_id)
FROM credit_card_status AS ccs
WHERE status = 'Activo';


# =========================================================
# NIVEL 3
# =======================================================
# Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:

CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(150),
    price DECIMAL(10,2),
    colour VARCHAR(10),
    weight DECIMAL(4,1),
    warehouse_id VARCHAR(10)
);

-- Importar los datos del CSV y eliminar el símbolo "$" de la columna price 
-- antes de insertarla en la tabla usando REPLACE(@price, '$', '').
LOAD DATA LOCAL INFILE '/Users/patrycjaproniewska/Documents/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @price, colour, weight, warehouse_id)
SET price = REPLACE(@price, '$', '');

-- ponemos $ en el nombre de la columna para mantener esta info:
ALTER TABLE products
RENAME COLUMN price TO price_$USD;

SELECT * FROM products;

-- para conectar Product con Transaction, creo una tabla intermedia:
-- transaction_product:

CREATE TABLE transaction_product (
    transaction_id VARCHAR(255),
    product_id INT,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- t.product_id - es u. texto con comas, no estan separadas: Ej.: "75, 73, 98" 
-- este proceso funciona de la siguiente manera:
-- podemos fabricar una cadena con formato JSON a partir de product_ids (funciona con STRING)
-- luego JSON_TABLE la divide/explota en filas y de estamanera podemos separar los product_id
-- Comprobar el resultado de separar los product_id de producto para que en transaction_product 
-- aparezcan una fila por cada producto:

SELECT 
    t.id AS transaction_id,
    CAST(p.product_id AS UNSIGNED) AS product_id
FROM transactions AS t,
JSON_TABLE(
    CONCAT(
        '["',
        REPLACE(REPLACE(t.product_ids, ' ', ''), ',', '","'),
        '"]'),
    '$[*]'
    COLUMNS (product_id VARCHAR(10) PATH '$')
) AS p;

-- REPLACE: Quita espacios, cambia comas por "," - 75","73","98
-- CONCAT('["', … , '"]') construye un array: una cadena de JSON / JSON string - ["75","73","98"].
-- array JSON = lista de valores entre corchetes.
-- JSON_TABLE( … , '$[*]' COLUMNS (product_id VARCHAR(10) PATH '$')) AS p: analiza esta cadena de texto 
-- para identificar su estructura sintáctica y extraer información = nos devuelve una fila por cada elemento del array.
-- la columna resultante se llama product_id donde cada elemento esta en fila separada
-- SELECT t.id AS transaction_id, CAST(p.product_id AS UNSIGNED) AS product_id
-- convierte cada product_id a número (UNSIGNED) para que funcione con FK - tabla products 
-- porducts.id es un tipo de datos INT

-- insertamos los datos en la tabla intermedia usando la función JSON_TABLE
-- CROSS JOIN combina todas las filas de una tabla con todas las filas de otra.


INSERT INTO transaction_product (transaction_id, product_id)
SELECT 
    t.id,
    CAST(p.product_id AS UNSIGNED)
FROM transactions AS t
CROSS JOIN JSON_TABLE(
    CONCAT(
        '["',
        REPLACE(REPLACE(t.product_ids, ' ', ''), ',', '","'),
        '"]'
    ),
    '$[*]'
    COLUMNS (
        product_id VARCHAR(10) PATH '$'
    )
) AS p;

-- visualizamos la tabla nueva con datos insertados:
SELECT *
FROM transaction_product;

-- Ahora podemos relacionar las tablas a traves de foreign key:

-- creamos la relación entre transaction_product y transactions
ALTER TABLE transaction_product
ADD CONSTRAINT fk_transactionproduct_transaction
FOREIGN KEY (transaction_id) REFERENCES transactions(id)
ON DELETE CASCADE;

-- creamos la relación entre transaction_product y products
ALTER TABLE transaction_product
ADD CONSTRAINT fk_transactionproduct_product
FOREIGN KEY (product_id) REFERENCES products(id)
ON DELETE CASCADE;

-- definimos los dos campos como PK (clave compuesta y FK a la vez)
ALTER TABLE transaction_product
ADD PRIMARY KEY (transaction_id, product_id);

# Ejercicio 1
# Necesitamos conocer el número de veces que se ha vendido cada producto.

SELECT 
    p.product_name, p.id AS product_id,
    COUNT(tp.product_id) AS veces_vendido
FROM products AS p
JOIN transaction_product AS tp
    ON p.id = tp.product_id
JOIN transactions AS t
ON t.id = tp.transaction_id
WHERE t.declined = 0
GROUP BY p.product_name, p.id
ORDER BY veces_vendido DESC;

