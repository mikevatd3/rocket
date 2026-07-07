WITH geo_permits AS (
    SELECT
        bp."Record ID",
        bp."Parcel ID",
        bp."Address",
        bp."Issued Date"::DATE                                  AS issued_date,
        EXTRACT(YEAR FROM bp."Issued Date"::DATE)               AS permit_year,
        bp."Permit Type",
        bp."Description of Work",
        bp."Current Building Use Type",
        bp."Proposed Building Use Type",
        bp."Is Building Vacant?",
        bp."Purchased from DLBA?",
        bp."In DLBA Compliance Program?",
        bp."Change in Units?",
        bp."Number of Units",
        bp."Contractor Estimated Cost",
        bp."Department Estimated Cost",
        CASE
            WHEN bp."Permit Type" ILIKE '%rehab%'
              OR bp."Permit Type" ILIKE '%renovation%'
              OR bp."Permit Type" ILIKE '%alteration%'
              OR bp."Description of Work" ILIKE '%rehab%'
              OR bp."Description of Work" ILIKE '%renovation%'
              OR bp."Description of Work" ILIKE '%remodel%'    THEN 'Rehab/Renovation'
            WHEN bp."Permit Type" ILIKE '%new construction%'   THEN 'New Construction'
            WHEN bp."Permit Type" ILIKE '%demo%'               THEN 'Demolition'
            ELSE 'Other'
        END AS permit_category,
        CASE
            WHEN bp."Issued Date"::DATE < '2015-01-01'                                     THEN 'Pre-Investment (2010-2015)'
            WHEN bp."Issued Date"::DATE BETWEEN '2015-01-01' AND '2022-12-31'              THEN 'Investment Period (2015-2023)'
            WHEN bp."Issued Date"::DATE >= '2023-01-01'                                    THEN 'Post-Investment (2023+)'
        END AS investment_period,
        aljoy.name AS study_area
    FROM raw.detodp_building_permits_20260202 bp
    JOIN rocket.alpine_joy_study_areas aljoy
        ON ST_WITHIN(
            ST_TRANSFORM(ST_SETSRID(ST_MAKEPOINT(bp."Longitude", bp."Latitude"), 4326), 2898),
            aljoy.geometry
        )
    WHERE bp."Issued Date"::DATE >= '2010-01-01'
),

-- most recent use_code per parcel for land use context
parcel_use AS (
    SELECT DISTINCT ON (ma.parcel_id)
        ma.parcel_id,
        ma.use_code,
        uc.description AS use_code_description
    FROM rod.main_assessors ma
    LEFT JOIN public.p_use_codes uc
        ON ma.use_code = uc.use_code
    ORDER BY ma.parcel_id, ma.start_date DESC
)

SELECT
    gp.study_area,
    gp.permit_year,
    gp.permit_category,
    pu.use_code,
    pu.use_code_description,
    COUNT(*)                                                            AS permit_count,
    COUNT(*) FILTER (WHERE gp."Is Building Vacant?" = 'Yes')           AS vacant_at_permit,
    COUNT(*) FILTER (WHERE gp."Purchased from DLBA?" = 'Yes')          AS purchased_from_dlba,
    COUNT(*) FILTER (WHERE gp."In DLBA Compliance Program?" = 'Yes')   AS in_dlba_program,
    COUNT(*) FILTER (WHERE gp."Change in Units?" = 'Yes')              AS unit_change_count,
    SUM(gp."Contractor Estimated Cost"::NUMERIC)                       AS total_contractor_cost,
    SUM(gp."Department Estimated Cost"::NUMERIC)                       AS total_dept_cost
FROM geo_permits gp
LEFT JOIN parcel_use pu
    ON gp."Parcel ID" = pu.parcel_id
GROUP BY
    gp.study_area,
    gp.permit_year,
    gp.permit_category,
    pu.use_code,
    pu.use_code_description
ORDER BY
    gp.study_area,
    gp.permit_year,
    permit_count DESC;
