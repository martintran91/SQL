-- DATA ENDS AUGUST 3
-- Monkeypox Dataset: https://github.com/globaldothealth/monkeypox/blob/main/latest.csv
-- Population data: https://worldpopulationreview.com/countries
-- Signs and Symptoms: https://www.cdc.gov/poxvirus/monkeypox/symptoms.html

SELECT * FROM Monkeypox;

-- Select Columns Used

SELECT 
    country,  
    gender, 
    date_confirmation, 
    symptoms, 
    hospitalized, 
    traveled,
    date_death
FROM monkeypox
WHERE status = 'confirmed'
ORDER BY country, date_confirmation;



-- Case Count by Day

SELECT 
    date_confirmation, 
    COUNT(*) AS count,
    country
FROM monkeypox
WHERE status = 'confirmed'
GROUP BY date_confirmation, country
ORDER BY date_confirmation;

— Case Count Rolling

SELECT 
    date_confirmation,
    SUM(COUNT(date_confirmation)) OVER (ORDER BY date_confirmation) AS TotalCases
FROM Monkeypox
WHERE Status = 'confirmed'
GROUP BY date_confirmation;


-- Infection Count by Country

SELECT Country, COUNT(*) AS infections
FROM Monkeypox
WHERE Status = 'confirmed'
GROUP BY Country
ORDER BY infections DESC;

-- Infection Rate by Country

WITH InfectionCount (Country, infections)
AS
(
SELECT country, COUNT(*) AS infections
FROM Monkeypox
WHERE Status = 'confirmed'
GROUP BY Country
ORDER BY infections DESC
)
SELECT i.country, 
    i.infections, 
    p.population, 
    ROUND((i.infections/(p.population * 1000))*100,2) AS InfectionRate
FROM InfectionCount i
INNER JOIN population p
ON i.country = p.country
ORDER BY InfectionRate DESC;



-- Death Count by Day

SELECT COUNT(date_death) AS deaths, date_confirmation, country
FROM monkeypox
WHERE Status = 'confirmed'
GROUP BY date_confirmation, country;

-- Death Count by Country

SELECT country, COUNT(date_death) AS deaths
FROM monkeypox
GROUP BY country
ORDER BY deaths DESC, country;



-- Hospitalization Count WHERE (Y)

SELECT COUNT(hospitalized) AS hospitalizations
FROM monkeypox
WHERE hospitalized = 'Y' AND status = 'confirmed';

-- Hospitalization Count WHERE (N)

SELECT COUNT(hospitalized) AS hospitalizations
FROM monkeypox
WHERE hospitalized = 'N' AND status = 'confirmed';

-- Hospitalization Count WHERE Unspecified

SELECT COUNT(*) - (216)
FROM monkeypox
WHERE status = 'confirmed';

-- Hospitalizations by Country

SELECT country, COUNT(hospitalized) AS hospitalizations
FROM monkeypox
GROUP BY country
ORDER BY hospitalizations DESC, country;

-- Hospitalization Count by Day

SELECT COUNT(hospitalized) AS hospitalizations, date_confirmation, country
FROM monkeypox
WHERE hospitalized = 'Y' AND status = 'confirmed'
GROUP BY date_confirmation, country;



-- Let's look at symptoms
-- The symptoms reported are not in a standardized format and not all Sx may be correlated to monkeypox specifically, 
-- so for the purpose of keeping the dashboard in a standard format, I am using the list of Sx provided by the CDC
-- (https://www.cdc.gov/poxvirus/monkeypox/symptoms.html) which includes:
-- Fever
-- Headache
-- Muscle aches and backache
-- Swollen lymph nodes
-- Chills
-- Exhaustion
-- Respiratory symptoms (e.g. sore throat, nasal congestion, or cough)
-- A rash that may be located on or near the genitals (penis, testicles, labia, and vagina) or anus (butthole) 
--    but could also be on other areas like the hands, feet, chest, face, or mouth.
--        The rash will go through several stages, including scabs, before healing.
--        The rash can look like pimples or blisters and may be painful or itchy.



-- ALL SYMPTOMS

SELECT symptoms, COUNT(symptoms) AS SymptomCount
FROM monkeypox
GROUP BY symptoms
ORDER BY SymptomCount DESC;



-- SEPARATE SYMPTOMS

-- Fever

SELECT COUNT(symptoms) AS fever
FROM monkeypox
WHERE symptoms 
    LIKE '%fever%'
    OR symptoms LIKE '%temperature%';

-- Headache

SELECT COUNT(symptoms) AS headache
FROM monkeypox
WHERE symptoms LIKE '%headache%';

-- Muscle aches and backache

SELECT COUNT(symptoms) AS muscleache
FROM monkeypox
WHERE symptoms 
    LIKE '%muscle ache%'
    OR symptoms LIKE '%pain%'
    OR symptoms LIKE '%myalgia%';

-- Swollen lymph nodes

SELECT COUNT(symptoms) AS lymph
FROM monkeypox
WHERE symptoms 
    LIKE '%lymph%'
    OR symptoms LIKE '%adeno%';
    
-- Chills

SELECT COUNT(symptoms) AS chills
FROM monkeypox
WHERE symptoms LIKE '%chills%';

-- Exhaustion

SELECT COUNT(symptoms) AS fatigue
FROM monkeypox
WHERE symptoms 
    LIKE '%fatigue%'
    OR symptoms LIKE '%exhaustion%'
    OR symptoms LIKE '%strength%';

-- Respiratory
    -- sore throat
SELECT COUNT(symptoms) AS sorethroat
FROM monkeypox
WHERE symptoms 
    LIKE '%throat%';

    -- congestion
SELECT COUNT(symptoms) AS congestion
FROM monkeypox
WHERE symptoms 
    LIKE '%congest%';

    -- cough
SELECT COUNT(symptoms) AS cough
FROM monkeypox
WHERE symptoms 
    LIKE '%cough%';
    
-- Skin
    -- lesion
SELECT COUNT(symptoms) AS lesion
FROM monkeypox
WHERE symptoms 
    LIKE '%lesion%'
    OR symptoms LIKE '%pustule%'
    OR symptoms LIKE '%papule%'
    OR symptoms LIKE '%vesic%'
    OR symptoms LIKE '%blister%'
    OR symptoms LIKE '%ulcer%';    

    -- rash
SELECT COUNT(symptoms) AS rash
FROM monkeypox
WHERE symptoms 
    LIKE '%rash%'
    OR symptoms LIKE '%itch%'
    OR symptoms LIKE '%outbreak%';
    



-- Union all symptoms and count together

SELECT 'Headache' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms LIKE '%headache%'

    UNION
    
SELECT 'Fever' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%fever%'
    OR symptoms LIKE '%temperature%'

    UNION

SELECT 'Muscle ache' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%muscle ache%'
    OR symptoms LIKE '%pain%'
    OR symptoms LIKE '%myalgia%'
    
    UNION
    
SELECT 'Swollen Lymph Nodes' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%lymph%'
    OR symptoms LIKE '%adeno%'

    UNION
    
SELECT 'Chills' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms LIKE '%chills%'

    UNION
    
SELECT 'Fatigue' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%fatigue%'
    OR symptoms LIKE '%exhaustion%'
    OR symptoms LIKE '%strength%'
    
    UNION
    
SELECT 'Sore throat' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%throat%'

    UNION
    
SELECT 'Congestion' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%congest%'
    
    UNION

SELECT 'Cough' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%cough%'

    UNION

SELECT 'Skin lesion' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%lesion%'
    OR symptoms LIKE '%pustule%'
    OR symptoms LIKE '%papule%'
    OR symptoms LIKE '%vesic%'
    OR symptoms LIKE '%blister%'
    
    UNION
    
SELECT 'Rash' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%rash%'
    OR symptoms LIKE '%pustule%'
    OR symptoms LIKE '%papule%'
    OR symptoms LIKE '%vesic%'
    OR symptoms LIKE '%blister%'
    OR symptoms LIKE '%ulcer%';
    

-- Create a CTE to order by count

WITH sx AS
(
SELECT 'Headache' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms LIKE '%headache%'

    UNION
    
SELECT 'Fever' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%fever%'
    OR symptoms LIKE '%temperature%'

    UNION

SELECT 'Muscle ache' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%muscle ache%'
    OR symptoms LIKE '%pain%'
    OR symptoms LIKE '%myalgia%'
    
    UNION
    
SELECT 'Swollen Lymph Nodes' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%lymph%'
    OR symptoms LIKE '%adeno%'

    UNION
    
SELECT 'Chills' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms LIKE '%chills%'

    UNION
    
SELECT 'Fatigue' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%fatigue%'
    OR symptoms LIKE '%exhaustion%'
    OR symptoms LIKE '%strength%'
    
    UNION
    
SELECT 'Sore throat' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%throat%'

    UNION
    
SELECT 'Congestion' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%congest%'
    
    UNION

SELECT 'Cough' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%cough%'

    UNION

SELECT 'Skin lesion' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%lesion%'
    OR symptoms LIKE '%pustule%'
    OR symptoms LIKE '%papule%'
    OR symptoms LIKE '%vesic%'
    OR symptoms LIKE '%blister%'
    
    UNION
    
SELECT 'Rash' AS symptom, COUNT(symptoms) AS count
FROM monkeypox
WHERE symptoms 
    LIKE '%rash%'
    OR symptoms LIKE '%pustule%'
    OR symptoms LIKE '%papule%'
    OR symptoms LIKE '%vesic%'
    OR symptoms LIKE '%blister%'
    OR symptoms LIKE '%ulcer%'
)
SELECT *
FROM sx
ORDER BY count DESC, symptom;



-- Cases by Gender
    -- I am making sure to filter out data that <> 'confirmed' because some of it has been dropped, omitted, or only suspected
    
    -- Male
SELECT gender, COUNT(gender) AS count
FROM monkeypox
WHERE gender = 'male' AND status = 'confirmed';

    -- Female
SELECT gender, COUNT(gender) AS count
FROM monkeypox
WHERE gender = 'female' AND status = 'confirmed';

    -- Unspecified
SELECT COUNT(*) AS total
FROM monkeypox
WHERE status = 'confirmed';

-- There is an error when I attempt to count the NULLs under gender. Therefore, I am going to use a CTE
    -- to view the values. Since SQLite does not support the pivot function, I am going to create a table
    -- to reorder the rows and columns for calculation and end with a table in the format I need.
    
WITH cte
AS
(
SELECT gender, COUNT(gender) AS count
FROM monkeypox
WHERE gender = 'male' AND status = 'confirmed'

    UNION
    
SELECT gender, COUNT(gender) AS count
FROM monkeypox
WHERE gender = 'female' AND status = 'confirmed'

    UNION
    
SELECT gender, COUNT(*) AS total
FROM monkeypox
WHERE status = 'confirmed'
)
SELECT *
FROM cte
ORDER BY count;

-- Create table

DROP TABLE IF EXISTS t;

CREATE TABLE t 
(
male INTEGER, 
female INTEGER, 
unspecified INTEGER
);
INSERT INTO t (male, female, unspecified)
VALUES (1716, 5, 25652);

-- Query with calculations

SELECT male, female, (unspecified - (male + female)) AS UnspecifiedGender
FROM t;