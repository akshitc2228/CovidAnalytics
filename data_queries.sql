--cases to deaths ratio excluding null values:
--Observations: India has a population of over 1.4 billion people but max reported deaths are around 400,000; Hard to believe
SELECT
    location,
    population,
    collection_date,
    total_cases,
    total_deaths,
    (
        CASE
            WHEN total_cases <> 0 THEN
                ( total_deaths / total_cases ) * 100
            ELSE
                NULL
        END
    ) AS mortalityrate
FROM
    coviddeaths
WHERE
        total_cases <> 0
    AND location LIKE '%India'
    AND collection_date < '01-JAN-23'
ORDER BY
    location,
    collection_date;

--Let's check for another big country like the USA:
SELECT
    location,
    population,
    collection_date,
    total_cases,
    total_deaths,
    (
        CASE
            WHEN total_cases <> 0 THEN
                ( total_deaths / total_cases ) * 100
            ELSE
                NULL
        END
    ) AS mortalityrate
FROM
    coviddeaths
WHERE
        total_cases <> 0
    AND location LIKE '%United States'
    AND collection_date < '01-JAN-23'
ORDER BY
    total_deaths DESC;

--Find max cases and mortality period for India:
WITH maxvalues AS (
    SELECT
        MAX(total_cases) AS max_cases,
        MAX(
            CASE
                WHEN total_cases <> 0 THEN
                    (total_deaths / total_cases) * 100
                ELSE
                    NULL
            END
        )                AS max_mortality_rate
    FROM
        coviddeaths
    WHERE
            total_cases <> 0
        AND location LIKE '%India'
)
SELECT
    location,
    population,
    collection_date,
    total_cases,
    total_deaths,
    (
        CASE
            WHEN total_cases <> 0 THEN
                ( total_deaths / total_cases ) * 100
            ELSE
                NULL
        END
    ) AS mortalityrate
FROM
    coviddeaths,
    maxvalues
WHERE
    total_cases = maxvalues.max_cases
    OR (
        CASE
            WHEN total_cases <> 0 THEN
                ( total_deaths / total_cases ) * 100
            ELSE
                NULL
        END
    ) = maxvalues.max_mortality_rate
    AND total_cases <> 0
    AND location LIKE '%India'
ORDER BY
    mortalityrate DESC;

--Looking at countries with highest infection rate compared to population:
--Question: Why not partition by here? Would aggregation functions over attributes like total_cases and total_deaths
--not roll over the countries (location attribute in this case)? Seems to be the case for vaccinations.
SELECT
    location,
    population,
    MAX(total_cases)                      AS highest_total_cases,
    MAX((total_cases / population)) * 100 AS max_infection_spread_rate
FROM
    coviddeaths
WHERE
    collection_date < '01-AUG-22'
GROUP BY
    location,
    population
ORDER BY
    max_infection_spread_rate DESC;

--Countries with highest death count:
SELECT
    continent,
    location,
    MAX(total_deaths)                      AS highest_total_deaths,
    MAX((total_deaths / population)) * 100 AS max_death_percentage
FROM
    coviddeaths
WHERE
        collection_date < '01-AUG-22'
    AND continent IS NOT NULL
GROUP BY
    continent,
    location
ORDER BY
    max_death_percentage DESC;

---------------------------------------

--showing continents with highest death count:
SELECT
    continent,
    MAX(total_deaths) AS max_deaths
FROM
    coviddeaths
WHERE
        collection_date < '01-AUG-21'
    AND continent IS NOT NULL
GROUP BY
    continent
ORDER BY
    max_deaths DESC;

--show death toll by summing total_death count for all countries belonging to a continent and then dispalying the net total:
SELECT
    continent,
    SUM(total_deaths_countries) AS max_death_continent
FROM
    (
        SELECT
            continent,
            location,
            MAX(total_deaths) AS total_deaths_countries
        FROM
            coviddeaths
        WHERE
                collection_date < '01-AUG-21'
            AND continent IS NOT NULL
            AND total_deaths IS NOT NULL
        GROUP BY
            continent,
            location
    )
GROUP BY
    continent
ORDER BY
    continent,
    max_death_continent DESC;

--global numbers:
SELECT
    SUM(new_cases)                             AS nettotal_cases,
    SUM(new_deaths)                            AS nettotal_deaths,
    ( SUM(new_deaths) / SUM(new_cases) ) * 100 AS mortality_rate
FROM
    coviddeaths
WHERE
    continent IS NOT NULL;