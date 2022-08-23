Select *
FROM PortfolioProject..CovidDeaths
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
order by 1,2

--total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 As Case_Percentage
From PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

--highest infection rate
Select location, population, MAX(total_cases), MAX((total_cases/population))*100 As Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
where continent is not NULL				--this condition is used because in some cases continent is empty and hence the query is pulling the data that is not required.
group by location, population
order by Percent_Population_Infected DESC

--highest death rate
Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by Total_Death_Count DESC


--sorting by continent
Select continent,  MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by Total_Death_Count DESC

--global numbers

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not NULL
group by date 
order by 1,2

--total population vs vaccinations

--using cte
With PopvsVac (Continent, location, date, Population, New_Vaccinations, Cummulative_Vaccination)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as Cummulative_Vaccination
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not NULL
--and dea.location = 'Canada' and vac.new_vaccinations is not null
--order by 2,3
)
Select *,(Cummulative_Vaccination/Population)*100 as Percentage
From PopvsVac
where location = 'Australia'

--temp table
DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Cummulative_Vaccination numeric
)
Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as Cummulative_Vaccination
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not NULL

Select *,(Cummulative_Vaccination/Population)*100 as Percentage
From #Percent_Population_Vaccinated

--Creating view to store data

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as Cummulative_Vaccination
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not NULL

Select *
From Percent_Population_Vaccinated