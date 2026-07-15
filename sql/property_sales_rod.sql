WITH avg_consideration AS (
    SELECT doc.instrument_no,
           MAX(consideration),
           COUNT(*),
           ROUND((MAX(consideration) / COUNT(*))::NUMERIC, 2) AS value
    FROM rod.documents doc
    JOIN rod.properties pro
        ON doc.instrument_no = pro.instrument_no
    GROUP BY 1
)
SELECT 
    ajsa.name, 
    EXTRACT(YEAR FROM doc.date_received::DATE) AS year,
    COUNT(*) AS all_transactions,
    MIN(avg.value),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg.value) AS q25,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg.value) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg.value) AS q75,
    MAX(avg.value),
    COUNT(*) FILTER (WHERE avg.value > 150) AS paid_for
FROM rod.documents doc
JOIN rod.properties pro
    ON doc.instrument_no = pro.instrument_no
JOIN avg_consideration avg
    ON doc.instrument_no = avg.instrument_no
JOIN rod.main_assessors ma
    ON pro.parcel_id = ma.parcel_id
    AND ma.start_date < doc.date_received
    AND doc.date_received <= ma.end_date
JOIN rocket.alpine_joy_study_areas ajsa
    ON ST_Within(ST_Transform(ma.geometry, 2898), ajsa.geometry)
WHERE EXTRACT(YEAR FROM doc.date_received::DATE) IN (
    2008, 2009, 2010, 2011, 2012,
    2013, 2020, 2021, 2022, 2023
)
GROUP BY 1, 2;
