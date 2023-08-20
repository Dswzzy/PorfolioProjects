Select * 
FROM [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4


--Select * 
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

--Percentage of deaths vs total cases
select location, date, total_cases, total_deaths, (cast(total_deaths as decimal(12,2)) / (cast(total_cases as int)))*100 as DeathPercent
from [Portfolio Project]..CovidDeaths
where location like '%state%'
and continent is not null
order by 1,2

--Shows what Percentage of US population got covid
Select location, date, total_cases, population, (cast(total_cases as int)/ population)* 100 as PopPercentInfected
from [Portfolio Project]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PopPercentInfected
from [Portfolio Project]..CovidDeaths
Where continent is not null
group by location, population
order by PopPercentInfected desc


--data of the highest death count per population based by country

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Changing data conversions from country to continent

--Total Death Counts via Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Data showing the global numbers of covid cases per day 

Select date, SUM(new_cases) as 'global per day'
from [Portfolio Project]..CovidDeaths
group by date
order by 1,2

--Global death % which shows the global covid fatality rate.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null 
order by 1,2

--Joining together data from tables 'CovidDeath' and 'CovidVaccinations'/ hospital data

Select * 
from [Portfolio Project]..CovidDeaths death
Join [Portfolio Project]..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date

-- Data showing the total population and how vaccinations per day

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
from [Portfolio Project]..CovidDeaths death
Join [Portfolio Project]..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 1,2,3

--Rolling Count of Vaccinations per day by Country

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingCountVaccinated
from [Portfolio Project]..CovidDeaths death
Join [Portfolio Project]..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 1,2,3

--Creating a CTE to find total people vaccinated vs population

With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingCountVaccinated
from [Portfolio Project]..CovidDeaths death
Join [Portfolio Project]..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PopvsVac
order by 2,3


--Using a Temporary Table

Drop Table if exists PercentPopulationVax
Create Table PercentPopulationVax
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVax
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingCountVaccinated
from [Portfolio Project]..CovidDeaths death
Join [Portfolio Project]..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 1,2,3
Select*, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from PercentPopulationVax


--Visualization Create View

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingCountVaccinated
from [Portfolio Project]..CovidDeaths death
Join [Portfolio Project]..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null


Create View RollingCount as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingCountVaccinated
from [Portfolio Project]..CovidDeaths death
Join [Portfolio Project]..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null


Create View HighestCountCountry as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location


Create View DeathCountPerContinent as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent

