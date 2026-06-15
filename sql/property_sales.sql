SELECT 
    ajsa.name, 
    EXTRACT(YEAR FROM sale_date::DATE) AS year,
    COUNT(*) AS all_transactions,
    MIN(avg.avg_parcel_price),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg.avg_parcel_price) AS q25,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg.avg_parcel_price) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg.avg_parcel_price) AS q75,
    MAX(avg.avg_parcel_price),
    ROUND(100.0 * (COUNT(*) FILTER (WHERE main.taxpayer_state <> 'MI')) / COUNT(*), 2) AS out_of_state,
    ROUND(100.0 * (COUNT(*) FILTER (WHERE pre.grantor_category = 1)) / COUNT(*), 2) AS company_seller,
    ROUND(100.0 * (COUNT(*) FILTER (WHERE pre.grantee_category = 1)) / COUNT(*), 2) AS company_purchaser,
    COUNT(*) FILTER (WHERE LEFT(asr.term_of_sale, 2) IN ('19', '20')) AS multi_parcel,
    COUNT(*) FILTER (WHERE avg_parcel_price > 150) AS paid_for
FROM rocket.detroit_assessors_sales asr
JOIN rod.main_assessors main
    ON asr.parcel_id = main.parcel_id
    AND asr.sale_date::DATE > main.start_date
    AND asr.sale_date::DATE <= main.end_date
JOIN rocket.alpine_joy_study_areas ajsa
    ON ST_WITHIN(ST_TRANSFORM(main.geometry, 2898), ajsa.geometry)
JOIN rocket.assessors_sales_avg avg
    ON avg.parcel_id = asr.parcel_id
    AND avg.sale_id = asr.sale_id
JOIN rocket.sales_parties_predicted pre
    ON pre.sale_id = asr.sale_id
WHERE asr.grantor <> 'DETROIT LAND BANK AUTHORITY'
-- TODO Add more filtering?
GROUP BY 1, 2
ORDER BY 1, 2;
