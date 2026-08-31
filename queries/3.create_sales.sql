CREATE SCHEMA IF NOT EXISTS sales;
SET search_path TO sales;

CREATE TABLE IF NOT EXISTS points_of_sale (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    venta_id VARCHAR(10) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    tienda_id INT NOT NULL REFERENCES inventory.tiendas_info(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    sku INT NOT NULL REFERENCES inventory.sku_mappings(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    cantidad SMALLINT NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    moneda SMALLINT NOT NULL REFERENCES exchange_rates.currencies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    tipo_comprobante CHAR(1) NOT NULL
);

CREATE TABLE IF NOT EXISTS ecommerce_sales (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id VARCHAR(15) NOT NULL,
    fecha TIMESTAMP NOT NULL,
    product_handle INT NOT NULL REFERENCES inventory.sku_mappings(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    cantidad SMALLINT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency SMALLINT NOT NULL REFERENCES exchange_rates.currencies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    customer_name VARCHAR(120) NOT NULL,
    customer_email VARCHAR(120) NOT NULL,
    customer_rfc VARCHAR(13) DEFAULT NULL,
    shipping_city VARCHAR(150) NOT NULL,
    shipping_address VARCHAR(255) NOT NULL
);