-- Output as alpine_joy_assessors_sales_20260608.csv

WITH boundary_parcels AS (
    SELECT aljoy.name AS study_area, pf.parcel_id
    FROM raw.detodp_assessors_20250522 AS pf
    JOIN rocket.alpine_joy_study_areas AS aljoy
         ON ST_INTERSECTS(ST_TRANSFORM(pf.geom, 2898), aljoy.geometry)
    WHERE pf.property_c = '401'
      AND pf.is_improve > 0 -- 509
),
investor_tagged AS (
SELECT das.sale_date::DATE,
    bp.study_area           AS study_area,
    (spp.grantee_category = 0)::INT AS individual_purchase,
    app.avg_parcel_price
FROM rocket.detroit_assessors_sales das
      JOIN rocket.assessors_sales_avg app
           ON das.sale_id = app.sale_id
               AND das.parcel_id = app.parcel_id
      JOIN boundary_parcels bp
           ON das.parcel_id = bp.parcel_id
      JOIN rocket.sales_parties_predicted spp
           ON das.sale_id = spp.sale_id
WHERE das.sale_date::DATE <= DATE '2025-12-31'
    AND app.avg_parcel_price > 100
    AND das.grantor <> 'DETROIT LAND BANK AUTHORITY'
)
    SELECT
              it.study_area,
              EXTRACT(YEAR FROM it.sale_date::DATE)                          AS year,
              COUNT(*)                                                       AS sales,
              SUM(individual_purchase)                                       AS individual_purchase,
              COUNT(*) - SUM(individual_purchase)                            AS institutional_purchase,
              1000.0 * COUNT(*)/ 509                                         AS sales_rate,
              1000.0 * SUM(individual_purchase) / 509           AS sales_rate_individ,
              1000.0 * (COUNT(*) - SUM(individual_purchase)) / 509 AS sales_rate_institu,
              MIN(avg_parcel_price)                                          AS minimum_price,
              PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY avg_parcel_price) AS five_pct,
              PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg_parcel_price) AS quarter,
              PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_parcel_price)  AS median,
              PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_parcel_price) AS three_quarter,
              PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY avg_parcel_price) AS ninetyfive_pct,
              MAX(avg_parcel_price)                                          AS maximum_price
       FROM investor_tagged it
       GROUP BY it.study_area, EXTRACT(YEAR FROM it.sale_date::DATE)
       ORDER BY it.study_area, EXTRACT(YEAR FROM it.sale_date::DATE);
