WITH boundary_assessors AS (
    SELECT
        ma.*,
        aljoy.name AS study_area
    FROM rod.main_assessors AS ma
    JOIN rocket.alpine_joy_study_areas AS aljoy
        ON ST_WITHIN(ST_CENTROID(ST_TRANSFORM(ma.geometry, 2898)), aljoy.geometry)
    WHERE aljoy.name IN ('Original Boundaries', '1-Mile Buffer', '1/4-Mile Buffer')
),
tagged AS (
    SELECT
        *,
        (taxpayer_state IS NOT NULL AND taxpayer_state <> 'MI') AS is_out_of_state,
        (taxpayer_city IS NOT NULL AND taxpayer_city NOT ILIKE 'DETROIT') AS is_out_of_city
    FROM boundary_assessors
)
SELECT
    study_area,
    EXTRACT(YEAR FROM start_date) AS record_year,
    COUNT(*) AS num_ownership_records,
    COUNT(*) FILTER (WHERE is_out_of_state) AS num_out_of_state,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE is_out_of_state)
        / NULLIF(COUNT(*), 0),
        1
    ) AS pct_out_of_state,
    COUNT(*) FILTER (WHERE is_out_of_city) AS num_out_of_city,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE is_out_of_city)
        / NULLIF(COUNT(*), 0),
        1
    ) AS pct_out_of_city
FROM tagged
GROUP BY 1, 2
ORDER BY 1, 2;
