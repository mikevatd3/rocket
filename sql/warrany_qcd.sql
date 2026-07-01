SELECT *
FROM rod.documents d
JOIN rod.properties p ON d.instrument_no = p.instrument_no
JOIN rod.main_assessors ma 
    ON p.parcel_id = ma.parcel_id
    AND d.date_received > ma.start_date
    AND d.date_received < ma.end_date
JOIN rocket.alpine_joy_study_areas sas
    ON ST_WITHIN(ST_TRANSFORM(ma.geometry, 2898), sas.geometry)
WHERE document_type IN ('ALC', 'LC', 'LCM', 'IC')
ORDER BY sas.name;
