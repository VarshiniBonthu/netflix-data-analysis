drop table if exists netflix;
create table netflix
(show_id varchar(10),
type varchar(10),
title varchar(150),
director varchar(250),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(250)
);

select * from netflix;

--1 . count no of movies and tv shows

select type,count(type)
from netflix
group by type;

--2. most common rating for movies and TV shows
select type,rating from(
select type , rating , count(*),
rank() over(partition by type order by count(*) desc)
from netflix
group by type,rating
order by type,count(*) desc)
where rank=1;

--3.list all movies released in 2020

select release_year,type, title from netflix
where type = 'Movie'
and
release_year=2020;

--4.find top 5 countries acc to content
update netflix
set country=replace(country,' ','');


select new_country,count(*) as no_of_movies 
from(select
    unnest(string_to_array(country, ',')) as new_country
	from netflix)
group by new_country
having new_country is not null
order by count(*) desc
limit 5;

--5. find the longest movie by duration

select * from 
 (select distinct title as movie,
  split_part(duration,' ',1):: numeric as duration 
  from netflix
  where type ='Movie')
where duration = (select max(split_part(duration,' ',1):: numeric ) from netflix);

--6.find content added in last 5 years

select *
from netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';

--7. find all items directed by 'rajiv chilaka'

select * from netflix
where director like '%Rajiv Chilaka%';

--8. list all tv shows with more than 5 seasons

select * 
from netflix
where type='TV Show'
and
split_part(duration,' ',1)::numeric >= 5;

--9.list content in each genre

update netflix
set listed_in=replace(listed_in,' ','');

select all_genres,count(*) 
from (select 
unnest(string_to_array(listed_in,',')) as all_genres
from netflix)
group by all_genres;


--10.find avg number of content released by india on netflix and 
--return top 5 year with highest avg content release

select extract(year from to_date(date_added,'month dd, yyyy')) as year,
count(*),
count(*)::numeric/(select count(*) 
                 from netflix 
				 where country='India')::numeric*100 as avg_cont
from netflix
where country='India'
group by year;

--11.list all movies which are documentaries

select * from netflix
where listed_in like '%Documentaries%'
and
type='Movie';

--12.find all movies and tv shows without a director

select type,count(*) from netflix
where director is null
group by type;

--13.find how many movies salman khan appeared in last 10 years

select count(*) from (select casts,count(*) from netflix
where casts like '%Salman Khan%'
and
release_year> extract(year from current_date)-10
group by casts);


 --14. find top 10 actors who have passed in the highest no of movies made in india

 update netflix
 set casts=replace(casts,' ','');

 select ind_actors,count(*) from(select 
 unnest(string_to_array(casts,',')) as ind_actors from netflix
 where country='India')
 group by ind_actors
 order by count desc
 limit 10;

 --15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords as good and bad

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
