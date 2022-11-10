SELECT
	*
FROM
	economies
WHERE
	country = 'czech republic';

SELECT
	*
FROM
	czechia_payroll cp
JOIN czechia_payroll_calculation cpc 
ON
	cp.calculation_code = cpc.code
JOIN czechia_payroll_unit cpu
ON
	cp.unit_code = cpu.code
JOIN czechia_payroll_value_type cpvt
ON
	cp.value_type_code = cpvt.code
JOIN czechia_payroll_industry_branch cpib
ON
	cp.industry_branch_code = cpib.code;


-- Rostou v průběhu let mzdy ve všech odvětvích?
SELECT
	cp.value, 
	cp.payroll_year,
	cp.industry_branch_code,
	cpib.name
FROM
	czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
ON
	cp.industry_branch_code = cpib.code
WHERE
	cp.value_type_code = 5958
GROUP BY
	cp.payroll_year,
	cp.industry_branch_code
ORDER BY
	cp.industry_branch_code,
	cp.payroll_year;
	
-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

CREATE OR REPLACE VIEW v_czechia_price_category_special_category_code AS
SELECT 
		cp.category_code,
		cpc.name,
		cp.value,
		cpc.price_unit,
		YEAR (cp.date_from),
		cp.date_from, 
		round(avg(cp.value), 2) average
	FROM 
		czechia_price cp
	JOIN
		czechia_price_category cpc
	ON
		cp.category_code = cpc.code
	WHERE
		cp.region_code IS NULL AND
		cp.category_code IN (111301,114201)
	GROUP BY YEAR (cp.date_from), cpc.name
	ORDER BY name, cp.date_from DESC

SELECT 
	czp.payroll_year Observed_year,
	cpc.category_code Goods,
	cpc.name Name_of_goods,
	czp.value Salary,
	cpc.average Average_price_good,
	round(czp.value / cpc.average,0) Quantity_per_salary
FROM
	czechia_payroll czp
JOIN v_czechia_price_category_special_category_code cpc
ON
	czp.payroll_year = cpc.`YEAR (cp.date_from)` 
WHERE
	czp.value_type_code  = 5958 AND
	czp.payroll_year IN (2006,2018)
GROUP BY czp.payroll_year, cpc.name;

-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

CREATE OR REPLACE VIEW v_czechia_price_avg_price_per_year AS
	SELECT 
		category_code,
		AVG (value), 
		YEAR (date_from)
	FROM 
		czechia_price
	GROUP BY 
		YEAR (date_from), category_code;

SELECT
		cp1.category_code,
		cp1.`YEAR (date_from)`  year_basic,
		cp2.`YEAR (date_from)`,
		cp2.`YEAR (date_from)` + 1 year_prev,
		cp1.`AVG (value)`,
		cp2.`AVG (value)`,
		round ((cp1.`AVG (value)` - cp2.`AVG (value)`)/cp2.`AVG (value)`*100, 2) price_growth
	FROM 
		v_czechia_price_avg_price_per_year cp1
	JOIN 
		v_czechia_price_avg_price_per_year cp2
		ON cp1.category_code  = cp2.category_code 
			AND cp1.`YEAR (date_from)` = cp2.`YEAR (date_from)` + 1
	GROUP BY category_code , `YEAR (date_from)`;
	
CREATE OR REPLACE VIEW v_czechia_price_comparison_growth_per_code AS	
SELECT
		cp1.category_code code,
		cp1.`YEAR (date_from)`  year_basic,
		cp2.`YEAR (date_from)` start_year,
		cp2.`YEAR (date_from)` + 1 year_prev,
		cp1.`AVG (value)` AVG1,
		cp2.`AVG (value)` AVG2,
		round ((cp1.`AVG (value)` - cp2.`AVG (value)`)/cp2.`AVG (value)`*100, 2) price_growth
		FROM 
			v_czechia_price_avg_price_per_year cp1
		JOIN 
			v_czechia_price_avg_price_per_year cp2
			ON cp1.category_code  = cp2.category_code 
				AND cp1.`YEAR (date_from)` = cp2.`YEAR (date_from)` + 1
		GROUP BY 
			code, year_basic
			
SELECT 
	cpg.code code_product,
	cpc.name name_product,
	SUM(price_growth) sum_growth
FROM 
	v_czechia_price_comparison_growth_per_code cpg
JOIN 
	czechia_price_category cpc
ON 
 	cpg.code = cpc.code
GROUP BY cpg.code
ORDER BY sum_growth;
		
-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

CREATE OR REPLACE VIEW v_czechia_price_growth_food_per_years AS
SELECT
	cpg.code code_product,
	cpc.name name_product,
	SUM(price_growth) sum_growth,
	year_basic
FROM 
	v_czechia_price_comparison_growth_per_code cpg
JOIN 
	czechia_price_category cpc
ON 
 	cpg.code = cpc.code
GROUP BY cpg.code , cpg.year_basic
ORDER BY cpg.year_basic;

CREATE OR REPLACE VIEW v_czechia_price_total_growth_food_per_years AS
SELECT 
	year_basic,
	round (avg(sum_growth),2) average_growth_price_food
FROM v_czechia_price_growth_food_per_years 
GROUP BY year_basic;


CREATE OR REPLACE VIEW v_czechia_payroll_total_growth_per_years AS
SELECT
	cpay1.payroll_year basic_year,
	cpay2.payroll_year+1 next_year,
	cpay1.value basic_value,
	LEAD (cpay2.value,1) OVER (ORDER BY cpay2.payroll_year) next_value,
	round ((((LEAD (cpay2.value,1) OVER (ORDER BY cpay2.payroll_year)) - cpay1.value) / cpay1.value) * 100,2) payroll_growth
FROM
	czechia_payroll cpay1
JOIN 
	czechia_payroll cpay2
	ON cpay1.id  = cpay2.id 
WHERE
	cpay1.value_type_code = 5958
GROUP BY
	cpay1.payroll_year;
	

SELECT
	payroll.basic_year,
	payroll.payroll_growth,
	price.average_growth_price_food food_growth,
	price.average_growth_price_food - payroll.payroll_growth difference_food_price
FROM 
	v_czechia_payroll_total_growth_per_years payroll
RIGHT JOIN 
	v_czechia_price_total_growth_food_per_years price
ON 
	payroll.basic_year = price.year_basic
ORDER BY difference_food_price DESC;


/* Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem */

CREATE OR REPLACE VIEW v_czechia_GDP_total_growth_per_years AS
SELECT
	e1.`year` bacic_year,
	e1.`year` + 1 next_year,
	e1.GDP basic_GDP,
	LEAD (e1.GDP,1) OVER (ORDER BY e1.`year`) next_GDP,
	round((((LEAD (e1.GDP,1) OVER (ORDER BY e1.`year`))-e1.GDP) / e1.GDP ) * 100,2) GDP_growth
FROM economies e1
JOIN (SELECT * FROM economies WHERE country = 'Czech republic' AND GDP is not NULL) e2
ON e1.`year`  = e2.`year`
WHERE e1.country = 'Czech republic' AND e1.GDP is not NULL
ORDER BY e1.`year`

SELECT
payroll.basic_year,
GDP.GDP_growth,
payroll.payroll_growth,
price.average_growth_price_food price_growth
FROM v_czechia_payroll_total_growth_per_years payroll
RIGHT JOIN v_czechia_price_total_growth_food_per_years price
ON payroll.basic_year = price.year_basic
LEFT JOIN v_czechia_gdp_total_growth_per_years GDP
ON payroll.basic_year = GDP.bacic_year
