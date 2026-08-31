SET search_path TO sales;

DROP VIEW IF EXISTS top_skus;

CREATE VIEW top_skus AS
    WITH date_limit AS (
        SELECT MAX(fecha_hora) - INTERVAL '6 months' AS fecha_corte
        FROM sales.points_of_sale
    ),
    union_sales AS (
        SELECT
            pos.sku,
            pos.cantidad
        FROM sales.points_of_sale pos
        WHERE pos.fecha_hora >= (SELECT fecha_corte FROM date_limit)
        
        UNION ALL
        
        SELECT
            ecs.product_handle AS sku,
            ecs.cantidad
        FROM sales.ecommerce_sales ecs
        WHERE ecs.fecha >= (SELECT fecha_corte FROM date_limit)
    ),
    total_sales_6m AS (
        SELECT
            us.sku,
            SUM(us.cantidad) AS total_ventas
        FROM union_sales us
        GROUP BY us.sku
    ),
    avg_stock_6m AS (
        SELECT
            snsh.sku_erp AS sku,
            ROUND(AVG(snsh.cantidad_en_stock), 2) AS avg_stock
        FROM inventory.snapshots snsh
        WHERE snsh.fecha >= (SELECT fecha_corte FROM date_limit)
        GROUP BY snsh.sku_erp
    )
    SELECT
        skum.handle,
        ts.total_ventas,
        ast.avg_stock,
        ROUND((ts.total_ventas / NULLIF(ast.avg_stock, 0)), 2) AS rotacion_inventario
    FROM total_sales_6m ts
    INNER JOIN inventory.sku_mappings skum ON skum.id = ts.sku
    INNER JOIN avg_stock_6m ast ON ast.sku = ts.sku
    WHERE ast.avg_stock > 0
    ORDER BY rotacion_inventario DESC
    LIMIT 10;