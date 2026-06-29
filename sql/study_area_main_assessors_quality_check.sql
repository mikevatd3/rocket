SELECT ma.start_date, sas.name, COUNT(*)
FROM rod.main_assessors ma 
JOIN rocket.alpine_joy_study_areas sas
    ON ST_WITHIN(ST_TRANSFORM(ma.geometry, 2898), sas.geometry)
GROUP BY 1, 2
ORDER BY 1, 2;
