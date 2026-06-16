WITH study_parcels AS (
    SELECT das.*, mas.geometry
    FROM rocket.detroit_assessors_sales das
    JOIN rod.main_assessors mas
        ON das.parcel_id = mas.parcel_id
        AND das.sale_date::DATE > mas.start_date
        AND das.sale_date::DATE <= mas.end_date
    JOIN rocket.alpine_joy_study_areas ajsa
        ON ST_WITHIN(st_transform(mas.geometry, 2898), ajsa.geometry)
    WHERE ajsa.name = 'Original Boundaries'
),
transaction_window_counts AS (
    SELECT grantor,
           sale_date,
           COUNT(*) OVER (
                PARTITION BY grantor
                ORDER BY sale_date::DATE
                RANGE BETWEEN INTERVAL '1 year' PRECEDING AND CURRENT ROW
           ) AS transaction_within_year
    FROM study_parcels
    ORDER BY 3 DESC
)
SELECT DISTINCT ON (grantor) grantor, sale_date, transaction_within_year
FROM transaction_window_counts
WHERE transaction_within_year >= 3
ORDER BY grantor, transaction_within_year DESC, sale_date ASC;

