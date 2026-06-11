SELECT
    parcel_id,
    taxpayer_1,
    LAG(taxpayer_1) OVER (PARTITION BY parcel_id ORDER BY start_date) AS previous_owner
FROM rod.main_assessors;

SELECT SUM(tp::INT), parcel_id
FROM (SELECT taxpayer_1,
             parcel_id,
             start_date,
             LAG(taxpayer_1) OVER (PARTITION BY parcel_id ORDER BY start_date) <> taxpayer_1 AS tp,
                LAG(taxpayer_1) OVER (PARTITION BY parcel_id ORDER BY start_date) FROM rod.main_assessors AS assess
     JOIN rocket.alpine_joy_study_areas AS aljoy
ON
    ST_WITHIN(ST_TRANSFORM(assess.geometry, 2898), aljoy.geometry)
WHERE start_date >= '2010-01-01'
AND name = 'Original Boundaries' --785 parcels
    ) AS aggcount

GROUP BY parcel_id;

-- base table
SELECT taxpayer_1, parcel_id, start_date,
       LAG(taxpayer_1) OVER (PARTITION BY parcel_id ORDER BY start_date) <> taxpayer_1,
           LAG(taxpayer_1) OVER (PARTITION BY parcel_id ORDER BY start_date)
FROM rod.main_assessors AS assess
JOIN rocket.alpine_joy_study_areas AS aljoy ON
    ST_WITHIN(ST_TRANSFORM(assess.geometry, 2898), aljoy.geometry)
WHERE start_date >= '2010-01-01'; 
