select * from coviddeaths;
select * from covidvaccinations;

--STARTING WITH TEMP TABLES HERE; MAIN BENEFIT IS MULTIPLE QUERIES IN CONTRAST TO CTEs
-- Step 1: Create the temporary table
drop table if exists deathsAndVaccs
CREATE GLOBAL TEMPORARY TABLE deathsAndVaccs (
    continent VARCHAR2(26),
    location VARCHAR2(50),
    collection_date DATE,
    population NUMBER(38, 0),
    total_deaths NUMBER(38, 0),
    daily_deathAvg NUMBER(38, 3),
    new_vaccinations NUMBER(38, 0),
    rollingVaccCount NUMBER(38, 0),
    daily_vaccAvg NUMBER(38, 3),
    period VARCHAR2(15)  -- 'Pre-Vaccine' or 'Post-Vaccine'
) ON COMMIT DELETE ROWS;

-- Step 2: Insert the calculated data into the temporary table
INSERT INTO deathsAndVaccs
SELECT 
    cd.continent, 
    cd.location, 
    cd.collection_date,
    cd.population, 
    cd.total_deaths,
    AVG(cd.total_deaths) OVER (PARTITION BY cd.location ORDER BY cd.collection_date) AS daily_deathAvg,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.collection_date) AS rollingVaccCount,
    AVG(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.collection_date) AS daily_vaccAvg,

    -- Period classification based on the first vaccination date
    CASE 
        WHEN cd.collection_date < ADD_MONTHS(MIN(cv.collection_date) OVER (PARTITION BY cd.location), -3) THEN 'Pre-Vaccine'
        WHEN cd.collection_date >= ADD_MONTHS(MIN(cv.collection_date) OVER (PARTITION BY cd.location), -3) 
             AND cd.collection_date <= ADD_MONTHS(MIN(cv.collection_date) OVER (PARTITION BY cd.location), 3) THEN 'Post-Vaccine'
        ELSE 'Other'
    END AS period

FROM coviddeaths cd
INNER JOIN covidvaccinations cv 
    ON cd.location = cv.location 
    AND cd.collection_date = cv.collection_date
WHERE cd.total_deaths IS NOT NULL AND cd.continent IS NOT NULL and cv.new_vaccinations is not null;

select * from deathsandvaccs
order by location, collection_date;

--CREATING VIEWS:
CREATE VIEW percent_vaccinated AS
select cd.continent, cd.location, cd.collection_date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over 
(partition by cd.location order by cd.location, cd.collection_date) as rollingVaccCount
from coviddeaths cd join covidvaccinations cv on cd.location = cv.location and cd.collection_date = cv.collection_date
where cd.continent is not null and cv.new_vaccinations is not null;

select * from percent_vaccinated;





