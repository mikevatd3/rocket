WITH boundary_parcels AS (
    SELECT
        pf.*,
        aljoy.name AS study_area
    FROM raw.detodp_assessors_20260131 AS pf
    JOIN rocket.alpine_joy_study_areas AS aljoy
        ON ST_WITHIN(ST_CENTROID(ST_TRANSFORM(pf.geom, 2898)), aljoy.geometry)
    WHERE aljoy.name IN ('Original Boundaries', '1-Mile Buffer', '1/4-Mile Buffer')
)
SELECT
    study_area,
    property_class_description,
    use_code_description,
    COUNT(*) AS num_parcels,
    SUM(amt_assessed_value) AS total_assessed_value,
    AVG(amt_assessed_value) AS avg_assessed_value,
    AVG(amt_assessed_value - amt_assessed_value_previous) AS avg_yoy_assessed_change,
    COUNT(*) FILTER (WHERE property_class IS DISTINCT FROM property_class_previous) AS recently_reclassified,
    COUNT(*) FILTER (WHERE tax_status IS DISTINCT FROM tax_status_previous) AS recently_tax_status_changed
FROM boundary_parcels
GROUP BY 1, 2, 3
ORDER BY 1, 4 DESC;
