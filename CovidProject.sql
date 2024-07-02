

select * from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--select * from Portfolioproject..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--looking at the total cases VS total death

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percent
from Portfolioproject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--Looking at Total cases VS population
--Show what % ofpopulation got covid

select location,date,population,total_cases,(total_cases/population)*100 as percent_population_infected
from Portfolioproject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--Looking at country with higest Infection Rate compared to Popultaion

select location,population,max(total_cases)as Higest_Covid_Count,max((total_cases/population))*100 as percent_population_infected
from Portfolioproject..CovidDeaths
--where location like '%India%'
where continent is not null
group by location,population
order by percent_population_infected desc

--Showing Country with higest death count per population

select location,max(cast(total_deaths as int)) as Death_count
from Portfolioproject..CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by Death_count desc

--SHOWING CONTINENT WITH THE HIGEST DEATH COUNT

select continent,max(cast(total_deaths as int)) as Death_count
from Portfolioproject..CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by Death_count desc

--GLOBAL NUMBERS

select sum(new_cases) as Total_New_Cases,sum(cast(new_deaths as int)) as Total_New_Death,
(sum(cast(new_deaths as int)) / sum(new_cases))*100 as Death_Percent
from Portfolioproject..CovidDeaths
--where location like '%India%'
where continent is not null
--group by date
order by 1,2

--Looking total popultaion vs vaccination

Select d.continent,d.location,d.date,d.population,v.new_vaccinations from
Portfolioproject..CovidDeaths d
join 
Portfolioproject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 1,2,3

--Looking for Total vactination by date and location

Select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
sum(CONVERT(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as Rolling_Vaccination_Count
from
Portfolioproject..CovidDeaths d
join 
Portfolioproject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 1,2,3

 --USE CTE

 with PopvsVac (Continent,location,date,population,new_vaccinations,Rolling_Vaccination_Count) as
 (
 Select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
sum(CONVERT(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as Rolling_Vaccination_Count
from
Portfolioproject..CovidDeaths d
join 
Portfolioproject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
--where d.continent is not null
--order by 1,2,3
)
select *,(Rolling_Vaccination_Count/population)*100 as Rolling_Vaccination_Percent from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Vaccination_Count numeric
)

Insert into #PercentPopulationVaccinated
 Select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
sum(CONVERT(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as Rolling_Vaccination_Count
from
Portfolioproject..CovidDeaths d
join 
Portfolioproject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
--where d.continent is not null
--order by 1,2,3

Select *, (Rolling_Vaccination_Count/Population)*100
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
sum(CONVERT(int,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as Rolling_Vaccination_Count
from
Portfolioproject..CovidDeaths d
join 
Portfolioproject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
--where d.continent is not null