WITH detroit_boundary AS (
  SELECT *
  FROM etl.geographies
  WHERE geoid = '2616322000'
  LIMIT 1  
),
detroit_area_intersections AS (
  SELECT sas.name, 
         ST_Intersection(ST_Transform(sas.geometry, 4269), detroit_boundary.geometry) AS geometry
  FROM rocket.alpine_joy_study_areas sas
  JOIN detroit_boundary ON TRUE
)
SELECT 
    name, 
    ST_AREA(ST_TRANSFORM(geometry, 2898)) AS area, 
    ST_AREA(ST_TRANSFORM(geometry, 2898)) / 4772820.613658167 AS ratio_to_orig
FROM detroit_area_intersections
ORDER BY 2;
