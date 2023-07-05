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

-- Look at countries with highest infection rate per popilation
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM
    coviddeaths
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;

-- Look at countries with highest death count per popilation
SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    coviddeaths
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT
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
    SUM(new_cases),
    SUM(new_deaths),
    SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

-- Looking at total Population vs Vaccinations
WITH PopVSVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covidvaccinations vac
join coviddeaths dea
on vac.location = dea.location and vac.date=dea.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
 from PopVSVac;
 
 -- TEMP TABLE
 
 DROP table if exists PercentPopulationVaccinated;
 
CREATE TABLE PercentPopulationVaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population TEXT,
    new_vaccinations TEXT,
    RollingPeopleVaccinated TEXT
);
 
INSERT INTO PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covidvaccinations vac
join coviddeaths dea
on vac.location = dea.location and vac.date=dea.date
where dea.continent is not null;

SELECT 
    *,
    (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM
    PercentPopulationVaccinated;

-- creating View to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covidvaccinations vac
join coviddeaths dea
on vac.location = deapercentpopulationvaccinated.location and vac.date=dea.date
where dea.continent is not null;

SELECT 
    *
FROM
    portfolio1.percentpopulationvaccinated;
 


