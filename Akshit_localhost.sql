--select statements:
select * from coviddeaths 
where rownum <= 20
order by 3,4;

select * from covidvaccinations 
where rownum <= 20
order by 3,4;