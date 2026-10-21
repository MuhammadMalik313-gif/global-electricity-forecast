create table global_elec(
country varchar(30),
year_recorded	date,
GDP_Per_Capita_Current_USD int,
Total_Population int,
Population_Female_Percentage float,
Population_Male_Percentage float,
Electricity_Access_Urban_Percentage float,
Electricity_Access_Rural_Percentage float ,
Total_Electricity_Output_GWh float
);

select * from global_elec
from


-- Column ko TEXT rakh kar import karein, phir convert karein
 ALTER TABLE global_elec 
ALTER COLUMN year_recorded TYPE DATE 
USING TO_DATE(year_recorded::TEXT, 'YYYY');

alter table global_elec drop column year_recorded
alter table global_elec add column year_recorded integer

-- Agar table khaali hai (import fail hua tha, koi data nahi gaya)
ALTER TABLE global_elec DROP COLUMN gdp_per_capita_current_usd;
ALTER TABLE global_elec ADD COLUMN gdp_per_capita_current_usd DECIMAL(15,4);


ALTER TABLE global_elec 
ALTER COLUMN total_population TYPE BIGINT;


ALTER TABLE global_elec 
ALTER COLUMN country TYPE VARCHAR(100);




select * from global_elec

ALTER TABLE global_elec 
ALTER COLUMN year_recorded TYPE DATE 
USING TO_DATE(year_recorded::TEXT, 'YYYY');

q#1 country waise total population
select country,
      			sum(total_population)as country_waise_total_population
from global_elec
group by country

q2
select country,
				avg(Population_male_Percentage) as Male,
				avg(Population_Female_Percentage) as female

from global_elec
group by country

q3


select country,
				AVG(Electricity_Access_Urban_Percentage) AS Average_Urban,
				AVG(Electricity_Access_Urban_Percentage) /
				SUM(AVG(Electricity_Access_Urban_Percentage)) OVER () AS Urban_Ratio,
				
				avg(Electricity_Access_Rural_Percentage )as Average_Rural,
				avg((Electricity_Access_Rural_Percentage)
				/
				sum(avg((Electricity_Access_Rural_Percentage)) OVER() AS Rural_Ratio,
				
				 AVG(Total_Electricity_Output_GWh) AS Total_Output_Electricity,
     			 AVG(Total_Electricity_Output_GWh) /
     			 SUM(AVG(Total_Electricity_Output_GWh)) OVER () AS Electricity_Ratio
FROM global_elec
group by country


SELECT
    country,

    AVG(Electricity_Access_Urban_Percentage) AS Average_Urban,
    AVG(Electricity_Access_Urban_Percentage)
    / SUM(AVG(Electricity_Access_Urban_Percentage)) OVER () AS Urban_Ratio,

    AVG(Electricity_Access_Rural_Percentage) AS Average_Rural,
    AVG(Electricity_Access_Rural_Percentage)
    / SUM(AVG(Electricity_Access_Rural_Percentage)) OVER () AS Rural_Ratio,

    AVG(Total_Electricity_Output_GWh) AS Total_Output_Electricity,
    AVG(Total_Electricity_Output_GWh)
    / SUM(AVG(Total_Electricity_Output_GWh)) OVER () AS Electricity_Ratio

FROM global_elec
GROUP BY country;


select year_recorded,
				 AVG(Electricity_Access_Urban_Percentage) AS Average_Urban,
				  AVG(Electricity_Access_Rural_Percentage) AS Average_Rural,
from global_elec
group by year_recorded


select year_recorded,
				 AVG(Electricity_Access_Urban_Percentage) 
				 + AVG(Electricity_Access_Rural_Percentage) /2 as total_use_avg
				   
from global_elec
group by year_recorded

select country,
            sum(GDP_Per_Capita_Current_USD)*sum(total_population)as total_amount_gpd
from global_elec
group by country

cte
with  total_amount_pop as ( select
			country,
            sum(GDP_Per_Capita_Current_USD)*sum(total_population)as total_amount_gpd,
			
from global_elec
group by country
)


select  country,total_amount_gpd,
				rank ()over (order by total_amount_gpd desc ) as rnk
from total_amount_pop m


with  total_amount_pop as ( select
			country,
            sum(GDP_Per_Capita_Current_USD)*sum(total_population)as total_amount_gpd
			
			from global_elec
			group by country
)


select  country,total_amount_gpd,
				rank ()over (order by total_amount_gpd desc ) as rnk
from total_amount_pop


select country ,
			sum(total_population) as total_population,
			avg(Population_male_Percentage ) as Male_avg_population,
			avg(Population_Female_Percentage ) as Female_population,
			avg(Electricity_Access_Urban_Percentage) as Urban_Areas,
			avg(Electricity_Access_Rural_Percentage ) as Rural_Areas,
			sum(GDP_Per_Capita_Current_USD) AS Total_gpd
from global_elec
group by country



with avg_out as ( select country,
								AVG (Total_Electricity_Output_GWh) as avg_output,
								avg(GDP_Per_Capita_Current_USD) AS avg_gpd
								from global_elec
								where GDP_Per_Capita_Current_USD between 1000 and 20000 and 
								(Electricity_Access_Urban_Percentage > 80 or Electricity_Access_Rural_Percentage > 80)
 								group by country

)
select country,avg_output,avg_gpd
from avg_out
where avg_output>(select avg(avg_output)from avg_out)



with avg_out as ( select country,
								AVG (Total_Electricity_Output_GWh) as avg_output,
								avg(GDP_Per_Capita_Current_USD) AS avg_gpd
								from global_elec
								where GDP_Per_Capita_Current_USD between 1000 and 20000 and 
								(Electricity_Access_Urban_Percentage > 80 or Electricity_Access_Rural_Percentage > 80)
 								group by country

)
select country,avg_output,avg_gpd,
						rank() over(order by avg_output desc ) as rnk  
from avg_out
where avg_output>(select avg(avg_output)from avg_out)
order by avg_output desc
limit 5









