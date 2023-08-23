
--Specific SQL Queries for the Tableau Public Visualization



--Fatality % worldwide for Covid


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null 
order by 1,2



-- Death Totals for each continent


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'Upper middle income', 'Lower middle income', 'High income', 'Low income')
Group by location
order by TotalDeathCount desc




--Highest infection rate vs Population


Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PopPercentInfected
from [Portfolio Project]..CovidDeaths
Where continent is not null
group by location, population
order by PopPercentInfected desc


--Highest infection rate vs Population including dates


Select location, population,date, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/MAX(population))*100 as PopPercentInfected
from [Portfolio Project]..CovidDeaths
Where continent is not null
group by location, population,date
order by PopPercentInfected desc