-- Covid 19 Data Exploration 
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


USE PORTFOLIO1;
SELECT 
    *
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 3 , 4;
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
WHERE
    CONTINENT IS NOT NULL
ORDER BY 1 , 2;

-- Look at total_cases VS total_deaths 
-- Shows likelihood of dying if you contract covid in the country

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    (total_deaths / total_Cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%iceland%'
        AND CONTINENT IS NOT NULL
ORDER BY 1 , 2;

-- Look at total_cases VS population
-- Shows what percentage of population got Covid

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM
    coviddeaths
WHERE
    location LIKE '%iceland%'
ORDER BY 1 , 2;

-- Look at countries with highest infection rate per population

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM
    coviddeaths
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;
-- Look at countries with highest death count per population
SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    coviddeaths
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Show continents with highest death count per population

SELECT 
    continent,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
-- GLOBAL NUMBERS
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;


-- Total Population vs Vaccinations
-- Show percentage of population that has received at least one vaccination

Select 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (
    Partition by dea.Location 
    Order by 
      dea.location, 
      dea.Date
  ) as RollingPeopleVaccinated 
From 
  CovidDeaths dea 
  Join CovidVaccinations vac On dea.location = vac.location 
  and dea.date = vac.date 
where 
  dea.continent is not null 
order by 
  2, 3;
  
  
-- Use CTE to perform calculation on Partition by in previous query

WITH PopVSVac (
  continent, location, date, population, 
  new_vaccinations, RollingPeopleVaccinated
) as(
  select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    sum(vac.new_vaccinations) over (
      partition by dea.location 
      order by 
        dea.location, 
        dea.date
    ) as RollingPeopleVaccinated 
  from 
    covidvaccinations vac 
    join coviddeaths dea on vac.location = dea.location 
    and vac.date = dea.date 
  where 
    dea.continent is not null
) 
Select 
  *, 
  (
    RollingPeopleVaccinated / population
  )* 100 as cte_PercentPopulationVaccinated 
from 
  PopVSVac;
  
-- Use TEMP TABLE to perform calculation on Partition by in previous query

DROP 
  table if exists temp_PercentPopulationVaccinated;
CREATE TABLE temp_PercentPopulationVaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population TEXT,
    new_vaccinations TEXT,
    RollingPeopleVaccinated TEXT
);
INSERT INTO temp_PercentPopulationVaccinated 
select 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  sum(vac.new_vaccinations) over (
    partition by dea.location 
    order by 
      dea.location, 
      dea.date
  ) as RollingPeopleVaccinated 
from 
  covidvaccinations vac 
  join coviddeaths dea on vac.location = dea.location 
  and vac.date = dea.date 
where 
  dea.continent is not null;
SELECT 
    *,
    (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM
    PercentPopulationVaccinated;
    
-- creating View to store data for later visualization

DROP 
  VIEW if exists view_PercentPopulationVaccinated;
CREATE VIEW view_PercentPopulationVaccinated AS 
select 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  sum(vac.new_vaccinations) over (
    partition by dea.location 
    order by 
      dea.location, 
      dea.date
  ) as RollingPeopleVaccinated 
from 
  covidvaccinations vac 
  join coviddeaths dea on vac.location = dea.location 
  and vac.date = dea.date 
where 
  dea.continent is not null;
SELECT 
    *
FROM
    portfolio1.percentpopulationvaccinated;
