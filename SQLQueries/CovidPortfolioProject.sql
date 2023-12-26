select * 
from dbo.coviddeathss 
where continent is not null
order by 3,4

--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population from dbo.coviddeathss order by 1,2

-- Looking at Total Cases vs Total Deaths as Percentage
-- Shows likelihood of dying if you contract covid in Turkey

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN total_cases = 0 THEN NULL
        ELSE total_deaths * 100.0 / total_cases
    END AS DeathPercentage
FROM
    dbo.coviddeathss
Where location like '%Turkey%'
ORDER BY 1,2

-- Total Cases vs Population 
-- Shows what percentage of population got Covid

SELECT
    location,
    date,
    total_cases,
    population,
    CASE
        WHEN total_cases = 0 THEN NULL
        ELSE total_cases * 100.0 / population
    END AS PercentPopulationInfected
FROM
    dbo.coviddeathss
Where location like '%Turkey%'
ORDER BY 1,2


-- Looking at countries with Highest infection rate compared to Population

select location,population,MAX(total_cases) as HighestInfectionCount,
CASE
        WHEN population = 0 THEN NULL
        ELSE MAX((total_cases * 100.0 / population))
    END AS PercentPopulationInfected

from dbo.coviddeathss
Group By location,population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location,MAX(total_deaths) as TotalDeathCount 
from dbo.coviddeathss
where continent is not null
group by location
order by TotalDeathCount desc

-- Lets Break Things Down By Continent

-- Showing continents with the highest death count per population

select continent,MAX(total_deaths) as TotalDeathCount 
from dbo.coviddeathss
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select
	date,
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	    CASE
        WHEN sum(new_cases) = 0 THEN NULL
        ELSE sum(new_deaths) * 100.0 / sum(new_cases)
    END AS DeathPercentage
from dbo.coviddeathss
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    CAST(SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS bigint) AS RollingPeopleVaccinated
FROM
    dbo.coviddeathss dea
JOIN
    dbo.covidvac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.location, dea.date;


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
    SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    CAST(SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS bigint) AS RollingPeopleVaccinated
FROM
    dbo.coviddeathss dea
JOIN
    dbo.covidvac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY
--    dea.location, dea.date;
)
SELECT
    *,
    CASE
        WHEN Population = 0 THEN 0
        ELSE CAST(RollingPeopleVaccinated AS float) / Population * 100
    END AS VaccinationPercentage
FROM
    PopvsVac;


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    CAST(SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS bigint) AS RollingPeopleVaccinated
FROM
    dbo.coviddeathss dea
JOIN
    dbo.covidvac vac ON dea.location = vac.location AND dea.date = vac.date
--WHERE
--    dea.continent IS NOT NULL
--ORDER BY
--    dea.location, dea.date
SELECT
    *,
    CASE
        WHEN Population = 0 THEN 0
        ELSE CAST(RollingPeopleVaccinated AS float) / Population * 100
    END AS VaccinationPercentage
FROM
    #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    CAST(SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS bigint) AS RollingPeopleVaccinated
FROM
    dbo.coviddeathss dea
JOIN
    dbo.covidvac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
--ORDER BY
--    dea.location, dea.date

select * from PercentPopulationVaccinated
