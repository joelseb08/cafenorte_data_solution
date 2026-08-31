SET search_path TO sales;

DROP VIEW IF EXISTS crecimiento_mom_sales;

CREATE VIEW crecimiento_mom_sales AS
    WITH date_limit AS (
        SELECT DATE_TRUNC('month', MAX(fecha_hora)) - INTERVAL '11 months' AS fecha_corte
        FROM sales.points_of_sale
    ),
    union_ventas AS (
        SELECT 
            DATE_TRUNC('month', pos.fecha_hora) AS mes,
            'Físico' AS canal,
            pos.monto AS monto_mxn
        FROM sales.points_of_sale pos
        WHERE pos.fecha_hora >= (SELECT fecha_corte FROM date_limit)

        UNION ALL

        SELECT 
            DATE_TRUNC('month', ecs.fecha) AS mes,
            'E-commerce' AS canal,
            ecs.amount * COALESCE(rts.rate_to_mxn, 1.0) AS monto_mxn
        FROM sales.ecommerce_sales ecs
        LEFT JOIN exchange_rates.rates rts ON rts.currency_id = ecs.currency AND rts.fecha = ecs.fecha::date
        WHERE ecs.fecha >= (SELECT fecha_corte FROM date_limit)
    ),
    ventas_mensuales AS (
        SELECT 
            mes,
            canal,
            SUM(monto_mxn) AS total_ventas
        FROM union_ventas
        GROUP BY mes, canal
    ),
    ventas_con_lag AS (
        SELECT 
            mes,
            canal,
            total_ventas,
            LAG(total_ventas) OVER (PARTITION BY canal ORDER BY mes) AS ventas_mes_anterior
        FROM ventas_mensuales
    )
    SELECT 
        TO_CHAR(mes, 'YYYY-MM') AS periodo_mes,
        canal,
        ROUND(total_ventas, 2) AS total_ventas_mxn,
        ROUND(COALESCE(ventas_mes_anterior, 0), 2) AS ventas_mes_anterior,
        ROUND(
            ((total_ventas - ventas_mes_anterior) / NULLIF(ventas_mes_anterior, 0)) * 100, 
            2
        ) AS crecimiento_mom_porcentaje
    FROM ventas_con_lag
    ORDER BY mes ASC, canal;