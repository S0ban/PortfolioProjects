Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
Order by 1,2


--Looing at Total Cases vs Population 
-- Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Order by 1,2


-- Looking at Countries with Highest Infection Rate Comapred to population 

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group by location, population
Order by PercentagePopulationInfected desc


-- Showing Countires with Hgihest Death Count per Population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Lets Break Things down by Continent

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by Continent
Order by TotalDeathCount desc



-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group by date
Order by 1,2



-- Looing at Total population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(Vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(Vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,Vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,Vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
