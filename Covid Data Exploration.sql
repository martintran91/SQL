/*
Covid 19 Data Exploration with MySQL
 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT * FROM covid.coviddeaths
WHERE continent != ''
ORDER BY location, date;

SELECT * FROM covidvaccinations
ORDER BY location, date;



-- Select data we are going to be using

SELECT location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM covid.coviddeaths
WHERE continent != ''
ORDER BY location, date;



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
FROM covid.coviddeaths
WHERE location like '%states%'
ORDER BY location, date;



-- Looking at Total Cases vs Population
-- Shows what percentage of population has contracted Covid

SELECT location, 
	date, 
	total_cases, 
	population, 
	(total_cases/population)*100 as PercentPopulationInfected
FROM covid.coviddeaths
WHERE location like '%states%'
ORDER BY location, date;



-- Looking at country with highest percent rate compared to population

SELECT location, 
	population, 
	MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases/population)*100) as PercentPopulationInfected
FROM covid.coviddeaths
WHERE continent != ''
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;



-- Showing countries with the highest death count by population

SELECT location, 
	MAX(CAST(total_deaths AS UNSIGNED)) as TotalDeathCount
FROM covid.coviddeaths
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount DESC;





-- LET's BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest death count per population

SELECT continent, 
	MAX(CAST(total_deaths AS UNSIGNED)) as TotalDeathCount
FROM covid.coviddeaths
WHERE continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths, 
	SUM(CAST(new_deaths AS UNSIGNED))/SUM(New_Cases)*100 AS DeathPercentage
FROM covid.CovidDeaths
-- Where location like '%states%'
WHERE continent != ''
-- Group By date
ORDER BY total_cases, total_deaths;



-- Looking at Total Population vs Vacciantions

SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY dea.location, dea.date;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--  , (RollingPeopleVaccinated/population)*100
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY dea.location, dea.date;



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date date,
population bigint,
new_vaccinations bigint,
RollingPeopleVaccinated bigint
);
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;
-- WHERE dea.continent != ''

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid.CovidDeaths dea
JOIN covid.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != '';
