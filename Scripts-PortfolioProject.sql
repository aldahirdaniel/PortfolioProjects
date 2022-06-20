Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Probabilidad de morir si contraes covid en tu pa�s

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Panama'
order by 1,2

-- Looking at total cases vs population
-- Porcentaje de personas que contrajeron Covid

Select location, date,  population,  total_cases,(total_cases/population)*100 as PercentageWhoGotCovid
from PortfolioProject..CovidDeaths
where location like 'Panama'
order by 1,2

-- Looking at Countries with Highest infection rate compared to population
-- Paises con mayor ratio de infecci�n vs poblaci�n

Select location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected 
from PortfolioProject..CovidDeaths
group by Location, population
order by PercentagePopulationInfected  desc

-- Showing Countries with Highest Death count per population
Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount  desc

-- Showing continent with Highest Death count per population

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount  desc

-- Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ((SUM(cast(new_deaths as int)))/ (SUM(new_cases))) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total population vs vaccinations (using BIGINT)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeaploVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE (common table expression)

WITH PopvsVac (continent, location, date, population, new_vaccionations, RollingPeaploVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeaploVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeaploVaccinated/population)*100
from PopvsVac

-- using views

CREATE VIEW PercentPeopleVaccinated as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeaploVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)

select *
from PercentPeopleVaccinated


