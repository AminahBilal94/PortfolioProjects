--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we will be using

select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where Location like '%Pak%'
and  continent is not null
order by 1,2

--Looking at total cases vs population

select Location, date, total_cases,  population, (total_cases/population)*100 as PercentPoulationInfected
from PortfolioProject..CovidDeaths
--where Location like '%Pak%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select Location,  MAX(total_cases) as HighestInfectionCount,  population, MAX((total_cases/population)*100) as PercentPoulationInfected 
from PortfolioProject..CovidDeaths
--where Location like '%Pak%'
group by population, location
order by PercentPoulationInfected desc

--showing countries with highest death count per population 
select continent, Max(cast(total_deaths as int)) as higestdeathcount
from PortfolioProject..CovidDeaths
where continent is not null
--where Location like '%Pak%'
group by continent
order by higestdeathcount desc

--showing continents with highest death count per population 

select continent, Max(cast(total_deaths as int)) as higestdeathcount
from PortfolioProject..CovidDeaths
where continent is not null
--where Location like '%Pak%'
group by continent
order by higestdeathcount desc

--GLOBAL NUMBERS
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int) ) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100  as DeathPercentage 
from PortfolioProject..CovidDeaths
--where Location like '%Pak%'
WHERE continent is not null
group by date
order by 1,2

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int) ) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100  as DeathPercentage 
from PortfolioProject..CovidDeaths
--where Location like '%Pak%'
WHERE continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination

With PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date=vac.date
-- WHERE dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations
Create View PercentPopulationVaccinated2 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date=vac.date
 WHERE dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated2