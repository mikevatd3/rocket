-- The model has more 1 -> 0 errors than anything else (especially since I'm not
-- distinguishing between categories 1-3.

-- Run this first to inspect the first 1000 largest parties
SELECT grantee, COUNT(*), (array_agg(grantee_category))[1]
FROM rocket.sales_parties_predicted
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1000;

SELECT grantor, COUNT(*), (array_agg(grantor_category))[1]
FROM rocket.sales_parties_predicted
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1000;

-- Update grantor / grantee errors that were found in the first 1000
UPDATE rocket.sales_parties_predicted 
SET grantee_category = 1
WHERE TRIM(grantee) IN (
    'WAYNE COUNTY SHERIFF',
    'SHERIFF',
    'SECRETARY OF VETERANS AFFAIRS',
    'WOODLAWN PROPERTIES',
    'DETROIT LAND BANK AUTH',
    'HUNTER PASTEUR HOMES LAFAYETTE PK',
    'PARTY CITY LC',
    'JOHN WHITBY FORSYTH PROPERTI et al',
    'TANSLEY LP',
    'FELICIA MACK, DEPUTY SHERIFF',
    'HANTZ WOODLANDS',
    'HANTZ WOODLAND',
    'TAXPAYER',
    'SCOTTEN PK LDHALP'
);


UPDATE rocket.sales_parties_predicted 
SET grantor_category = 1
WHERE TRIM(grantor) IN (
    'WAYNE COUNTY SHERIFF',
    'SHERIFF',
    'SECRETARY OF VETERANS AFFAIRS',
    'WOODLAWN PROPERTIES',
    'DETROIT LAND BANK AUTH',
    'HUNTER PASTEUR HOMES LAFAYETTE PK',
    'PARTY CITY LC',
    'JOHN WHITBY FORSYTH PROPERTI et al',
    'TANSLEY LP',
    'FELICIA MACK, DEPUTY SHERIFF',
    'HANTZ WOODLANDS',
    'HANTZ WOODLAND',
    'TAXPAYER',
    'SCOTTEN PK LDHALP'
);
