SELECT *
FROM coviddeaths

-- Data to be analyzed
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY Date ASC

-- Looking at Total cases vs. Total Deaths
-- Shows the likelihood of dying if you contract Covid in the states
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeaths
WHERE location like '%states%'
ORDER BY total_cases ASC 

-- Looking at Total Cases vs Population
-- Shows what percentage of the population contracted Covid in the states
SELECT Location, Date, total_cases, Population, (total_cases/Population)*100 AS Percent_Population_Infected
FROM coviddeaths
WHERE location like '%states%'
ORDER BY total_cases ASC 

-- What country has the highest infection rate compared to the population?
-- Andorra has a 17.13%  due to a small population size.
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM coviddeaths
Group BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Shows countries with the highest death count per population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM coviddeaths
Group BY Location
ORDER BY Total_Death_Count DESC

-- Shows Continents with the highest death count per population
SELECT Continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM coviddeaths
Group BY Continent
ORDER BY Total_Death_Count DESC

-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
FROM coviddeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2

-- Using Joins to join Covid deaths and Covid Vaccinations table
SELECT *
FROM coviddeaths AS dea -- Creating aliases for these two tables
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date
    
-- Looking at Total Population vs. Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS Rolling_Count_Vaccinations
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date
ORDER BY 2,3 

-- Using CTE, if # of columns in CTE is different it will give an error
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_Count_Vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS Rolling_Count_Vaccinations
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date
)
SELECT *, (Rolling_Count_Vaccinations/Population) *100 AS VaccinationsPerPopulation
FROM PopvsVac

-- Using TEMP Tables instead of CTE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
Rolling_Count_Vaccinations numeric
)
INSERT INTO
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS Rolling_Count_Vaccinations
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date

SELECT *, (Rolling_Count_Vaccinations/Population) *100 AS VaccinationsPerPopulation
FROM #PercentPopulationVaccinated

-- Create view to store data for visualization
percentpopulationvaccinatedCREATE VIEW PercentPopulationVaccinated AS 
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM coviddeaths
Group BY Location, Population