select * from [Portfolio project]..CovidDeaths$ order by 3 ,4 ;
--select * from [Portfolio project]..Covidvaccination$ order by 3 ,4 ;
--select the Data that we are going to use


select location, date, total_cases, new_cases, total_deaths, population from [Portfolio project]..CovidDeaths$ order by 1,2;
-- Looking at Total cases VS Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage  from [Portfolio project]..CovidDeaths$ 
where continent is not null
order by 1,2;


-- Looking Total_cases vs Total_deaths at US
-- show the percentage of deaths in united states

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage  from [Portfolio project]..CovidDeaths$ 
WHERE location like '%states%' order by 1,2;

-- Looking At Total caes VS Total Population
-- show the percentage of popoulation who got covidcases
select location, date, total_cases, population, (total_cases/population)*100 as Cases_percentage from [Portfolio project]..CovidDeaths$
where continent is not null order by 1,2;


--2
-- EUROPEAN UNION IS A PART OF EUROPE
select location,sum(cast(new_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is  null
and location not in('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc;


--3
-- looking at countries  with highest infection count compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercetageOfPopulationInfected  from [Portfolio project]..CovidDeaths$
  where continent is not null 
 group by location, population
 order by PercetageOfPopulationInfected desc;
  --4
  select location, population, date,  max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercetageOfPopulationInfected  from [Portfolio project]..CovidDeaths$
  where continent is not null 
 group by location, population, date
 order by PercetageOfPopulationInfected desc;


  -- showing countries with highest deathcount compared to population
 select location, population, max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/population))*100 as percentageofpopulationDEAD
from [Portfolio project]..CovidDeaths$
where continent is not null
group by location, population
order by percentageofpopulationDEAD desc;
 
 -- showing  locations with highest death count compared to population
  select location, max(cast(total_deaths as int)) as HighestDeathCount from [Portfolio project]..CovidDeaths$
  where continent is not null
  group by location
  order by HighestDeathCount desc;

  --Lets Break Things by continent
  -- showing   continents with highest death count compared to population
  select continent, max(cast(total_deaths as int)) as HighestDeathCount from [Portfolio project]..CovidDeaths$
  where continent is not null
  group by continent
  order by HighestDeathCount desc;

  --1

  -- Global Numbers
 select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage  from [Portfolio project]..CovidDeaths$ 
--WHERE location like '%states%'
where continent is not null
--group by date
order by 1,2;

select * from [Portfolio project]..CovidDeaths$ dea
join
[Portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date;

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,sum(convert(int,vac.new_vaccinations))  over (partition by dea.location)  as total_vaccinations from [Portfolio project]..CovidDeaths$ dea
join
[Portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


-- giving some order to partition by location and date
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,sum(convert(int,vac.new_vaccinations))  over (partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated from [Portfolio project]..CovidDeaths$ dea
join
[Portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,sum(convert(int,vac.new_vaccinations))  over (partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated from [Portfolio project]..CovidDeaths$ dea
join
[Portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3;
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
Drop Table if exists  #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into  #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,sum(convert(int,vac.new_vaccinations))  over (partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated from [Portfolio project]..CovidDeaths$ dea
join
[Portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3;
Select *, (RollingPeopleVaccinated/Population)*100 as Rollimgpeople_vaccinatedpercentage
From #percentagepopulationvaccinated


-- Create a view for later visualization
create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,sum(convert(int,vac.new_vaccinations))  over (partition by dea.location order by dea.location, dea.date)  as RollingPeopleVaccinated from [Portfolio project]..CovidDeaths$ dea
join
[Portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3;
select * from percentagepopulationvaccinated;