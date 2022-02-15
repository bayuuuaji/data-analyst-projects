SELECT *
FROM covid19..deaths
ORDER BY 3,4;

SELECT *
FROM covid19..vaksin
ORDER BY 3,4;



-- Select Data that Will be use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid19..deaths
where continent is not null
ORDER BY 1,2;



-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as "Death Precentage"
FROM covid19..deaths
WHERE location = 'Indonesia'
ORDER BY 1,2;



-- Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as "Population Cases Precentage"
FROM covid19..deaths
WHERE location = 'Indonesia'
ORDER BY 1,2;



-- Countries  with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS "Highest Cases", MAX((total_cases/population))*100 as "Population Infected Precentage"
FROM covid19..deaths
where continent is not null
GROUP BY location, population
ORDER BY 4 desc;



-- Countries with highest death count
SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeaths
FROM covid19..deaths
where continent is not null
GROUP BY location
ORDER BY 2 desc;



-- Average cases
SELECT AVG(total_cases) 
FROM covid19..deaths;



-- Countries that total cases is more than average cases
SELECT location, SUM(total_cases)
FROM covid19..deaths
where continent is not null
and total_cases > (SELECT AVG(total_cases) FROM covid19..deaths)
GROUP BY location
ORDER BY 2 desc;



-- Data per continent
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeaths
FROM covid19..deaths
where continent is not null
GROUP BY continent
ORDER BY 2 desc;



-- Continent with highest death count per population
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeaths
FROM covid19..deaths
where continent is not null
GROUP BY continent
ORDER BY 2 desc;




-- Global Numbers
SELECT SUM(new_cases) as "Total Cases", SUM(CAST(new_deaths as bigint)) as "Total Deaths", SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 as "Death Precentage" 
FROM covid19..deaths
WHERE continent is not null;



-- Total Population vs Vaccinations


	-- Using CTE
	With POPvsVAC (continent, location, date, population, new_vaccinations, TotalVaccinations)
	as
	(
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(bigint, v.new_vaccinations)) OVER (Partition By d.location ORDER BY d.location, d.date) as TotalVaccinations
	FROM covid19..deaths d
	JOIN covid19..vaksin v
	ON v.location = d.location
	and v.date = d.date
	WHERE d.continent is not null
	--,ORDER BY 2,3
	)
	SELECT *, (TotalVaccinations/population) * 100 as "Total Vaccinations Precentage" 
	FROM POPvsVAC
	ORDER BY 2,3;



	-- Temp Table
	DROP TABLE if exists #PercentPopulationVaccinated
	CREATE TABLE #PercentPopulationVaccinated
	(
	continent nvarchar(255), 
	location nvarchar(255), 
	date datetime, 
	population numeric, 
	new_vaccinations numeric, 
	TotalVaccinations numeric
	)

	Insert into #PercentPopulationVaccinated
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(bigint, v.new_vaccinations)) OVER (Partition By d.location ORDER BY d.location, d.date) as TotalVaccinations
	FROM covid19..deaths d
	JOIN covid19..vaksin v
	ON v.location = d.location
	and v.date = d.date
	WHERE d.continent is not null
	--,ORDER BY 2,3

	SELECT *, (TotalVaccinations/population) * 100 as "Total Vaccinations Precentage" 
	FROM #PercentPopulationVaccinated
	ORDER BY 2,3;


-- VIEW
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CONVERT(bigint, v.new_vaccinations)) OVER (Partition By d.location ORDER BY d.location, d.date) as TotalVaccinations
	FROM covid19..deaths d
	JOIN covid19..vaksin v
	ON v.location = d.location
	and v.date = d.date
	WHERE d.continent is not null
	--,ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated;