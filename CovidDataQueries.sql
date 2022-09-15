SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccines
--ORDER BY 3, 4

--Select Data that we will be using:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

--Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location Like 'United States'
ORDER BY 1, 2

--Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location Like 'United States'
ORDER BY 1, 2

-- Countries with highest infection rate compared to population
SELECT location, Max(total_cases) AS HighestInfectionCount, population, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY population, location
ORDER BY PercentPopulationInfected desc

--Countries with highest death count per population
SELECT location, Max(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Now by Continent
SELECT location, Max(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NULL AND location NOT IN ('Low income', 'Lower middle income', 'upper middle income', 
'high income', 'European Union', 'International', 'World')
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing Continents with Infection rate compared to population

SELECT location, Max(total_cases) AS HighestInfectionCount, population, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NULL AND location NOT IN ('Low income', 'Lower middle income', 'upper middle income', 
'high income', 'European Union', 'International', 'World')
GROUP BY population, location
ORDER BY PercentPopulationInfected desc

--Global Numbers

SELECT date, SUM(new_cases) AS NewCases, SUM(cast(new_deaths AS int)) AS NewDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--Global Death Percentage
SELECT SUM(new_cases) AS NewCases, SUM(cast(new_deaths AS int)) AS NewDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccines vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--Use CTE

WITH PopsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccines vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopsVac


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccines vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
