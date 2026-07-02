SELECT fc.*, pc.geom
FROM raw.tax_foreclosures_2025 AS fc
JOIN raw.detodp_assessors_20250522 AS pc
    ON fc.parcel_id = pc.parcel_id;
