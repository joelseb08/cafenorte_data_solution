CREATE SCHEMA IF NOT EXISTS exchange_rates;
SET search_path TO exchange_rates;

CREATE TABLE IF NOT EXISTS currencies (
    id SMALLINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code CHAR(3) NOT NULL,
    name VARCHAR(50) DEFAULT NULL
);

INSERT INTO currencies (code, name) VALUES
('MXN', 'Peso mexicano'),
('USD', 'Dólar estadounidense'),
('EUR', 'Euro');

CREATE TABLE IF NOT EXISTS rates (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    fecha DATE NOT NULL,
    currency_id SMALLINT NOT NULL REFERENCES currencies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    rate_to_mxn DECIMAL(10, 4) NOT NULL
);