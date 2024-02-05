select *
from [PORTFOLIO PROJECT].dbo.coviddeaths
where continent is not null
order by 3,4

select *
from [PORTFOLIO PROJECT].dbo.covidvaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [PORTFOLIO PROJECT]..CovidDeaths
order by 1,2

--loking at total cases vs total deaths

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [PORTFOLIO PROJECT]..CovidDeaths
order by 1,2

--looking at total cases vs total deaths at a specific location kenya

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [PORTFOLIO PROJECT]..CovidDeaths
where location like 'Kenya'
order by 1,2

--looking at the total cases vs the population

select location, date, total_cases, population,(total_cases/population)*100 as infectedpercentage
from [PORTFOLIO PROJECT]..CovidDeaths
where location like 'Kenya'
order by 1,2

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as infectedpercentage
from [PORTFOLIO PROJECT]..CovidDeaths
--where location like 'Kenya'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as infectedpercentage
from [PORTFOLIO PROJECT]..CovidDeaths
--where location like 'Kenya'
group by location, population
order by infectedpercentage desc

--looking at countries with highest death count per population

select location, population, max(cast(total_deaths as int)) as highestdeathcount
from [PORTFOLIO PROJECT]..CovidDeaths
--where location like 'Kenya'
where continent is not null
group by location,population
order by highestdeathcount desc


--lets break things down by continent

--showing the continent with the highest death count

select continent, max(cast(total_deaths as int)) as highestdeathcount
from [PORTFOLIO PROJECT]..CovidDeaths
--where location like 'Kenya'
where continent is not null
group by continent
order by highestdeathcount desc


--global numbers

select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [PORTFOLIO PROJECT]..CovidDeaths
where continent is not null
order by deathpercentage desc, date desc

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / sum(new_cases)*100 as deathpercentaage
from [PORTFOLIO PROJECT]..CovidDeaths
--where location like 'Kenya'
where continent is not null
--group by date
order by 1,2

select *
from [PORTFOLIO PROJECT].dbo.CovidDeaths da
join [PORTFOLIO PROJECT].dbo.covidvaccinations vac
on da.location=vac.location
and da.date=vac.date

--looking as total population vs vaccinations

select da.continent, da.location, da.date, da.population, vac.new_vaccinations
from [PORTFOLIO PROJECT].dbo.CovidDeaths da
join [PORTFOLIO PROJECT].dbo.covidvaccinations vac
on da.location=vac.location
and da.date=vac.date
where da.continent is not null
order by 2,3


select da.continent, da.location, da.date, da.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by da.location order by da.location, da.date)as cumulativenewvaccinations
from [PORTFOLIO PROJECT].dbo.CovidDeaths da
join [PORTFOLIO PROJECT].dbo.covidvaccinations vac
on da.location=vac.location
and da.date=vac.date
where da.continent is not null
order by 2,3


-- using CTE

with popvsvac (continent, location, date, population, new_vaccinations, cumulativenewvaccinations)
as
(
select da.continent, da.location, da.date, da.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by da.location order by da.location, da.date)as cumulativenewvaccinations
from [PORTFOLIO PROJECT].dbo.CovidDeaths da
join [PORTFOLIO PROJECT].dbo.covidvaccinations vac
on da.location=vac.location
and da.date=vac.date
where da.continent is not null 
)

select *,( cumulativenewvaccinations/population)*100
from popvsvac

--temptable
drop table if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
(
continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativenewvaccinations numeric
)

insert into #percentpopulationvaccinated
select da.continent, da.location, da.date, da.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations )) over(partition by da.location order by da.location, da.date)as cumulativenewvaccinations
from [PORTFOLIO PROJECT].dbo.CovidDeaths da
join [PORTFOLIO PROJECT].dbo.covidvaccinations vac
on da.location=vac.location
and da.date=vac.date
where da.continent is not null 

select *,(cumulativenewvaccinations/population)*100
from #percentpopulationvaccinated


--creating views to store data for later visualization

create view percentpopulationvaccinated as
select da.continent, da.location, da.date, da.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by da.location order by da.location, da.date)as cumulativenewvaccinations
from [PORTFOLIO PROJECT].dbo.CovidDeaths da
join [PORTFOLIO PROJECT].dbo.covidvaccinations vac
on da.location=vac.location
and da.date=vac.date
where da.continent is not null
--order by 2,3

select*
 from percentpopulationvaccinated

 select*
 from deathpercentage

 




