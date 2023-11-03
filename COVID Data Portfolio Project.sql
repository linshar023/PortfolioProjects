SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Updating course above to remove continents that are under location column
-- Using is not null because becasue when it is null that means the location is an enitre continent which we do not want

SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- To get a percent multiply by 100
-- as = alias
-- Below shows likliehood of dying if you contract covid in your country
-- Can use 'and' with multiple 'where'

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
ORDER BY 1,2


-- Looking at Countries with highest infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
Group by location, population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
-- If nvarchar, use cast()

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
Where continent is not null
Group by location
ORDER BY TotalDeathCount desc

-- NOW WE'LL BREAK THINGS DOWN BY CONTINENT
-- The correct way is below

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
Where continent is null
Group by location
ORDER BY TotalDeathCount desc

-- Reverting back to continent to be able to practice in Tableau but know the above script is the correct way

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

--	GLOBAL NUMBERS
-- Dive into aggregate functions

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%' 
Where continent is not null
Group by date
ORDER BY 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%' 
Where continent is not null
--Group by date
ORDER BY 1,2

--Pulling up covid vaccinations chart

Select *
From PortfolioProject..CovidVaccinations

-- Joining both tables together
-- Looking at total population vs vaccination
-- Can use Cast(...as int) OR Convert (bigint, ...)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
-- Will get an error if the number of columns in 'with' do not match the columns in 'select'

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

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
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated