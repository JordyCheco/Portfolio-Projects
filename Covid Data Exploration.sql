Select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--  The Data that We will be focuing on 
Select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths in the United States
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Total Cases vs Population in the United States
-- Shows the precentage of the population that got covid
Select Location, Date, population, total_cases, ( total_cases/population)* 100 as PrecentPopulationInfected 
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with Hightest Infection Rate Compared to Population
Select Location, population, MAX (total_cases) as PeakInfectionCount, Max(( total_cases/population))* 100 as PrecentPopulationInfected 
from PortfolioProject..CovidDeaths
Group By Location, population
order by PrecentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By Location
order by  TotalDeathCount desc


-- Showing the continets with the hightest Death counts
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By continent
order by  TotalDeathCount desc

-- Global Numbers
Select Date, Sum(new_cases) as total_cases,Sum(cast(new_deaths as int))as total_deaths, Sum(cast(new_deaths as int))/Sum(New_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by Date
order by 1,2

--Comparing total Population to Vaccinations
Select dea.continent, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
Order by 2,3

--CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table 
Drop Table if exists  #PercentPopulationVaccinated
Create table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store Data for later Visualizations

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


