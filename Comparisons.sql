SELECT
    *
FROM
    coviddeaths
WHERE
    ROWNUM <= 20;

SELECT
    *
FROM
    covidvaccinations
WHERE
    ROWNUM <= 20;

--compare the infection rate, death toll, and vaccination between countries:

--see max cases and death toll and mortality rate for each country
SELECT
    continent,
    location,
    population,
    MAX(total_cases)  AS max_cases,
    MAX(total_deaths) AS death_toll,
    CASE
        WHEN MAX(total_cases) > 0 THEN
            ( MAX(total_deaths) / MAX(total_cases) ) * 100
        ELSE
            0
    END               AS mortality_rate
FROM
    coviddeaths
WHERE
    collection_date BETWEEN '01-JAN-20' AND '01-JAN-22'
    AND continent IS NOT NULL
GROUP BY
    continent,
    location,
    population
ORDER BY
    mortality_rate DESC;

--first check if rolling vaccinations resets or not:
SELECT
    cd.continent,
    cd.location,
    cd.population,
    cv.new_vaccinations,
    cv.total_vaccinations
FROM
         coviddeaths cd
    JOIN covidvaccinations cv ON cd.location = cv.location
                                 AND cd.collection_date = cv.collection_date
WHERE
    cd.collection_date BETWEEN '01-JAN-21' AND '01-NOV-22'
    AND cd.continent IS NOT NULL
    AND cv.total_vaccinations IS NOT NULL
    AND cv.new_vaccinations IS NOT NULL
ORDER BY
    1,
    2,
    4;

--compare vaccination rates between countries and how effective that vaccination has been 
--thereby assessing the efficiency of the vaccine:
SELECT
    cd.continent,
    cd.location,
    cd.population,
    max(cv.total_vaccinations) AS net_vaccinated,
    (max(cv.total_vaccinations)/population)*100 as percent_vaccination
FROM
         coviddeaths cd
    JOIN covidvaccinations cv ON cd.location = cv.location
                                 AND cd.collection_date = cv.collection_date
WHERE
    cd.collection_date BETWEEN '01-JAN-21' AND '01-NOV-22'
    AND cd.continent IS NOT NULL
GROUP BY
    cd.continent,
    cd.location,
    cd.population
ORDER BY
    percent_vaccination DESC;
    
    SELECT
    cd.continent,
    cd.location,
    cd.population,
    max(cv.people_vaccinated) AS people_vaccinated,
    (max(cv.people_vaccinated)/population)*100 as percent_vaccination
FROM
         coviddeaths cd
    JOIN covidvaccinations cv ON cd.location = cv.location
                                 AND cd.collection_date = cv.collection_date
WHERE
    cd.collection_date BETWEEN '01-JAN-21' AND '01-NOV-22'
    AND cd.continent IS NOT NULL
GROUP BY
    cd.continent,
    cd.location,
    cd.population
ORDER BY
    percent_vaccination DESC;

--The resuts from the query above were not accurate. I suspect total_vaccinations is not resetting between locations
SELECT
    continent,
    location,
    total_vaccinations,
    new_vaccinations
FROM
    covidvaccinations
WHERE
    collection_date BETWEEN '01-JAN-21' AND '01-NOV-22'
    AND continent IS NOT NULL
    AND total_vaccinations IS NOT NULL
    AND new_vaccinations IS NOT NULL
ORDER BY
    continent,
    location,
    new_vaccinations;

--discrepancies observed between total_vaccinations and new_vaccinations; likely due to missing values in new_vaccinations
--resulting in unaccounted for addition to total_vaccinations.

--partition by approach:
select cd.continent, cd.location, cd.collection_date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over 
(partition by cd.location order by cd.location, cd.collection_date)
from coviddeaths cd join covidvaccinations cv on cd.location = cv.location and cd.collection_date = cv.collection_date
where cd.continent is not null 
order by 2, 3;

with RollingVaccinations (continent, location, collection_date, population, new_vaccinations, rollingVaccCount) as 
(
select cd.continent, cd.location, cd.collection_date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over 
(partition by cd.location order by cd.location, cd.collection_date) as rollingVaccCount
from coviddeaths cd join covidvaccinations cv on cd.location = cv.location and cd.collection_date = cv.collection_date
where cd.continent is not null 
)
select continent, location, collection_date, population, new_vaccinations, (rollingVaccCount/population)*100 as percent_vaccinated
from RollingVaccinations
where new_vaccinations is not null and rollingVaccCount is not null;
order by percent_vaccinated desc;

----------------------
--JUST ADDITIONAL DATE BOUNDS:
with RollingVaccinations (continent, location, collection_date, population, new_vaccinations, rollingVaccCount) as 
(
select cd.continent, cd.location, cd.collection_date, cd.population, cv.new_vaccinations,
sum(cv.new_vaccinations) over 
(partition by cd.location order by cd.location, cd.collection_date) as rollingVaccCount
from coviddeaths cd join covidvaccinations cv on cd.location = cv.location and cd.collection_date = cv.collection_date
where cd.continent is not null 
)
select continent, location, population, max(rollingVaccCount), (max(rollingVaccCount)/population)*100 as percent_vaccinated
from RollingVaccinations
where collection_date BETWEEN '01-JAN-21' AND '01-NOV-22'
group by continent, location, population
order by percent_vaccinated desc;



    