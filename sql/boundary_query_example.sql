SELECT
    id, object_id, amt_sale_price, EXTRACT(DAYS FROM CURRENT_DATE - sale_date) AS days_since_sold,
    CASE WHEN is_improved = 1 THEN 'building'
         ELSE 'no_building'
    END AS vacancy, parcel_id, address, zip_code, taxpayer_1,
    taxpayer_2, taxpayer_address, taxpayer_city, taxpayer_state, taxpayer_zip_code,
    property_class, neighborhood, ST_TRANSFORM(geom, 4326)
FROM raw.detodp_assessors_20260131 das
JOIN rocket.alpine_joy_study_areas ajsa
    ON ST_WITHIN(
        ST_CENTROID(ST_TRANSFORM(das.geom, 2898)), 
        ajsa.geometry
    )
WHERE name = 'Original Boundaries';
