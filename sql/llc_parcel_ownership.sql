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
        (
            taxpayer_1 ILIKE '%LLC%'
            OR taxpayer_1 ILIKE '%L L C%'
            OR taxpayer_1 ILIKE '%L.L.C%'
            OR taxpayer_1 ILIKE '%LIMITED LIABILITY%'
        ) AS is_llc
    FROM boundary_assessors
)
SELECT
    study_area,
    EXTRACT(YEAR FROM start_date) AS record_year,
    COUNT(*) AS num_ownership_records,
    COUNT(*) FILTER (WHERE is_llc) AS num_llc_records,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE is_llc)
        / NULLIF(COUNT(*), 0),
        1
    ) AS pct_llc
FROM tagged
GROUP BY 1, 2
ORDER BY 1, 2;
