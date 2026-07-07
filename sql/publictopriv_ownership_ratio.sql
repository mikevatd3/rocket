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
            taxpayer_1 ILIKE '%CITY OF DETROIT%'
            OR taxpayer_1 ILIKE '%DETROIT LAND BANK%'
            OR taxpayer_1 ILIKE '%STATE OF MICHIGAN%'
            OR taxpayer_1 ILIKE '%WAYNE COUNTY%'
            OR taxpayer_1 ILIKE '%UNITED STATES%'
            OR taxpayer_1 ILIKE '%HOUSING COMMISSION%'
        ) AS is_public_owner
    FROM boundary_assessors
)
SELECT
    study_area,
    EXTRACT(YEAR FROM start_date) AS record_year,
    COUNT(*) FILTER (WHERE is_public_owner) AS num_public,
    COUNT(*) FILTER (WHERE NOT is_public_owner) AS num_private,
    ROUND(
        COUNT(*) FILTER (WHERE is_public_owner)::NUMERIC
        / GREATEST(COUNT(*) FILTER (WHERE NOT is_public_owner), 1), 4
    ) AS public_to_private_ratio
FROM tagged
GROUP BY 1, 2
ORDER BY 1, 2;
