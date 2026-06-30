SELECT 
    name, 
    ST_AREA(geometry) AS area, 
    ST_AREA(geometry) / 4773002.517285653 AS ratio_to_orig
FROM rocket.alpine_joy_study_areas sas
ORDER BY 3;
