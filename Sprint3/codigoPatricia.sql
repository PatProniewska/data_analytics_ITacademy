# =========================================================
# NIVEL 1
# =========================================================

# Ejercicio 1
# Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. 
# las otras dos tablas ("transaction" y "company"). Después de crear la tabla será necesario que ingreses la información 
# del documento denominado "datos_introducir_credit". Recuerda mostrar el diagrama y realizar una breve descripción del mismo.

-- Creación de la tabla credit_card
CREATE TABLE credit_card(
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(34) NOT NULL,
    pan VARCHAR(25) NOT NULL,
    pin CHAR(4) NOT NULL,
    cvv CHAR(3),
    expiring_date VARCHAR(10) NOT NULL
);

-- Creación de las relaciones entre las tablas
ALTER TABLE transaction
ADD CONSTRAINT FK_transaction_creditcard
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

ALTER TABLE transaction
ADD CONSTRAINT FK_Transaction_Company
FOREIGN KEY (company_id) 
REFERENCES company(id);

-- Consulta para comprobar la tabla
SELECT *
FROM credit_card;

# Ejercicio 2
# El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. 
# La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.

UPDATE credit_card
SET credit_card.iban = 'TR323456312213576817699999'
WHERE credit_card.id = 'CcU-2938';

SELECT *
FROM credit_card
WHERE credit_card.id = 'CcU-2938';

# Ejercicio 3
#. En la tabla "transaction" ingresa una nueva transacción con la siguiente información:

-- 1. Comprobar si existen los registros de la tarjeta y la empresa
SELECT * FROM credit_card WHERE id = 'CcU-9999';
SELECT * FROM company WHERE id = 'b-9999';

-- 2. Crear la empresa asociada a la transacción (si no existe - como en nuestro caso)
INSERT INTO company (id, company_name, phone, email, country, website)
VALUES ('b-9999', 'Test Company', '000000000', 'test@test.com', 'Spain', 'www.test.com');

-- 3. Crear la tarjeta de crédito de la transacción (si no existe - como en nuestro caso)
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ('CcU-9999', 'TEST123456789', '9999888877776666', '1234', '999', '12/30/30');

-- 4. Insertar la nueva transacción en la tabla "transaction"
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

SELECT *
FROM transaction
WHERE transaction.id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

# Ejercicio 4
# Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.

ALTER TABLE credit_card
DROP COLUMN pan;

DESCRIBE credit_card;

# =========================================================
# NIVEL 2
# =========================================================

# Ejercicio 1
# Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.

DELETE from transaction
where id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

# Ejercicio 2
# La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
# Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. 
# Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: 
# Nombre de la compañía. Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía. 
# Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.

CREATE OR REPLACE VIEW vista_marketing AS
SELECT 
	company.company_name AS nombre_compania, 
	company.phone AS telefono, 
    company.country AS pais, 
    AVG(amount) AS promedio_compra
FROM company
JOIN transaction
ON company.id = transaction.company_id
GROUP BY company.id, company_name
ORDER BY AVG(amount) DESC;

SELECT *
FROM vista_marketing;

# Ejercicio 3
# Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"

SELECT *
FROM vista_marketing
WHERE vista_marketing.pais = 'Germany'
ORDER BY nombre_compania ASC;

# =========================================================
# NIVEL 2
# =========================================================

# Ejercicio 1
# La próxima semana tendrás una nueva reunión con los gerentes de marketing. 
# Un compañero de tu equipo realizó modificaciones en la base de datos, pero no recuerda cómo las realizó. 
# Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama.

-- 1. Crear la tabla "user":

CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- 2. Comprobar y modificar el tipo de datos de transaction.user_id (FK).
-- Columnas: transaction.user_id y user.id, deben tener el mismo tipo de dato como el el diagrama: (CHAR(10)) 
-- para que la relación FK funcione correctamente. 

ALTER TABLE transaction
MODIFY COLUMN user_id CHAR(10);

-- 3. Abrir el archivo "datos introducir sprint3 user.sql"
-- Insertar los datos del archivo “datos_introducir_user.sql” y comprobar el resultado:

SELECT *
FROM user;

-- 4. Preparar los datos para crear las relacion (FK) entre tablas:

-- Comprobar si hay usuarios que existen en tabla TRANSACTION y no existan en tabla USER

SELECT DISTINCT user_id
FROM transaction
WHERE user_id IS NOT NULL
AND user_id NOT IN (SELECT id FROM user);

-- Añadir los datos de. prueba de usuario que faltaba:

INSERT INTO user (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
VALUES ('9999', 'testname', 'testsurname', '000000000', 'user@test.com', '2001-01-01', 'Spain', 'Barcelona', '08000', 'Poblenou Street 123');

-- 5. Crear relacion (FK) entre las tablas (después de crear el usuario que faltaba, podemos establecer la FK sin errores.):

ALTER TABLE transaction
ADD CONSTRAINT FK_Transaction_user
FOREIGN KEY (user_id) 
REFERENCES user(id);

-- 6. Visualizar datos finales:

SELECT *
FROM user;


# Ejercicio 2
# La empresa también le pide crear una vista llamada "InformeTecnico":

CREATE OR REPLACE VIEW informe_tecnico AS
SELECT 
	transaction.id AS ID_transaccion, 
    user.name AS Nombre_usuario,
    user.surname AS Apellido_usuario,
    credit_card.iban AS IBAN_tarjeta,
    company.company_name AS Nombre_compania
FROM transaction
JOIN user
ON transaction.user_id = user.id
JOIN credit_card
ON transaction.credit_card_id = credit_card.id
JOIN company
ON transaction.company_id = company.id
ORDER BY transaction.id DESC;

SELECT *
FROM informe_tecnico;











