WITH geo_blight AS (
    SELECT
        bv."Parcel ID",
        bv."Address",
        bv."Ticket ID",
        bv."Ordinance Description",
        bv."Ticket Issued Date"::DATE   AS issued_date,
        bv."Fine Amount",
        bv."Balance Due",
        bv."Payment Status",
        aljoy.name                      AS study_area
    FROM raw.detodp_blight_violations_20260131 bv
    JOIN rocket.alpine_joy_study_areas aljoy
        ON ST_WITHIN(
            ST_TRANSFORM(ST_SETSRID(ST_MAKEPOINT(bv."Longitude", bv."Latitude"), 4326), 2898),
            aljoy.geometry
        )
    WHERE bv."Ticket Issued Date"::DATE >= '2010-01-01'
),

chronic_parcels AS (
    SELECT
        "Parcel ID",
        "Address",
        study_area,
        COUNT(*)                                                            AS total_violations,
        COUNT(*) FILTER (WHERE issued_date < '2015-01-01')                 AS pre_invest_violations,
        COUNT(*) FILTER (WHERE issued_date BETWEEN '2015-01-01'
                                               AND '2022-12-31')           AS during_invest_violations,
        COUNT(*) FILTER (WHERE issued_date >= '2023-01-01')                AS post_invest_violations,
        MIN(issued_date)                                                    AS first_violation_date,
        MAX(issued_date)                                                    AS last_violation_date,
        MAX(issued_date) - MIN(issued_date)                                 AS violation_span_days,
        SUM("Fine Amount"::NUMERIC)                                         AS total_fines,
        SUM("Balance Due"::NUMERIC)                                         AS total_balance_due,
        COUNT(*) FILTER (WHERE "Payment Status" = 'Paid')                  AS paid_violations,
        STRING_AGG(DISTINCT "Ordinance Description", ' | ')                AS violation_types
    FROM geo_blight
    GROUP BY "Parcel ID", "Address", study_area
    HAVING COUNT(*) >= 3
),

-- most recent owner and land use per parcel
current_parcel_context AS (
    SELECT DISTINCT ON (ma.parcel_id)
        ma.parcel_id,
        ma.taxpayer_1               AS current_owner,
        ma.naive_name_dedupe        AS owner_dedupe,
        ma.taxpayer_city,
        ma.taxpayer_state,
        ma.use_code,
        ma.is_improved,
        ma.num_buildings,
        uc.description              AS use_code_description
    FROM rod.main_assessors ma
    LEFT JOIN public.p_use_codes uc
        ON ma.use_code = uc.use_code
    ORDER BY ma.parcel_id, ma.start_date DESC
)

SELECT
    cp."Parcel ID" AS parcel_id,
    cp."Address" AS address,
    cp.study_area,
    cp.total_violations,
    cp.pre_invest_violations,
    cp.during_invest_violations,
    cp.post_invest_violations,
    cp.first_violation_date,
    cp.last_violation_date,
    cp.violation_span_days,
    cp.total_fines,
    cp.total_balance_due,
    cp.paid_violations,
    ROUND(cp.paid_violations::NUMERIC / NULLIF(cp.total_violations, 0) * 100, 1) AS pct_paid,
    cp.violation_types,
    cpc.current_owner,
    cpc.owner_dedupe,
    cpc.taxpayer_city,
    cpc.taxpayer_state,
    cpc.use_code_description,
    cpc.is_improved,
    cpc.num_buildings
FROM chronic_parcels cp
LEFT JOIN current_parcel_context cpc
    ON cp."Parcel ID" = cpc.parcel_id
ORDER BY
    cp.study_area,
    cp.total_violations DESC;
