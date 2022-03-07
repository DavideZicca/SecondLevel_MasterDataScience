# Davide Zicca - Bank DB Project
-- ------------------------------------------------
-- Creo Schema e Tabelle
-- ------------------------------------------------

CREATE SCHEMA Bank;

-- ------------------------------------------------
USE Bank;
CREATE TABLE Branch (
    id INT,
    name CHAR(50) UNIQUE,
    address CHAR(50),
    PRIMARY KEY (id)
);

-- ------------------------------------------------
USE Bank;
CREATE TABLE Card (
    id INT,
    number CHAR(50) UNIQUE,
    expiration_date DATE,
    is_blocked BOOL,
    PRIMARY KEY (id)
);


-- ------------------------------------------------
USE Bank;
CREATE TABLE Loan_type (
    id INT,
    type CHAR(50) UNIQUE,
    description CHAR(100),
    base_amount DECIMAL(10, 3),
    base_interest_rate DECIMAL(10, 3),
    PRIMARY KEY (id)
);

-- ------------------------------------------------
USE Bank;
CREATE TABLE Customer (
    id INT,
    branch_id INT,
    first_name CHAR(50),
    last_name CHAR(50),
    date_of_birth DATE,
    gender CHAR(6),
    PRIMARY KEY (id),
    FOREIGN KEY (branch_id) REFERENCES Branch(id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
);

-- ------------------------------------------------
USE Bank;
CREATE TABLE Account (
    id INT,
    customer_id INT,
    card_id INT,
    balance CHAR(50),
    PRIMARY KEY (id),
    FOREIGN KEY (customer_id) REFERENCES Customer(id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	FOREIGN KEY (card_id) REFERENCES Card(id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
);

-- ------------------------------------------------
USE Bank;
CREATE TABLE Loan (
    id INT,
    account_id INT,
    loan_type_id INT,
    amount_paid DECIMAL(10, 3),
    start_date DATE,
    due_date DATE,
    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES Account(id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	FOREIGN KEY (loan_type_id) REFERENCES Loan_type(id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
);

-- ------------------------------------------------
USE Bank;
CREATE TABLE Transaction (
    id INT,
    account_id INT,
    description CHAR(100),
    amount DECIMAL(10, 3),
    date DATE,
    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES Account(id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
);

-- ------------------------------------------------
-- Creo gli Users
-- ------------------------------------------------
CREATE USER 'mariod'@'%' IDENTIFIED BY 'password';
CREATE USER 'gallagherL'@'%' IDENTIFIED BY 'password';
CREATE USER 'batiG'@'%' IDENTIFIED BY 'password';
GRANT ALL ON *.* TO 'mariod'@'%';
GRANT ALL ON *.* TO 'gallagherL'@'%' WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON *.* TO 'batiG'@'%';
SELECT * FROM mysql.user;

SHOW GRANTS for 'batiG'@'%';

-- ------------------------------------------------
-- Creo una visualizzazione
-- ------------------------------------------------
USE Bank;
CREATE VIEW User_role_information AS
	SELECT User, Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv 
		FROM mysql.user
		WHERE Select_priv = 'Y' OR Insert_priv = 'Y' OR Update_priv = 'Y' OR Delete_priv = 'Y' OR Create_priv = 'Y'; 

-- ------------------------------------------------
-- Inserisco valori nel Database
-- ------------------------------------------------
USE Bank;
INSERT INTO Branch (id, name, address) VALUES ('1', 'Roggiano Bank', 'Roggiano');
INSERT INTO Branch (id, name, address) VALUES ('2', 'San Marco Argentano Bank', 'San Marco Argentano');
INSERT INTO Branch (id, name, address) VALUES ('3', 'Cosenza Bank', 'Cosenza');
INSERT INTO Branch (id, name, address) VALUES ('4', 'Foggia Bank', 'Foggia');
INSERT INTO Branch (id, name, address) VALUES ('5', 'Firenze Bank', 'Firenze');

-- ------------------------------------------------
USE Bank;
INSERT INTO Card (id, number, expiration_date, is_blocked) VALUES ('1', '1234567890123456', '2021-08-30', TRUE);
INSERT INTO Card (id, number, expiration_date, is_blocked) VALUES ('2', '1234567890123457', '2022-08-20', TRUE);
INSERT INTO Card (id, number, expiration_date, is_blocked) VALUES ('3', '1234567890123458', '2023-03-21', TRUE);
INSERT INTO Card (id, number, expiration_date, is_blocked) VALUES ('4', '1234567890123459', '2021-09-14', FALSE);
INSERT INTO Card (id, number, expiration_date, is_blocked) VALUES ('5', '1234567890123450', '2021-06-9', TRUE);

-- ------------------------------------------------
USE Bank;
INSERT INTO Loan_type (id, type, description, base_amount, base_interest_rate) VALUES ('1', 'Prestito Ipotecario', 'Descrizione1', 10000, 15);
INSERT INTO Loan_type (id, type, description, base_amount, base_interest_rate) VALUES ('2', 'Prestiti Auto', 'Descrizione2', 5000, 20);
INSERT INTO Loan_type (id, type, description, base_amount, base_interest_rate) VALUES ('3', 'Prestiti Personali', 'Descrizione3', 3000, 25);
INSERT INTO Loan_type (id, type, description, base_amount, base_interest_rate) VALUES ('4', 'Prestiti con Anticipo sullo Stipendio', 'Descrizione4', 1000, 50);
INSERT INTO Loan_type (id, type, description, base_amount, base_interest_rate) VALUES ('5', 'Prestiti alle Piccole e Medie Aziende', 'Descrizione5', 7000, 35);

-- ------------------------------------------------
USE Bank;
INSERT INTO Customer (id, branch_id, first_name, last_name, date_of_birth, gender) VALUES ('1', '1', 'Mario', 'Draghi', '1947-09-3', 'male');
INSERT INTO Customer (id, branch_id, first_name, last_name, date_of_birth, gender) VALUES ('2', '3', 'Matteo ', 'Renzi', '1975-01-11', 'male');
INSERT INTO Customer (id, branch_id, first_name, last_name, date_of_birth, gender) VALUES ('3', '1', 'Di Maio', 'Luigi', '1986-07-6', 'male');
INSERT INTO Customer (id, branch_id, first_name, last_name, date_of_birth, gender) VALUES ('4', '2', 'Batistuta', 'Gabriel', '1969-02-1', 'male');
INSERT INTO Customer (id, branch_id, first_name, last_name, date_of_birth, gender) VALUES ('5', '2', 'Gallagher', 'Liam', '1972-09-21', 'male');

-- ------------------------------------------------
USE Bank;
INSERT INTO Account (id, customer_id, card_id, balance) VALUES ('1', '1', '1', '100000');
INSERT INTO Account (id, customer_id, card_id, balance) VALUES ('2', '2', '2', '10000');
INSERT INTO Account (id, customer_id, card_id, balance) VALUES ('3', '3', '3', '200');
INSERT INTO Account (id, customer_id, card_id, balance) VALUES ('4', '5', '4', '500000');
INSERT INTO Account (id, customer_id, card_id, balance) VALUES ('5', '5', '5', '1000000');

-- ------------------------------------------------
USE Bank;
INSERT INTO Loan (id, account_id, loan_type_id, amount_paid, start_date, due_date) VALUES ('1', '1', '3', '0', '2020-05-18', '2023-05-18');
INSERT INTO Loan (id, account_id, loan_type_id, amount_paid, start_date, due_date) VALUES ('2', '5', '1', '0', '2019-08-12', '2021-05-25');
INSERT INTO Loan (id, account_id, loan_type_id, amount_paid, start_date, due_date) VALUES ('3', '4', '2', '100', '2019-05-13', '2024-05-14');
INSERT INTO Loan (id, account_id, loan_type_id, amount_paid, start_date, due_date) VALUES ('4', '2', '5', '1000', '2018-05-25', '2021-05-21');
INSERT INTO Loan (id, account_id, loan_type_id, amount_paid, start_date, due_date) VALUES ('5', '1', '4', '5000', '2020-05-20', '2023-05-07');

-- ------------------------------------------------
USE Bank;
INSERT INTO Transaction (id, account_id, description, amount, date) VALUES ('1', '1', 'Descrizione 100', '1000.90', '2020-05-18');
INSERT INTO Transaction (id, account_id, description, amount, date) VALUES ('2', '2', 'Descrizione 200', '500.80', '2019-12-07');
INSERT INTO Transaction (id, account_id, description, amount, date) VALUES ('3', '5', 'Descrizione 300', '100.90', '2018-06-30');
INSERT INTO Transaction (id, account_id, description, amount, date) VALUES ('4', '5', 'Descrizione 400', '5060.7', '2020-01-24');
INSERT INTO Transaction (id, account_id, description, amount, date) VALUES ('5', '5', 'Descrizione 500', '500.67', '2018-01-24');

-- ------------------------------------------------
-- Verifica che ogni account abbia un saldo minimo di disponibilità di denaro in ogni momento.
-- ------------------------------------------------
USE Bank;
delimiter //
CREATE TRIGGER bal_limit_insert BEFORE INSERT ON Account FOR EACH ROW
    BEGIN
		DECLARE message varchar(50);
		IF NEW.balance < 100 THEN
			SET message= CONCAT('Errore di inserimento: nuovo saldo troppo basso: ', NEW.balance);
			SIGNAL SQLSTATE '46000'
            SET MESSAGE_TEXT = message;
		END IF;
	END;
//

CREATE TRIGGER bal_limit_update BEFORE UPDATE ON Account FOR EACH ROW
    BEGIN
		DECLARE message varchar(50);
		IF NEW.balance < 100 THEN
			SET message= CONCAT('Errore di update: nuovo saldo troppo basso: ', NEW.balance);
			SIGNAL SQLSTATE '46000'
            SET MESSAGE_TEXT = message;
		END IF;
	END;
//
delimiter ;

-- ------------------------------------------------
-- 
-- ------------------------------------------------
-- 1.	Numero di clienti che hanno un account in due o più filiali.
-- ------------------------------------------------
USE Bank;

SELECT c.first_name, c.last_name 
	FROM Customer c
	WHERE c.id IN (SELECT customer_id
		FROM Customer_Branch cb
        GROUP BY customer_id
        HAVING COUNT(*) >= 2);


-- ------------------------------------------------
-- 2. 	Alla fine di ogni anno, un documento attestante tutti i movimenti è generato per ogni account.
-- ------------------------------------------------
CREATE EVENT IF NOT EXISTS Account_transactions_every_year
ON SCHEDULE AT '2021-12-31' + INTERVAL 1 year 
	DO SELECT * 
	FROM Transaction t

-- ------------------------------------------------
-- 3.	Cerca clienti che non hanno account aperti.
-- ------------------------------------------------
USE Bank;
SELECT c.first_name, c.last_name 
	FROM Customer c
	WHERE c.id NOT IN (SELECT customer_id
		FROM Account cb
        GROUP BY customer_id);   

-- ------------------------------------------------
-- 		   --- Fine ---
-- ------------------------------------------------
DROP DATABASE Bank;