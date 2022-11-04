SELECT *
FROM economies
WHERE country = 'Czech Republic';

SELECT *
FROM czechia_payroll cp
JOIN czechia_payroll_calculation cpc 
ON cp.calculation_code  = cpc.code
JOIN czechia_payroll_unit cpu
ON cp.unit_code = cpu.code
JOIN czechia_payroll_value_type cpvt
ON cp.value_type_code = cpvt.code
JOIN czechia_payroll_industry_branch cpib
ON cp.industry_branch_code = cpib.code;

-- Rostou v průběhu let mzdy ve všech odvětvích?
SELECT value, 
		 payroll_year,
		 industry_branch_code,
		 cpib.name
-- SELECT *
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib
ON cp.industry_branch_code  = cpib.code 
WHERE cp.value_type_code = 5958 AND cp.calculation_code = 100
GROUP BY industry_branch_code, payroll_year
ORDER BY industry_branch_code, payroll_year, payroll_quarter;
