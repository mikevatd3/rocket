SELECT 
    EXTRACT(YEAR FROM date_received), 
    COUNT(*) AS parcel_level,
    COUNT(*) FILTER (WHERE p.parcel_id IS NULL) AS missing_parcel_id,
    COUNT(*) FILTER (WHERE ma.parcel_id IS NOT NULL) AS successful_join
FROM rod.documents d
LEFT JOIN rod.properties p ON d.instrument_no = p.instrument_no
LEFT JOIN rod.main_assessors ma 
    ON p.parcel_id = ma.parcel_id
    AND d.date_received > ma.start_date
    AND d.date_received < ma.end_date
WHERE document_type IN ('ALC', 'LC', 'LCM', 'IC')
GROUP BY 1
ORDER BY 1;
