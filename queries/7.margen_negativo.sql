SET search_path TO inventory;

DROP VIEW IF EXISTS margen_negativo;

CREATE VIEW margen_negativo AS
    WITH ultimo_costo AS (
        SELECT 
            t.sku_erp,
            t.costo_mxn
        FROM (
            SELECT 
                cprov.sku_erp,
                cprov.costo_mxn,
                ROW_NUMBER() OVER (PARTITION BY cprov.sku_erp ORDER BY cprov.fecha_vigencia DESC) AS rn
            FROM inventory.catalogo_proveedores cprov
        ) t
        WHERE t.rn = 1
    ),
    ventas_con_margen AS (
        SELECT 
            pos.tienda_id,
            pos.sku,
            pos.cantidad,
            pos.monto AS ingreso_venta,
            (pos.cantidad * uc.costo_mxn) AS costo_total,
            pos.monto - (pos.cantidad * uc.costo_mxn) AS margen_bruto
        FROM sales.points_of_sale pos
        INNER JOIN ultimo_costo uc ON uc.sku_erp = pos.sku
    )
    SELECT 
        tinf.tienda_id AS codigo_tienda,
        tinf.ciudad,
        tinf.region,
        skum.handle AS producto,
        SUM(v.cantidad) AS unidades_vendidas,
        ROUND(SUM(v.ingreso_venta), 2) AS ingreso_total,
        ROUND(SUM(v.costo_total), 2) AS costo_total,
        ROUND(SUM(v.margen_bruto), 2) AS perdida_total_monto,
        ROUND((SUM(v.margen_bruto) / NULLIF(SUM(v.ingreso_venta), 0)) * 100, 2) AS margen_porcentaje
    FROM ventas_con_margen v
    INNER JOIN inventory.tiendas_info tinf ON tinf.id = v.tienda_id
    INNER JOIN inventory.sku_mappings skum ON skum.id = v.sku
    GROUP BY tinf.tienda_id, tinf.ciudad, tinf.region, skum.handle
    HAVING SUM(v.margen_bruto) < 0
    ORDER BY perdida_total_monto ASC;