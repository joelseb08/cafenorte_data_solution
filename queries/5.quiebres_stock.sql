SET search_path TO inventory;

DROP VIEW IF EXISTS quiebres_stock;

CREATE VIEW quiebres_stock AS
    WITH date_limit AS (
        SELECT MAX(fecha) - INTERVAL '3 months' AS fecha_corte
        FROM inventory.snapshots
    ),
    dias_en_cero AS (
        SELECT 
            snsh.tienda_id,
            snsh.sku_erp,
            snsh.fecha,
            snsh.fecha - (ROW_NUMBER() OVER (PARTITION BY snsh.tienda_id, snsh.sku_erp ORDER BY snsh.fecha) * INTERVAL '1 day') AS racha_id
        FROM inventory.snapshots snsh
        WHERE snsh.cantidad_en_stock = 0 AND snsh.fecha >= (SELECT fecha_corte FROM date_limit)
    ),
    quiebres_consecutivos AS (
        SELECT 
            tienda_id,
            sku_erp,
            COUNT(*) AS dias_consecutivos,
            MIN(fecha) AS fecha_inicio_quiebre,
            MAX(fecha) AS fecha_fin_quiebre
        FROM dias_en_cero
        GROUP BY tienda_id, sku_erp, racha_id
        HAVING COUNT(*) > 3
    )
    SELECT 
        tinf.tienda_id AS codigo_tienda,
        tinf.ciudad,
        tinf.region,
        skum.sku_erp,
        qc.dias_consecutivos,
        qc.fecha_inicio_quiebre,
        qc.fecha_fin_quiebre
    FROM quiebres_consecutivos qc
    INNER JOIN inventory.tiendas_info tinf ON tinf.id = qc.tienda_id
    INNER JOIN inventory.sku_mappings skum ON skum.id = qc.sku_erp
    ORDER BY qc.dias_consecutivos DESC, tinf.tienda_id;