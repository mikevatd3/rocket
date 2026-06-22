WITH boundary_assessors AS (
    SELECT
        ma.*,
        aljoy.name AS study_area
    FROM rod.main_assessors AS ma
    JOIN rocket.alpine_joy_study_areas AS aljoy
        ON ST_WITHIN(ST_CENTROID(ST_TRANSFORM(ma.geometry, 2898)), aljoy.geometry)
    WHERE aljoy.name IN ('Original Boundaries','1-Mile Buffer', '1/4-Mile Buffer')
),
as_of_2015 AS (
    SELECT
        study_area,
        parcel_id,
        use_code AS use_code_2015
    FROM boundary_assessors
    WHERE start_date = DATE '2015-01-01'
),
as_of_current AS (
    SELECT
        study_area,
        parcel_id,
        use_code AS use_code_current
    FROM boundary_assessors
    WHERE start_date = DATE '2025-01-01'
)
SELECT
    a.study_area,
    a.use_code_2015,
    uc15.description AS use_code_2015_description,
    c.use_code_current,
    ucc.description AS use_code_current_description,
    COUNT(*) AS num_parcels
FROM as_of_2015 a
JOIN as_of_current c
    USING (parcel_id, study_area)
LEFT JOIN public.p_use_codes uc15
    ON a.use_code_2015 = uc15.use_code
LEFT JOIN public.p_use_codes ucc
    ON c.use_code_current = ucc.use_code
GROUP BY
    a.study_area,
    a.use_code_2015,
    uc15.description,
    c.use_code_current,
    ucc.description
ORDER BY
    a.study_area,
    num_parcels DESC;
