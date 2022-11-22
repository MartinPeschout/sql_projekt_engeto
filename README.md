# Komentář k projektu

Projekt jsem začal tím, že jsem si prošel všechny tabulky, o kterých byla zmínka v zadání projektu a snažil se pochopit údaje obsažené v jednotlivých sloupcích v každé z nich. Stanovil jsem si postup, že vytvořím jednotlivé query pro odpovědi na zadané otázky a na konec, na základě údajů, které budu potřebovat v těchto jednotlivých dotazích, vytvořím konečné tabulky, které měly být součástí projektu. Následně poté, co jsem si opět prohlédl videa se záznamu jsem pochopil, že postup měl být opačný, tj. prvně tabulky a z nich získat pomocí query podklady pro odpovědi na zadané otázky. Přepracoval jsem tedy projekt dle tohoto zadání.

## Tvorba tabulky *t_{jmeno}_{prijmeni}_project_SQL_primary_final*

V rámci tohoto úkolu jsem pospojoval tabulky *czechia_price*, *czechia_payroll*, *czechia_payroll_industry_branch* a *czechia_price_category* do jedné tabulky, z které jsem následně získával údaje pro ověření zadaných hypotéz. Tvorba tabulky trvala 2m32s, což s ohledem na mé zkušenosti nedokážu odhadnout, zdali je potřeba tvorbu tabulky optimalizovat či nikoliv.

## Tvorba tabulky *t_{jmeno}_{prijmeni}_project_SQL_secondary_final*

Následně jsem vytvořil druhou požadovanou tabulku, do této tabulky jsem si natáhl pouze sloupce o GDP jednotlivých zemí a procentuální růst GDP pro jednotlivé roky. Nic víc jsem v rámci tohoto projektu nepotřeboval.

## Otázka : Rostou v průběhu let mzdy ve všech odvětvích?

Vytvořil jsem si VIEW *v_czechia_payroll_total_growth_per_years_with_branch* a následně jsem z tohoto přehledu přes SELECT získal potřebné údaje. Na základě těchto údajů lze hovořit o tom, že ve všech odvětvích od roku 2006 do roku 2017 vyrostly mzdy. I když rozdílným tempem a ne každým rokem byl přírůstek mezd kladný. Premiantem je odvětví *Kulturní, zábavní a rekreační činnosti*, dále je to odvětví *Zdravotní a sociální péče* a odvětví *Zemědělství, lesnictví, rybářství*. U těchto oborů se jedná o více než 90% navýšení mezd. Naopak k nejmenšímu nárůstu došlo u odvětví *Peněžnictví a pojišťovnictví*, kdy dokonce pětkrát došlo ke snížení mezd a to v letech 2008, 2009, 2012, 2014 a 2016. Na druhou stranu obor *Peněžnictví a pojišťovnictví* patřil v roce 2006 k nejlépe placeným oborům, zatímco obory *Zemědělství, lesnictví, rybářství* a *Kulturní, zábavní a rekreační činnosti* patřily mezi obory s nejmenšími platy a pořadí těchto jmenovaných odvětví se nezměnilo ani v roce 2018 (obor *Peněžnictví a pojišťovnictví* stále patří mezi nejlépe ohodnocené obory, zatímco obory *Zemědělství, lesnictví, rybářství* a *Kulturní, zábavní a rekreační činnosti* jsou na chvostu výše průměrných platů, obor *Zdravotní a sociální péče* se drží dlouhodobě uprostřed tabulky z pohledu průměrných mezd za jednotlivá odvětví).

## Otázka : Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

V prvé řadě jsme si z tabulky *t_martin_peschout_project_sql_primary_final* vytvořil VIEW *v_czechia_price_category_special_category_code*, který jsem následně spojil s *czechia_payroll*. Výsledky jsou jednoznačně viditelné ve vytvořeném přehledu ve sloupci *Quantity_per_salary*

## Otázka : Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Zde jsem začal vytvoření přehledu *v_czechia_price_avg_price_per_year*, čímž jsem si vypočítal procentuální zvýšení/snížení cen jednotlivých komodit v jednotlivých letech. Následně jsem z výše uvedeného přehledu spočítal celkovou sumu růstu cen a průměr z růstu cen a seřadil QUERY dle průměrné ceny. Vyšlo mi, že nejpomaleji zdražuje položka *Cukr krystalový* (ta dokonce zlevnila) a dále položka *Banány žluté* (nárůst cen o necelé procento).

## Otázka : Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)

Začal jsem opět tvorbou VIEW *v_czechia_payroll_total_growth_per_years* z tabulky *t_martin_peschout_project_sql_primary_final*, čímž jsem získal údaje o růstu mezd v jednotlivých letech. Následně jsem spojil výše získaný přehled s přehledem VIEW *v_czechia_price_avg_price_per_year price* získaným v předchozím dotazu. Z následného dotazu jsem obdržel průměrné ceny potravin, průměrné mzdy v jednotlivých letech a rozdíl průměrných cen potravin a průměrných mezd. Z výsledku je patrné, že k největšímu nárůstu cen potravin v porovnání z nárůstem mezd došlo v roce 2017 (8,42%) a 2012 (6,42%), takže 10% rozdíl nebyl ve sledovaných letech dosažen.
## Otázka : Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem
V rámci přípravy podkladů na zodpovězení tohoto předpokladu jsem využil předchozí VIEW *v_czechia_payroll_total_growth_per_years* a VIEW *v_czechia_price_avg_price_per_year* , které jsem spojil a následně propojil i tabulku *t_martin_peschout_project_sql_secondary_final*. Údaje, které se týkaly mezd a cen potravin ovšem byly až od roku 2007, takže výsledek se týká let 2007 – 2018. Na základě výsledků testové statistiky lze konstatovat, že pro určení závislosti bychom potřebovali znát více dat (vyhodnocovat delší období), nicméně po vložení dat do grafu je patrné, že pohyb hrubého GDP se projeví dříve či později v růstu či poklesu cen potravin a výše mezd.
