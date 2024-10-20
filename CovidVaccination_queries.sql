select *
from covidvaccinations;

--check rolling vaccinations:
select continent, location, min(new_vaccinations) as startingVaccinations
from covidvaccinations
where new_vaccinations is not null
group by continent, location
order by 1,2;

--confirms the suspicison that vaccination records indeed to rollover between locations for a continent.

--join both tables:
select *
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and cd.collection_date = cv.collection_date;

--find out the total number of people vaccinated for each continent:
SELECT 
    cd.continent, 
    cd.location, 
    cd.collection_date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) 
        OVER (PARTITION BY cd.continent ORDER BY cd.collection_date) AS rolling_vaccinations
FROM coviddeaths cd
JOIN covidvaccinations cv
    ON cd.location = cv.location
    AND cd.collection_date = cv.collection_date
WHERE cd.continent IS NOT NULL and cv.new_vaccinations is not null
ORDER BY cd.continent, cd.collection_date, cv.new_vaccinations, cd.location;

--using a CTE to :
WITH PopVsVacc (continent, location, collection_date, population, new_vaccinations, rolling_vaccinations) AS
(
    SELECT 
        cd.continent, 
        cd.location, 
        cd.collection_date, 
        cd.population, 
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) 
            OVER (PARTITION BY cd.continent ORDER BY cd.collection_date) AS rolling_vaccinations
    FROM coviddeaths cd
    JOIN covidvaccinations cv
        ON cd.location = cv.location
        AND cd.collection_date = cv.collection_date
    WHERE cd.continent IS NOT NULL 
      AND cv.new_vaccinations IS NOT NULL
),
PopulationByLocation as (
    select continent,
           location,
           max(population) as population_per_location
    from PopVsVacc
    group by continent, location
)
SELECT 
    pv.continent,
    MAX(pv.rolling_vaccinations) AS total_vaccinated_continent,
    SUM(pl.population_per_location) AS total_population_continent,
    (MAX(pv.rolling_vaccinations) / SUM(pl.population_per_location)) * 100 AS percent_vaccinated_continent
FROM PopVsVacc pv
JOIN PopulationByLocation pl
    ON pv.continent = pl.continent
GROUP BY pv.continent
ORDER BY percent_vaccinated_continent DESC;

--notes on this: order by on percent_vaccinated wont work correctly because population will keep changing as I've partitioned
--on continent.