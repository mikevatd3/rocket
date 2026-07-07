WITH boundary_assessors AS (
    SELECT
        ma.*,
        aljoy.name AS study_area
    FROM rod.main_assessors AS ma
    JOIN rocket.alpine_joy_study_areas AS aljoy
        ON ST_WITHIN(ST_CENTROID(ST_TRANSFORM(ma.geometry, 2898)), aljoy.geometry)
    WHERE aljoy.name IN ('Original Boundaries', '1-Mile Buffer', '1/4-Mile Buffer')
),
ownership_history AS (
    SELECT
        parcel_id,
        study_area,
        taxpayer_1,
        start_date,
        LAG(taxpayer_1) OVER (PARTITION BY parcel_id, study_area ORDER BY start_date) AS previous_owner
    FROM boundary_assessors
),
flagged AS (
    SELECT
        *,
        previous_owner IS DISTINCT FROM taxpayer_1 AND previous_owner IS NOT NULL AS ownership_changed,
        CASE WHEN start_date < DATE '2015-01-01' THEN 'pre_2015' ELSE 'post_2015' END AS period
    FROM ownership_history
)
SELECT
    study_area,
    period,
    COUNT(*) FILTER (WHERE ownership_changed) AS num_ownership_changes,
    COUNT(DISTINCT parcel_id) AS num_parcels,
    MIN(start_date) AS period_start,
    MAX(start_date) AS period_end,
    ROUND(
        COUNT(*) FILTER (WHERE ownership_changed)::NUMERIC
        / GREATEST((MAX(start_date) - MIN(start_date)) / 365.25, 1)
        / NULLIF(COUNT(DISTINCT parcel_id), 0), 4
    ) AS changes_per_parcel_per_year
FROM flagged
GROUP BY 1, 2
ORDER BY 1, 2;
