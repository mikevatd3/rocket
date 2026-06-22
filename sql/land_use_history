WITH boundary_assessors AS (
    SELECT
        ma.*,
        aljoy.name AS study_area
    FROM rod.main_assessors AS ma
    JOIN rocket.alpine_joy_study_areas AS aljoy
        ON ST_WITHIN(ST_CENTROID(ST_TRANSFORM(ma.geometry, 2898)), aljoy.geometry)
    WHERE aljoy.name IN ('Original Boundaries', '1-Mile Buffer', '1/4-Mile Buffer')
),
use_code_history AS (
    SELECT
        parcel_id,
        study_area,
        use_code,
        start_date,
        LAG(use_code) OVER (PARTITION BY parcel_id, study_area ORDER BY start_date) AS previous_use_code
    FROM boundary_assessors
)
SELECT
    study_area,
    CASE WHEN start_date < DATE '2015-01-01' THEN 'pre_2015' ELSE 'post_2015' END AS period,
    COUNT(*) FILTER (WHERE previous_use_code IS DISTINCT FROM use_code
                      AND previous_use_code IS NOT NULL) AS num_use_code_changes,
    COUNT(DISTINCT parcel_id) AS num_parcels,
    ROUND(
        COUNT(*) FILTER (WHERE previous_use_code IS DISTINCT FROM use_code
                          AND previous_use_code IS NOT NULL)::NUMERIC
        / NULLIF(COUNT(DISTINCT parcel_id), 0), 4
    ) AS changes_per_parcel
FROM use_code_history
GROUP BY 1, 2
ORDER BY 1, 2;
