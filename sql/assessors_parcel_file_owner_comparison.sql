-- This query uses a combination of all the parcel files from 2008-2025 and 
-- looks at the count of parcels where the taxpayer address equals the parcel 
-- address. This isn't a perfect measure of owner occupied, but provides a look
-- at who owns parcels the area.

WITH inside_alpine_joy AS (
    SELECT *
    FROM rod.main_assessors ma
    JOIN rocket.alpine_joy_study_areas ajsa
        ON ST_WITHIN(
            ST_TRANSFORM(ma.geometry, 2898), 
            ST_TRANSFORM(ajsa.geometry, 2898)
        )
    WHERE 
        ajsa.name = 'Original Boundaries'
)
SELECT
    l.start_date,
    COUNT(*) AS total_parcels, 
    COUNT(*) FILTER (WHERE l.taxpayer_address = l.address) AS owner_occupied,
    COUNT(*) FILTER (WHERE l.taxpayer_address <> l.address) AS diff_address,
    COUNT(*) FILTER (WHERE r.address IS NOT NULL) AS diff_address_alipine_joy
FROM inside_alpine_joy l
LEFT JOIN inside_alpine_joy r
    ON l.taxpayer_address = r.address
    AND l.start_date = r.start_date
GROUP BY l.start_date;
