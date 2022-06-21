/* Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types*/
select * 
from project..[covid deaths]
where continent is not null
order by 3,4

--select * 
--from project..[covid vaccination]
--order by 3,4

select location, date ,total_cases,new_cases,total_deaths
,population from project..[covid deaths] 
where continent is not null
order by 1,2

-- looking at total cases vs  total deaths

select location, date ,total_cases,total_deaths,
(total_deaths/total_cases)*100 as deathpercentage  from project..[covid deaths] 
where location like '%india%'
and  continent is not null
order by 1,2

-- Total Cases vs Population
-- percentage of population got covid

select location, date ,population,total_cases,
(population/total_cases)*100 as PercentPopulationInfected  from project..[covid deaths] 
where location like '%india%'
and  continent is not null
order by 1,2


-- Countries with Highest Infection Rate compared to Population
 select location, population, MAX (total_cases) as Higestinfectioncount,max (total_cases/population)*100 as
 PercentPopulationInfected from project..[covid deaths]
 group by location,population
 order by PercentPopulationInfected desc


 -- Countries with Highest Death Count per Population
 select location,max(cast (total_deaths as int)) as Totaldeathscount 
 from project..[covid deaths]
 where continent is not null
 group by location
 order by Totaldeathscount desc


 -- BREAKING THINGS DOWN BY CONTINENT

 -- Showing continents with the highest desth count per population


 select continent,max(cast (total_deaths as int)) as Totaldeathscount 
 from project..[covid deaths]
 where continent is not null
 group by continent
 order by Totaldeathscount desc


 --- GLOBAL NUMBERS

select Sum(new_cases) as Total_cases ,sum(cast(new_deaths as int)) as Total_deaths,
sum (cast(new_deaths as int))/sum (new_cases)*100 as deathpercentage  from project..[covid deaths] 
WHERE  continent is not null
--GROUP BY DATE
order by 1,2

-- Total Population vs Vaccinations


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date ) as Rollingpeoplevaccination

from project..[covid deaths] dea
join project..[covid vaccination] vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from project..[covid deaths] dea
join project..[covid vaccination] vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table

DROP Table if exists PopulationVaccinated
Create Table PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from project..[covid deaths] dea
join project..[covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PopulationVaccinated




-- Creating View to store data for later visualizations

Create View presentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from project..[covid deaths] dea
join project..[covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


