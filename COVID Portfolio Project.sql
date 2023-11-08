
--SELECT * FROM PortfolioProject..CovidVaccinations
--WHERE location = 'Algeria'
--AND total_tests IS NOT NULL
--ORDER BY  5 DESC;

SELECT Location,Date,Population ,Total_cases,(total_cases/Population)*100 as TotalCasesPerPopulation
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%ger%'
ORDER BY 1,2 ;

ALTER TABLE CovidDeaths ALTER COLUMN Total_cases FLOAT ;


SELECT location ,count(total_deaths) AS TotalDeathsPerLocation
FROM CovidDeaths


--Looking At Countries With Highest Infection Rate Compared To Population

SELECT Location,Population ,MAX(Total_cases) AS HigestInfectionCount,MAX((total_cases/Population))*100 as PersentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location,Population
ORDER BY PersentPopulationInfected DESC;

--Showing Countries With Highest Death Count Per Population

SELECT Location,MAX(CAST(Total_deaths AS INT)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeaths DESC;


SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

-- Let's Break Things Down By Continent 

SELECT location,MAX(CAST(Total_deaths AS INT)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC;


--Showing Continent With The Highest Count Per Population


SELECT continent,MAX(CAST(Total_deaths AS INT)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC;


-- Globel Numbers

SELECT SUM(new_cases) AS Total_Cases,SUM(CAST(new_deaths AS INT)) AS Total_Deaths,CASE WHEN new_cases=0
     THEN NULL
	 ELSE SUM(CAST( new_deaths AS INT))/SUM(new_cases)*100 
	 END AS totaldeath--,total_deaths,(total_deaths/total_cases)*100 as TotalCasesPerPopulation
FROM PortfolioProject..CovidDeaths

--WHERE location LIKE '%ger%'
WHERE continent IS NOT NULL
--GROUP BY date , new_cases,location 
ORDER BY 1,2 DESC;


--Looking At Total Population Vs Vaccinations
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CONVERT (FLOAT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location ,D.date) AS RollingPoepleVaccinated
--(RollingPoepleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations V
JOIN PortfolioProject..CovidDeaths D
ON D.location=V.location
AND D.date=V.date
WHERE D.continent IS NOT NULL
--AND new_vaccinations= 1000
ORDER BY 3 ,2DESC


--USE CTE
WITH PopVsVac(continent,location,date,population,new_vaccinations,RollingPoepleVaccinated)
AS 
(
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CONVERT (FLOAT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location ,D.date) AS RollingPoepleVaccinated
--(RollingPoepleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations V
JOIN PortfolioProject..CovidDeaths D
ON D.location=V.location
AND D.date=V.date
WHERE D.continent IS NOT NULL
--AND new_vaccinations= 1000
--ORDER BY 2,3
)
SELECT * ,(RollingPoepleVaccinated/population)*100 FROM PopVsVac




--Temp Table 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(cotinent NVARCHAR(255),
 location NVARCHAR(255),
 date DATETIME ,
 population NUMERIC,
 new_vaccination NUMERIC,
 RollingPoepleVaccinated NUMERIC


 )
INSERT INTO #PercentPopulationVaccinated
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CONVERT (FLOAT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location ,D.date) AS RollingPoepleVaccinated
--(RollingPoepleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations V
JOIN PortfolioProject..CovidDeaths D
ON D.location=V.location
AND D.date=V.date
--WHERE D.continent IS NOT NULL
--AND new_vaccinations= 1000
--ORDER BY 2,3


SELECT * ,(RollingPoepleVaccinated/population)*100 FROM #PercentPopulationVaccinated

--CREATE A VIEW 
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated
AS 
SELECT D.continent,D.location,D.date,D.population,V.new_vaccinations,
SUM(CONVERT (FLOAT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location ,D.date) AS RollingPoepleVaccinated
--(RollingPoepleVaccinated/population)*100
FROM PortfolioProject..CovidVaccinations V
JOIN PortfolioProject..CovidDeaths D
ON D.location=V.location
AND D.date=V.date
WHERE D.continent IS NOT NULL
--AND new_vaccinations= 1000
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated