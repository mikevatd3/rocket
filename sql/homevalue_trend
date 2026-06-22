WITH study_sales AS (
    SELECT
        das.sale_id,
        das.parcel_id,
        das.sale_date::DATE AS sale_date,
        das.property_class_description,
        (app.avg_parcel_price / NULLIF(app.parcel_count, 0)) AS corrected_price,
        aljoy.name AS study_area
    FROM rocket.detroit_assessors_sales AS das
    JOIN rocket.assessors_sales_avg AS app
        ON das.sale_id = app.sale_id
        AND das.parcel_id = app.parcel_id
    JOIN rod.main_assessors AS mas
        ON das.parcel_id = mas.parcel_id
        AND das.sale_date::DATE > mas.start_date
        AND das.sale_date::DATE <= mas.end_date
    JOIN rocket.alpine_joy_study_areas AS aljoy
        ON ST_WITHIN(ST_CENTROID(ST_TRANSFORM(mas.geometry, 2898)), aljoy.geometry)
    WHERE aljoy.name IN ('Original Boundaries', '1-Mile Buffer', '1/4-Mile Buffer')
      AND app.avg_parcel_price > 100 -- drop $0/$1 token deeds
      AND das.grantor <> 'DETROIT LAND BANK AUTHORITY'
      -- AND das.sale_verification = 'DEED' OR 'PROPERTY TRANSFER AFFIDAVIT' ??? pick at later
)
-- pre/post summary by property class
SELECT
    study_area,
    CASE WHEN sale_date < DATE '2015-01-01' THEN 'pre_2015' ELSE 'post_2015' END AS period,
    property_class_description,
    COUNT(*) AS num_sales,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY corrected_price) AS p25_price,
    PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY corrected_price) AS median_price,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY corrected_price) AS p75_price,
    AVG(corrected_price) AS avg_price
FROM study_sales
GROUP BY 1, 2, 3
ORDER BY 1, 2, 4 DESC;
