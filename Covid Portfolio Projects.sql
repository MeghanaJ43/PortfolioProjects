 select *
from PortfolioProject..CovidDeathscleaned
where continent is not null
order by 3,4

select location, date , total_cases, new_cases, total_deaths , population
from PortfolioProject..CovidDeathscleaned
where continent is not null
order by 1,2

select location, date , total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeathscleaned
--Where location like '%asia%'
Where continent is not null
order by 1,2 

select location, date , population , total_cases , (total_cases/population)*100 as PercentPolulationInfected
from PortfolioProject..CovidDeathscleaned
--Where location like '%asia%'
Where continent is not null
order by 1,2

select location, population ,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as  PercentPolulationInfected
from PortfolioProject..CovidDeathscleaned
where continent is not null
--where location like '%asia%'
group by Location, Population
order by PercentPolulationInfected desc


select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeathscleaned
--where location like '%asia%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeathscleaned
--where location like '%asia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeathscleaned
--Where location like '%asia%'
Where continent is not null
order by 1,2 

select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(int , vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeathscleaned dea
join PortfolioProject.[dbo].[CovidVaccinations$ExternalData_1] vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

select *
from [dbo].[CovidVaccinations$ExternalData_1]


with PopVsVac(Continent,location, date , population , new_vaccinations,  RollingPeopleVaccinated)
as
(
select dea.continent, dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeathscleaned dea
join PortfolioProject.[dbo].[CovidVaccinations$ExternalData_1] vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathscleaned dea
Join PortfolioProject.[dbo].[CovidVaccinations$ExternalData_1] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathscleaned dea
Join PortfolioProject.[dbo].[CovidVaccinations$ExternalData_1] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



