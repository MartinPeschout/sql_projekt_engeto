/* Tabulky pojmenujte t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin
 * za Českou republiku sjednocených na totožné porovnatelné období – společné roky)*/

CREATE OR REPLACE TABLE t_martin_peschout_project_SQL_primary_final AS
SELECT 
	cp.category_code,
	cp.value value1,
	cp.date_from,
	cp.region_code,
	cpay.value,
	cpay.payroll_year,
	cpay.industry_branch_code,
	cpay.value_type_code,
	cpayib.name name1,
	cpc.name,
	cpc.price_unit 
FROM 
	czechia_price cp
JOIN 
	czechia_payroll cpay
ON 
   YEAR(cp.date_from) = cpay.payroll_year AND
   cpay.value_type_code = 5958
LEFT JOIN
  	czechia_payroll_industry_branch cpayib
ON
  	cpayib.code = cpay.industry_branch_code
LEFT JOIN 
  	czechia_price_category cpc
ON 
  	cp.category_code = cpc.code;
  
  
/* ------------------------------------------------------------------------------------------------------------------------------------------------------*/
  
/* t_martin_peschout_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech) */
  
CREATE OR REPLACE table t_martin_peschout_project_SQL_secondary_final AS
SELECT
	country,
	`year` bacic_year,
	`year` + 1 next_year,
	GDP basic_GDP,
	LEAD (GDP,1) OVER (PARTITION BY country ORDER BY country, `year`) next_GDP,
	round((((LEAD (GDP,1) OVER (PARTITION BY country ORDER BY country, `year`))-GDP) / GDP ) * 100,2) GDP_growth
FROM 
	economies
WHERE
	GDP is not NULL
ORDER BY
	country , `year`;

/* ------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Rostou v průběhu let mzdy ve všech odvětvích?

CREATE OR REPLACE VIEW v_czechia_payroll_total_growth_per_years_with_branch AS 
SELECT 
	value,
	payroll_year,
	industry_branch_code,
	name1
FROM 
	t_martin_peschout_project_sql_primary_final
WHERE 
	value_type_code = 5958 AND industry_branch_code IS NOT NULL
GROUP BY 
	payroll_year,
	industry_branch_code
ORDER BY 
	industry_branch_code,
	payroll_year;

SELECT 
	payroll_year,
	industry_branch_code,
	name1,
	value,
	LEAD (value,1) OVER (PARTITION BY industry_branch_code ORDER BY industry_branch_code, payroll_year) next_value,
	round ((((LEAD (value,1) OVER (PARTITION BY industry_branch_code ORDER BY industry_branch_code, payroll_year)) - value) / value) * 100,2) payroll_growth
FROM
	v_czechia_payroll_total_growth_per_years_with_branch;


/* ------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

CREATE OR REPLACE VIEW v_czechia_price_category_special_category_code AS
SELECT 
	category_code,
	name,
	value1,
	price_unit,
	YEAR (date_from) YEAR1
FROM 
	t_martin_peschout_project_sql_primary_final 
WHERE 
	region_code IS NULL AND
	category_code IN (111301,114201)
GROUP BY
	YEAR (date_from), name
ORDER BY
	name, date_from DESC;
	
SELECT 
	czp.payroll_year Observed_year,
	cpc.category_code Goods,
	cpc.name Name_of_goods,
	czp.value Salary,
	cpc.value1,
	ROUND (czp.value / cpc.value1,0) Quantity_per_salary,
	cpc.price_unit
FROM
	czechia_payroll czp
JOIN 
	v_czechia_price_category_special_category_code cpc
ON
	czp.payroll_year  = cpc.YEAR1 
WHERE
	czp.value_type_code  = 5958 AND
	czp.payroll_year IN (2006,2018)
GROUP BY czp.payroll_year, cpc.name;

/* ------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
	
CREATE OR REPLACE VIEW v_czechia_price_avg_price_per_year AS
SELECT 
	YEAR (date_from),
	category_code,
	name,
	value1,
	LEAD (value1,1) OVER (PARTITION BY category_code ORDER BY category_code, YEAR (date_from)) next_value,
	ROUND ((((LEAD (value1,1) OVER (PARTITION BY category_code  ORDER BY category_code, YEAR (date_from))) - value1) / value1) * 100,2) price_growth
FROM 
	t_martin_peschout_project_sql_primary_final
WHERE 
	region_code IS NULL
GROUP BY 
	category_code, YEAR (date_from);
			
SELECT 
	category_code, 
	name, 
	SUM (price_growth), 
	AVG (price_growth)
FROM 
	v_czechia_price_avg_price_per_year
GROUP BY
	category_code
ORDER BY 
	AVG (price_growth);

/* ------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

CREATE OR REPLACE VIEW v_czechia_payroll_total_growth_per_years AS
SELECT
	payroll_year basic_year,
	payroll_year+1 next_year,
	value basic_value,
	LEAD (value,1) OVER (ORDER BY payroll_year) next_value,
	round ((((LEAD (value,1) OVER (ORDER BY payroll_year)) - value) / value) * 100,2) payroll_growth
FROM
	t_martin_peschout_project_sql_primary_final  
WHERE
	value_type_code = 5958
GROUP BY
	payroll_year;

SELECT 
	payroll.basic_year year_of_measurement,
	payroll.payroll_growth average_payroll,
	ROUND (AVG (price.price_growth),2) average_price_food,	
	ROUND (AVG (price.price_growth),2) - payroll_growth difference_food_price 
FROM 
	v_czechia_payroll_total_growth_per_years payroll
RIGHT JOIN 
	v_czechia_price_avg_price_per_year price
ON 
	payroll.basic_year  = price.`YEAR (date_from)`
GROUP BY 
	payroll.basic_year
ORDER BY 
	difference_food_price DESC;

/* ------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem */

SELECT
	payroll.basic_year year_of_measurement,
	payroll.payroll_growth average_payroll,
	ROUND (AVG (price.price_growth),2) average_price_food,
	gdp.GDP_growth 
FROM 
	v_czechia_payroll_total_growth_per_years payroll
RIGHT JOIN 
	v_czechia_price_avg_price_per_year price
ON 
	payroll.basic_year  = price.`YEAR (date_from)`
LEFT JOIN 
	t_martin_peschout_project_sql_secondary_final GDP
ON 
	payroll.basic_year = GDP.bacic_year
WHERE 
	gdp.country = 'Czech republic' AND 
	gdp.basic_GDP IS NOT NULL
GROUP BY 
	basic_year;


