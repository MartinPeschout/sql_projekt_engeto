# Komentář k projektu

Projekt jsem začal tím, že jsem si prošel všechny tabulky, o kterých byla zmínka v zadání projektu a snažil se pochopit údaje obsažené v jednotlivých sloupcích v každé z nich. Stanovil jsem si postup, že vytvořím jednotlivé query pro odpovědi na zadané otázky a na konec, na základě údajů, které budu potřebovat v těchto jednotlivých dotazích vytvořím konečné tabulky, které měly být součástí projektu. Následně poté, co jsem si opět prohlédl videa se záznamu jsem pochopil že postup měl být opačný, tj. prvně tabulky a z nich získat pomocí query podklady pro odpovědi na zadané otázky. Přepracoval jsem tedy projekt dle tohoto zadání.

## Tvorba tabulky *t_{jmeno}_{prijmeni}_project_SQL_primary_final*

V rámci tohoto úkolu jsem pospojoval tabulky *czechia_price*, *czechia_payroll*, *czechia_payroll_industry_branch* a *czechia_price_category* do jedné tabulky, z které jsem následně získával údaje pro ověření zadaných hypotéz. Tvorba tabulky trvala 2m32s, což s ohledem na mé zkušenosti nedokáži odhadnout, zdali je potřeba tvorbu tabulky optimalizovat či nikoliv.

## Tvorba tabulky *t_{jmeno}_{prijmeni}_project_SQL_secondary_final*

Následně jsem vytvořil druhou požadovanou tabulku, do této tabulky jsem si natáhl pouze sloupce o GDP jednotlivých zemí a procentuální růst GDP pro jednotlivé roky. Nic víc jsem v rámci tohoto projektu nepotřeboval.

## Otázka : Rostou v průběhu let mzdy ve všech odvětvích?

Na základě získaných údajů lze hovořit o tom, že ve všech odvětvích od roku 2006 do roku 2017 vyrostly mzdy. I když rozdílným tempem a ne každým rokem byl přírůstek mezd kladný. Premiantem je odvětví *Kulturní, zábavní a rekreační činnosti*, dále je to odvětví *Zdravotní a sociální péče* a odvětví *Zemědělství, lesnictví, rybářství*. U těchto oborů se jedná o více než 90% navýšení mezd. Naopak k nejmenšímu nárůstu došlo u odvětví *Peněžnictví a pojišťovnictví*, kdy dokonce pětkrát došlo ke snížení mezd a to v letech 2008, 2009, 2012, 2014 a 2016. Na druhou stranu obor *Peněžnictví a pojišťovnictví* patřil v roce 2006 k nejlépe placeným oborům, zatímco obory *Zemědělství, lesnictví, rybářství* a *Kulturní, zábavní a rekreační činnosti* patřily mezi obory s nejmenšími platy a pořadí těchto jmenovaných odvětví se nezměnilo ani v roce 2018 (obor *Peněžnictví a pojišťovnictví* stále patří mezi nejlépe ohodnocené obory, zatímco obory *Zemědělství, lesnictví, rybářství* a *Kulturní, zábavní a rekreační činnosti* jsou na chvostu výše průměrných platů, obor *Zdravotní a sociální péče* se drží dlouhodobě uprostřed tabulky z pohledu průměrných mezd za jednotlivá odvětví).
