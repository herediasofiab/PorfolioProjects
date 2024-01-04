SELECT *
FROM [Projecto Porfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT *
FROM [Projecto Porfolio]..CovidVac
ORDER BY 3,4


--Deaths Porcent vs Total Cases

SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Projecto Porfolio]..CovidDeaths
WHERE location='Spain' and continent is not null
ORDER BY 1,2


--Total Cases vs Population

SELECT location, date, total_cases, population,(total_cases/population)*100 as PercentagePopulationInfected
FROM [Projecto Porfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Locations with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM [Projecto Porfolio]..CovidDeaths
GROUP BY location, population
WHERE continent is not null
ORDER BY PercentagePopulationInfected desc


--Showing Countries with the Highest Death Count per Location

SELECT location, MAX(cast(total_deaths as int))as TotalDeathCount
FROM [Projecto Porfolio]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing Continents with the Highest Death Count

SELECT continent, MAX(cast(total_deaths as int))as TotalDeathCount
FROM [Projecto Porfolio]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Continents with Highest Infection Rate compared to Population

SELECT continent, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM [Projecto Porfolio]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercentagePopulationInfected desc


--Global Numbers

SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Projecto Porfolio]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Population vs Vaccinations 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert (int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
FROM [Projecto Porfolio]..CovidDeaths dea
JOIN [Projecto Porfolio]..CovidVac vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  is not null
--ORDER BY 2, 3
)
SELECT *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVac
FROM PopvsVac


--Temp Table

DROP TABLE if exists PercentagePopulationVaccinated
CREATE TABLE PercentagePopulationVaccinated 
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentagePopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert (int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
FROM [Projecto Porfolio]..CovidDeaths dea
JOIN [Projecto Porfolio]..CovidVac vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  is not null

SELECT *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVac
FROM PercentagePopulationVaccinated 



--Create View to store data for later visualizations 

CREATE VIEW PercentPopulationVacc as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert (int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
FROM [Projecto Porfolio]..CovidDeaths dea
JOIN [Projecto Porfolio]..CovidVac vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVacc



--Percentage of total deaths versus total vaccinated

SELECT dea.Location,(SUM(CAST(dea.total_deaths as bigint))) as TotalDeaths,
	SUM(CAST(vac.total_vaccinations as bigint)) as TotalVac, 	
	((SUM(CAST(dea.total_deaths as bigint))/(SUM(CAST(vac.total_vaccinations as bigint))))*100) as PercentDeathsVaccinated
FROM [Projecto Porfolio]..CovidDeaths dea
	JOIN [Projecto Porfolio]..CovidVac vac 
	ON dea.location = vac.location 
	AND dea.continent = vac.continent
WHERE dea.continent is not null
GROUP BY dea.location
ORDER BY PercentDeathsVaccinated desc



----Total number of smoking cases per location, and percentage of cases per population

SELECT 
	 Location, TotalCases Smokers_Percentage, SmokersCasesTotal, PercenCases_byPopulation 
FROM
(
SELECT
	dea.location,
	MAX(COALESCE(TRY_CAST(vac.female_smokers as int), 0) + COALESCE(TRY_CAST(vac.male_smokers as int), 0)) as Smokers_Percentage, 
	MAX(dea.total_cases) as TotalCases,
	(MAX(COALESCE(TRY_CAST(vac.female_smokers as int), 0) + COALESCE(TRY_CAST(vac.male_smokers as int), 0)))*MAX(dea.total_cases) as SmokersCasesTotal,
	MAX(dea.total_cases/dea.population) as PercenCases_byPopulation 	
FROM [Projecto Porfolio]..CovidDeaths dea
	JOIN [Projecto Porfolio]..CovidVac vac 
	ON dea.location = vac.location 
WHERE dea.continent is not null
GROUP BY dea.location
) as SmokersSub
ORDER BY 
Smokers_Percentage desc, PercenCases_byPopulation desc



--Creation of Visualization of the total number of smoking cases by locality and percentage of cases by population ( Query Previous)

CREATE VIEW SmokersView as
SELECT 
    Location,
    TotalCases,
    Smokers_Percentage,
    SmokersCasesTotal,
    PercenCases_byPopulation 
FROM
(
    SELECT
        dea.location,
        MAX(COALESCE(TRY_CAST(vac.female_smokers as int), 0) + COALESCE(TRY_CAST(vac.male_smokers as int), 0)) as Smokers_Percentage, 
        MAX(dea.total_cases) as TotalCases,
        (MAX(COALESCE(TRY_CAST(vac.female_smokers as int), 0) + COALESCE(TRY_CAST(vac.male_smokers as int), 0))) * MAX(dea.total_cases) as SmokersCasesTotal,
        MAX(dea.total_cases/dea.population) as PercenCases_byPopulation 	
    FROM 
        [Projecto Porfolio]..CovidDeaths dea
        JOIN [Projecto Porfolio]..CovidVac vac ON dea.location = vac.location 
    WHERE 
        dea.continent is not null
    GROUP BY 
        dea.location
) as SmokersSub;


SELECT *
FROM SmokersView
ORDER BY Smokers_Percentage desc, PercenCases_byPopulation desc


