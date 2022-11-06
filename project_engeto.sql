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
	


		