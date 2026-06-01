WITH investor_tagged AS (
    SELECT
        das.sale_date,
        -- dense_rank() OVER (ORDER BY das.neighborhood) AS neighborhood,
        das.neighborhood,
        (spp.grantee_category = 0)::INT AS individual_purchase,
        -- (spc.grantor_prediction = 1)::INT AS grantor_prediction,
        avg_parcel_price
    FROM
        rocket.detroit_assessors_sales das
        -- JOIN sales_party_categories spc ON das.sale_id = spc.sale_id
        JOIN rocket.assessors_sales_avg app ON das.sale_id = app.sale_id
            AND das.parcel_id = app.parcel_id
        JOIN raw.detodp_assessors_20250522 pf ON das.parcel_id = pf.parcel_id
        JOIN rocket.sales_parties_predicted spp
            ON das.sale_id = spp.sale_id
    WHERE
        das.sale_date::DATE <= DATE '2025-12-31'
        AND avg_parcel_price > 100
        AND property_class_code = '401'
        AND is_improve > 0
        AND das.grantor <> 'DETROIT LAND BANK AUTHORITY'
        AND neighborhood IS NOT NULL
),
neighborhood_parcel_counts AS (
    SELECT neighborho AS neighborhood, COUNT(*) AS universe
    FROM raw.detodp_assessors_20250522 
    WHERE 
        property_c = '401'
        AND is_improve > 0
    GROUP BY neighborho
),
neighborhood_groups AS (
    SELECT
        it.neighborhood,
        EXTRACT(YEAR FROM sale_date::DATE) AS year,
        COUNT(*) AS sales,
        SUM(individual_purchase) AS individual_purchase, 
        MIN(avg_parcel_price) AS minimum_price,
        PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY avg_parcel_price) AS five_pct,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg_parcel_price) AS quarter,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_parcel_price) AS median,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_parcel_price) AS three_quarter,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY avg_parcel_price) AS ninetyfive_pct,
        MAX(avg_parcel_price) AS maximum_price
    FROM investor_tagged it
    GROUP BY EXTRACT(YEAR FROM sale_date::DATE), neighborhood
)
SELECT
    ng.neighborhood,
    year,
    sales,
    individual_purchase,
    sales - individual_purchase AS institutional_purchase,
    1000.0 * sales / universe AS sales_rate,
    1000.0 * individual_purchase / universe AS sales_rate_individ,
    1000.0 * (sales - individual_purchase) / universe AS sales_rate_institu,
    minimum_price,
    five_pct,
    quarter,
    median,
    three_quarter,
    ninetyfive_pct,
    maximum_price,
    universe
FROM neighborhood_groups ng
JOIN neighborhood_parcel_counts npc
    ON ng.neighborhood = npc.neighborhood;
