
-- hola el enunciado del sprint 4 nivel 2 ejercicio 1, debe ser:

-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en: si les tres últimes transaccions 
-- han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:...

DROP TABLE IF EXISTS company;

# =========================================================
# NIVEL 1
# =========================================================

# Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga, 
# al menos 4 tablas de las que puedas realizar las siguientes consultas:

-- crear base de datos:
CREATE DATABASE transactions_sprint4;
USE trannsactions_sprint4;

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

USE transactions_sprint4;

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

-- Mirar: rresolver el problema: /usr/local/mysql/data - busco la carpeta y ahi ubico los rchivos csv.


# Ejercicio 1
# Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.


# Ejercicio 2
# Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.


