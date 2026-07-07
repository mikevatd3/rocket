WITH geo_blight AS (
    SELECT
        bv."Ticket ID",
        bv."Parcel ID",
        bv."Address",
        bv."Ordinance Law",
        bv."Ordinance Description",
        bv."Disposition",
        bv."Fine Amount",
        bv."Balance Due",
        bv."Payment Status",
        bv."Ticket Issued Date"::DATE AS issued_date,
        EXTRACT(YEAR FROM bv."Ticket Issued Date"::DATE) AS violation_year,
        CASE
            WHEN bv."Ticket Issued Date"::DATE < '2015-01-01'                              THEN 'Pre-Investment (2010-2015)'
            WHEN bv."Ticket Issued Date"::DATE BETWEEN '2015-01-01' AND '2022-12-31'       THEN 'Investment Period (2015-2023)'
            WHEN bv."Ticket Issued Date"::DATE >= '2023-01-01'                             THEN 'Post-Investment (2023+)'
        END AS investment_period,
        aljoy.name AS study_area
    FROM raw.detodp_blight_violations_20260131 bv
    JOIN rocket.alpine_joy_study_areas aljoy
        ON ST_WITHIN(
            ST_TRANSFORM(ST_SETSRID(ST_MAKEPOINT(bv."Longitude", bv."Latitude"), 4326), 2898),
            aljoy.geometry
        )
    WHERE bv."Ticket Issued Date"::DATE >= '2010-01-01'
)

SELECT
    study_area,
    investment_period,
    violation_year,
    "Ordinance Description",
    COUNT(*)                                                    AS violation_count,
    COUNT(DISTINCT "Parcel ID")                                 AS parcels_affected,
    COUNT(*) FILTER (WHERE "Payment Status" = 'Paid')           AS paid_count,
    COUNT(*) FILTER (WHERE "Disposition" ILIKE '%responsible%') AS found_responsible,
    ROUND(AVG("Fine Amount"::NUMERIC), 2)                       AS avg_fine,
    SUM("Fine Amount"::NUMERIC)                                 AS total_fines,
    SUM("Balance Due"::NUMERIC)                                 AS total_balance_due
FROM geo_blight
GROUP BY
    study_area,
    investment_period,
    violation_year,
    "Ordinance Description"
ORDER BY
    study_area,
    violation_year,
    violation_count DESC;
