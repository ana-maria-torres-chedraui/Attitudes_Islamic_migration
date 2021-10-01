
pwd 
global path "C:\Users\t_ana\OneDrive\Documents\Ana Maria\thesis\Dataset Religion"

display "$path"
global logs "$path\logs"

capture log close
log using "logs/thesis.log", replace
set more off


// download from: https://www.pewforum.org/dataset/western-europe-survey-dataset/

import spss using "$path\church tax\Western Europe Public Data_Church Tax Added.sav", clear


describe


******************************************************************************** DESCRIPTIVE STATISTICS ********************************************************************************
codebook Q42d 

**  (QCURRELrec) The answers to religion have been collapsed to protect the confidentiality of respondents. Muslim+Jewish+Buddhist+Hindu+something else responses are collapsed into one category. However, in order to identify the Muslim responses, there is a question Q32b that was asked only to Muslims. So I used responses to question Q32b to filter Muslim responses to Q42d
* Muslim response to Q42d
tab Q42d if Q32b!=.
* Non-Muslim responses to Q42d
tab Q42d if Q32b==.

asdoc tab Q42d if Q32b==.,m title(Feelings of threat of non-Muslims in Western Europe) save(summary_statistics2.doc), replace
tab QCURRELrec

*******Dependent variable: dummy *********

recode Q42d (1 2 =1 "Agree") (3 4=0 "Disagree") (98 99=.), gen(feelthreatened)
tab feelthreatened, m
bysort country: tab feelthreatened if Q32b==. [aweight=weight],m
graph hbar feelthreatened if Q32b==. [pweight=weight], over(country) subtitle(Share of feelings of threat of non-Muslims in Western Europe (weighted), size(small)) blabel(bar, position(upper) format(%4.2f)) note("Source: Pew Research Center (2017)", size(vsmall))

graph bar feelthreatened if Q32b==. [pweight=weight], over(country, label (angle(vertical))) subtitle(Share of feelings of threat of non-Muslims in Western Europe (weighted), size(small)) blabel(bar, position(upper) format(%4.2f) size(small)) note("Source: Pew Research Center (2017)", size(vsmall)) 
save "Graphs/Bar_feelthreatened.gph", replace

save church_tax, replace
clear



****************************************************************** DATASET ON RELIGIOUS PROJECTIONS **************************************************
// download from: https://www.pewforum.org/2015/04/02/religious-projection-table/

cd "$path"

import excel using "$path\Religious Projection\Religious_Composition_by_Country_2010-2050 (2).xlsx", sheet("rounded_population") firstrow

keep Year Country Muslims AllReligions
destring Year, replace

******

encode Country, gen(country)
drop Country

keep if country==14 | country==21 |  country==57 | country==72| country==73 |  country==79| country==100 | country==103|  country==146 | country==155 | country==166 | country==185 | country==192 | country==202 | country==203 | country==223
keep if Year==2010
drop Year

recode country (14=1 "Austria") (21=2 "Belgium") (57=3 "Denmark") (72=4 "Finland")(73=5 "France")(79=6 "Germany")(100=7 "Ireland")(103=8 "Italy")(146=9 "Netherlands")(155=10 "Norway")(166=11 "Portugal") (185=12 "Slovakia")(192=13 "Spain")(202=14 "Sweden")(203=15 "Switzerland")(223=16 "United Kingdom"), gen(Country) 
drop country
rename Country country

replace AllReligions=strtrim(AllReligions)
replace AllReligions=subinstr(AllReligions, ",", "",.)
destring AllReligions, replace

replace Muslims=strtrim(Muslims)
replace Muslims=subinstr(Muslims, "<", "",.)
replace Muslims=subinstr(Muslims, ",", "",.)
destring Muslims, replace

gen percentage= Muslims/AllReligions
lab var percentage "Percentage of Muslims in the country (year 2010)"

save religious_projections, replace
clear

***** ACTUAL MERGE OF church_tax and religious_projections for making a graph

use church_tax.dta
merge m:1 country using "religious_projections.dta"
drop _merge

save church_tax_merge1, replace
clear


******************************************************************************** DATASET ON ACCOMMODATION OF ISLAM INDEX ************************************************************


//download from (http://www.serdarkaya.com/data.php)
use "$path\Accomodation of Islam Index\aoi2015_v2.dta"


tab country
drop if country==1 | country==5 | country==6 | country==7 | country==12 | country==13 | country==16 | country==17 | country==19 | country==25

recode country (2=1 "Austria") (3=2 "Belgium") (8=3 "Denmark") (9=4 "Finland")(10=5 "France")(11=6 "Germany")(14=7 "Ireland")(15=8 "Italy")(18=9 "Netherlands")(20=10 "Norway")(21=11 "Portugal")(22=12 "Spain")(23=13 "Sweden")(24=14 "Switzerland")(4=15 "United Kingdom"), gen(Country) 

drop country
rename Country country
lab var aoi2015 "Accommodation of Islam (2015)"

save accomodation.dta, replace

clear


********** preparation church tax for merging
** Drop Slovak Republic (not in dataset on accomodation index)

use church_tax_merge1
drop if country==12 // Slovakia not included in dataset of Accommodation

recode country (1=1 "Austria") (2=2 "Belgium") (3=3 "Denmark") (4=4 "Finland")(5=5 "France")(6=6 "Germany")(7=7 "Ireland")(8=8 "Italy")(9=9 "Netherlands")(10=10 "Norway")(11=11 "Portugal")(13=12 "Spain")(14=13 "Sweden")(15=14 "Switzerland")(16=15 "United Kingdom"), gen(Country) 

drop country
rename Country country

************ ACTUAL MERGING******

 merge m:1 country using "accomodation.dta"
drop _merge

save church_tax_merge2, replace
clear


******************************************************************************** DATASET ON RELIGIOUS DIVERSITY ********************************************************************************

//download from (https://www.pewforum.org/2014/04/04/religious-diversity-index-scores-by-country/) 
import excel "$path\Religious Diversity Index\religious-diversity-index.xlsx", sheet("Sheet1") firstrow

replace CountryPopulation=subinstr(CountryPopulation, ",", "",.)
replace CountryPopulation=subinstr(CountryPopulation, "<", "",.)
destring CountryPopulation, replace

drop PercentChristian PercentMuslim PercentUnaffiliated PercentHindu PercentBuddhist PercentFolkReligions PercentOtherReligions PercentJewish

encode Country, gen(country)
drop Country

keep if country==13 | country==20 |  country==54 | country==69| country==70 |  country==76| country==97 | country==100|  country==143 | country==153 | country==164 | country==189 | country==199 | country==200 | country==220

recode country (13=1 "Austria") (20=2 "Belgium") (54=3 "Denmark") (69=4 "Finland")(70=5 "France")(76=6 "Germany")(97=7 "Ireland")(100=8 "Italy")(143=9 "Netherlands")(153=10 "Norway")(164=11 "Portugal") (189=12 "Spain")(199=13 "Sweden")(200=14 "Switzerland")(220=15 "United Kingdom"), gen(Country) 
drop country
rename Country country
lab var RDI "Religious Diversity Index"

save religious_diversity, replace
clear

************ ACTUAL MERGING******
use church_tax_merge2
merge m:1 country using "religious_diversity.dta"
drop _merge

save church_tax_merge3, replace

clear

******GDP******
//download from (https://ec.europa.eu/eurostat/databrowser/view/SDG_08_10/default/table)


import excel "C:\Users\t_ana\OneDrive\Documents\Ana Maria\thesis\GDP Eurostat\gdp.xlsx", sheet("Sheet 1") cellrange(A9:AQ48) firstrow case(preserve) clear 

keep TIME AD AF AH
rename TIME country
rename AD GDP2014
rename AF GDP2015
rename AH GDP2016
encode country, gen (Country)
drop country
keep if Country==1 | Country==2 |  Country==7 | Country==12| Country==13 |  Country==15| Country==19 | Country==20|  Country==26 | Country==28 | Country==30 | Country==35 | Country==36 | Country==37 | Country==39

recode Country (1=1 "Austria") (2=2 "Belgium") (7=3 "Denmark") (12=4 "Finland")(13=5 "France")(15=6 "Germany")(19=7 "Ireland")(20=8 "Italy")(26=9 "Netherlands")(28=10 "Norway")(30=11 "Portugal") (35=12 "Spain") (36=13 "Sweden")(37=14 "Switzerland")(39=15 "United Kingdom"), gen(country) 
drop Country
label var country countries

egen GDP_average=rowmean(GDP2014 GDP2015 GDP2016)
label var GDP_average Average_GDP_2014to2016

save GDP_average, replace
clear

****MERGE****
use church_tax_merge3
merge m:1 country using "GDP_average.dta"

drop _merge

save church_tax_merge4, replace



******************************************************************************** VARIABLES ON DEMOGRAPHIC CHARACTERISTICS ****************************************************************

** age, gender, religion and education

***RELIGION (categorical)
recode QCURRELrec (1=1 "Christian") (9=2 "Atheist") (10=3 "Agnostic") (91=4 "Others") (92=5 "No religion") (98=98 "Don't know") (99=99 "Refused"), gen(religion)
tab religion, m
lab var religion "What is your present religion if any?"

***AGE
rename QAGE age
lab var age "How old were you on your last birthday?"

***GENDER (dummy)
recode QGEN (1=1 "Male") (2=0 "Female"), gen(gender)
tab gender, m
lab var gender "Gender"

*EDUCATION (categorical)
* I recoded the variable education just to make the labels more intuitive
recode ISCED (2 = 1 "Basic education") (3=2 "Secondary and non-tertiary education") (5=3 "Tertiary education and above") (98=98 "Don't know") (99=99 "Refused"), gen(education)
tab education, m
lab var education "Education in ISCED 1997"

*****INCOME*****
** There are three income variables per country coded QINCa__, QINCb___ and QINCc__, except for the UK. For the UK there are 11 income variables QINCaGBR-QINCkGBR
** I will create 1 income variable that assembles all income variables. The income variable will reflect whether or not hte person earns below=0 or above=1 the median income (which changes per country). don't know and refused answers are recorded as missing valuves.
** Some income questions were asked to the 50% of the persons and some others to the other 50%, some answers were categorical and some others binary, that is why the code is different for some variables.
 
gen income=.

foreach var of varlist QINCaAUT-QINCaIRL QINCaNLD-QINCaPRT QINCaCHE {
	replace income = 0 if `var'<=5 
	replace income = 1 if `var'>=6 & `var'<=11
}

****** variables QINCaESP QINCaSWE QINCbGBR QINCdGBR QINCaITA QINCfGBR have a different coding

foreach var of varlist QINCaESP QINCaSWE QINCbGBR QINCdGBR {
	replace income = 0 if `var'<=6 
	replace income = 1 if `var'>=7 & `var'<=14
}

foreach var of varlist QINCaITA QINCfGBR {
	replace income = 0 if `var'<=4 
	replace income = 1 if `var'>=5 & `var'<=11
}

foreach var of varlist QINCbAUT-QINCbCHE QINCcAUT-QINCcCHE QINCcGBR QINCeGBR QINCgGBR QINCiGBR QINCjGBR QINCkGBR {
	replace income = 0 if `var'==1 
	replace income = 1 if `var'==2
}

recode income (0=0 "Median income or less") (1=1 "Above the median income"), gen(income_cat)
lab var income_cat "Is your income equal to, below or above the median income?"

*********POLITICAL ORIENTATION
gen Pol_ideology=.
foreach var of varlist QIDEOLOGY QIDEOLOGYa {
    replace Pol_ideology=0 if `var'==0
	replace Pol_ideology=1 if `var'==1
	replace Pol_ideology=2 if `var'==2
	replace Pol_ideology=3 if `var'==3
	replace Pol_ideology=4 if `var'==4
	replace Pol_ideology=5 if `var'==5
	replace Pol_ideology=6 if `var'==6
	replace Pol_ideology=98 if `var'==98
	replace Pol_ideology=99 if `var'==99
}
	
    replace Pol_ideology=0 if QIDEOLOGYb==1
	replace Pol_ideology=1 if QIDEOLOGYb==2
	replace Pol_ideology=2 if QIDEOLOGYb==3
	replace Pol_ideology=3 if QIDEOLOGYb==4
	replace Pol_ideology=4 if QIDEOLOGYb==5
	replace Pol_ideology=5 if QIDEOLOGYb==6
	replace Pol_ideology=6 if QIDEOLOGYb==7
	replace Pol_ideology=98 if QIDEOLOGYb==98
	replace Pol_ideology=99 if QIDEOLOGYb==99	

	tab Pol_ideology,m


*** Should I use: Pol_ideology as a continuous or as a categorical variable?
* First, check if the increase of 1 category is linear?
reg  feelthreatened aoi2015 i.Pol_ideology, r
coefplot, drop(_cons aoi2015)
reg  feelthreatened aoi2015 Pol_ideology, r
* There is almost always an increment, although it is not exactly the same for each increment in 1 unit.  It is reasonable though to treat Pol_ideology as a continuous or as a categorical variable. 
* I will treat it as categorical variable and 98 and 99 as missing values.

*** Recoding for ease of interpretation
recode Pol_ideology (0 1 2 =1 "(Left)") (4 5 6=2 "(Right)") (3=3 "(Center)") (98=98 "Don't know") (99=99 "Refused"), gen (pol_ideology_cat)

tab pol_ideology_cat, m
lab var pol_ideology_cat "In terms of politics, where would you place yourself: left, center and right?"


****VARIABLES DENOTING INTERGROUP CONTACT
tab Q34a //(personally knowing muslims)
recode Q34a (1=1 "Yes") (2=0 "No") (98=98 "Don't know") (99=99 "Refused"), gen(know_muslims_personally)
tab know_muslims_personally, m
lab var know_muslims_personally "Do you personally know anyone that is Muslim?"

****VARIABLES DENOTING ATTITUDES TOWARDS MIGRANTS IN GENERAL
tab Q43 // do you think that the number of migrants in the country should be increased, reduced or remain the same?
recode Q43 (1=1 "Be increased") (2=2 "Remain the same") (3=3 "Be reduced") (98=98 "Don't know") (99=99 "Refused"), gen(opinion_number_migrants)
lab var opinion_number_migrants "what do you think that should be done with the number of migrants in the country?"

******VARIABLES ON IN-GROUP IDENTITY*********
*Superiority of own culture: "Our people are not perfect, but our culture is superior to others." 
gen superiority_own_culture=.
replace superiority_own_culture=1 if Q50==1 | Q50==2
replace superiority_own_culture=2 if Q50==3 | Q50==4
replace superiority_own_culture=98 if Q50==98
replace superiority_own_culture=99 if Q50==99
recode superiority_own_culture (1=1 "Own culture is superior") (2=2 "Own culture is not superior") (98=98 "Don't know") (99=99 "Refused"), gen(Superiority_own_culture)
drop superiority_own_culture 
rename Superiority_own_culture superiority_own_culture
tab superiority_own_culture, m
lab var superiority_own_culture "Do you agree that our people are not perfect, but our culture is superior?"

*******VARIABLES DENOTING PEOPLE'S OPINIONS ON ISLAMIC VALUES AND PRACTICES

* Allowing women religious clothing in the country
tab Q41
recode Q41 (1=1 "Be allowed") (2=2 "Cover face not allowed") (3=3 "Not allowed") (98=98 "Don't know") (99=99 "Refused"), gen(women_religious_clothing_cat)
lab var women_religious_clothing "Do you agree that women religious clothing should be allowed in the country?"

* incompatibility of Islam with the culture of the country

gen compatibility_islam=.
replace compatibility_islam=1 if Q11==1
replace compatibility_islam=2 if Q11==2
replace compatibility_islam=3 if Q11==3
replace compatibility_islam=98 if Q11==98
replace compatibility_islam=99 if Q11==99
 
recode compatibility_islam (1=1 "Incompatible") (2=2 "Compatible") (3=3 "Other/Both/Neither/Depends") (98=98 "Don't know") (99=99 "Refused"), gen(Compatibility_islam)
drop compatibility_islam
rename Compatibility_islam compatibility_islam
tab compatibility_islam, m
lab var compatibility_islam "Do you think that Islam is incompatible with the culture of the country?"

*Muslims want to impose their religious law on everyone else in the country
gen Muslims_want_impose_Islam=.
replace Muslims_want_impose_Islam=1 if Q42b==1 | Q42b==2
replace Muslims_want_impose_Islam=2 if Q42b==3 | Q42b==4
replace Muslims_want_impose_Islam=98 if Q42b==98
replace Muslims_want_impose_Islam=99 if Q42b==99
recode Muslims_want_impose_Islam (1=1 "Muslims want to impose Islam") (2=2 "Muslims do not want to impose Islam") (98=98 "Don't know") (99=99 "Refused"), gen(muslims_want_impose_Islam)
drop Muslims_want_impose_Islam 
rename muslims_want_impose_Islam Muslims_want_impose_Islam
tab Muslims_want_impose_Islam, m
lab var Muslims_want_impose_Islam "Do you think that Muslims want to impose their religious law on everyone else in the country?"
 
 * RECODE DEPENDENT VARIABLE 
 tab Q42d 
 recode Q42d (1=4 "Completely agree") (2=3 "Mostly agree") (3=2 "Mostly disagree") (4=1 "Completely disagree") (99 98 .=.), gen(feelthreatened_ord)

 tab feelthreatened_ord, m
 lab var feelthreatened_ord "Do you agree that due to the number of Muslims you feel like a stranger in your own country?" 
save church_tax_merge4_demo_var, replace
clear

***** Indicators of Citizenship Rights for Immigrants (ICRI)*******


cd "C:\Users\t_ana\OneDrive\Documents\Ana Maria\thesis\Dataset Religion"

*download from: https://www.wzb.eu/en/research/migration-and-diversity/migration-integration-transnationalization/projects/indicators-of-citizenship-rights-for-immigrants-icri
//(ICRI indicators of 29 countries (excel file))

import excel "C:\Users\t_ana\OneDrive\Documents\Ana Maria\thesis\Dataset Religion\Multiculturalism Indicator\icri_indicators_29_countries_worldwide_.xlsx", sheet("Subscore 7.x") cellrange(A3:L33) firstrow

keep Country Year D E F G
encode Country, gen(country)
drop Country

keep if country==3 | country==4 |  country==7 | country==9| country==10 |  country==11| country==12 | country==13|  country==16 | country==19 | country==20 | country==23 | country==26 
recode country (3=1 "Austria") (4=2 "Belgium") (10=3 "Denmark") (12=5 "France")(9=6 "Germany")(16=8 "Italy")(19=9 "Netherlands")(20=10 "Norway")(23=11 "Portugal") (11=12 "Spain")(26=13 "Sweden")(7=14 "Switzerland")(13=15 "United Kingdom"), gen(Country) 
drop country
rename Country country

rename D funding2008
rename E course2008
rename F attire_teacher2008
rename G attire_stud2008

replace funding2008 = subinstr(funding2008, "<888>", ".", .) 
destring funding2008, replace
replace attire_teacher2008=subinstr(attire_teacher2008, "<888>", ".",.)
replace attire_teacher2008=subinstr(attire_teacher2008, "<999>", ".",.)
destring attire_teacher2008, replace

egen attire2008=rowmean(attire_stud2008 attire_teacher2008)
egen edu2008=rowmean(funding2008 course2008)
save ICRI_1, replace
clear


cd "$path"

import excel "$path\Multiculturalism Indicator\icri_indicators_29_countries_worldwide_.xlsx", sheet("Subscore 8.x") cellrange(A3:P33) firstrow

keep Country Year D E F G H K L
encode Country, gen(country)
drop Country

keep if country==3 | country==4 |  country==7 | country==9| country==10 |  country==11| country==12 | country==13|  country==16 | country==19 | country==20 | country==23 | country==26 
recode country (3=1 "Austria") (4=2 "Belgium") (10=3 "Denmark") (12=5 "France")(9=6 "Germany")(16=8 "Italy")(19=9 "Netherlands")(20=10 "Norway")(23=11 "Portugal") (11=12 "Spain")(26=13 "Sweden")(7=14 "Switzerland")(13=15 "United Kingdom"), gen(Country) 
drop country
rename Country country

rename D sla2008
rename E adhan2008
rename F archi2008
rename G cemen2008
rename H cemen_burial2008
rename K chap_mil2008
rename L chap_pris2008

replace adhan2008 = subinstr(adhan2008, "<888>", ".", .)
replace adhan2008 = subinstr(adhan2008, "<999>", ".", .)
destring adhan2008, replace

replace cemen_burial2008 = subinstr(cemen_burial2008, "<888>", ".", .)
destring cemen_burial2008, replace

replace chap_mil2008 = subinstr(chap_mil2008, "<888>", ".", .)
destring chap_mil2008, replace

replace chap_pris2008 = subinstr(chap_pris2008, "<888>", ".", .)
destring chap_pris2008, replace

destring sla2008 archi2008, replace

egen halal2008=rowmean(sla2008)
egen mosque2008=rowmean(archi2008 adhan2008)
egen chap2008=rowmean(chap_mil2008 chap_pris2008)
egen cem2008=rowmean(cemen2008 cemen_burial2008)

save ICRI_2, replace
clear

*** ACTUAL MERGE 

use church_tax_merge4_demo_var
merge m:1 country using "ICRI_1.dta"
drop _merge

merge m:1 country using "ICRI_2.dta"
drop _merge

egen icri2008=rowmean(halal2008 mosque2008 chap2008 cem2008 attire2008 edu2008)

save ICRI_merge5, replace

****************************************************************************************************SUMMARY STATISTICS AND GRAPHS ********************************************
*** Summary statistics and correlation matrix of independent variables
meologit feelthreatened_ord aoi2015 i.superiority_own_culture i.Muslims_want_impose_Islam i.women_religious_clothing i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country:

gen sam=e(sample)
asdoc tabstat Muslims_want_impose_Islam compatibility_islam women_religious_clothing superiority_own_culture age gender education pol_ideology_cat income_cat opinion_number_migrants know_muslims_personally religion aoi2015 percentage GDP_average RDI if sam==1, statistics(min max mean sd p25 median p75), title(Summary Statistics: Independent variables) save(summary_statistics_IndepVariab.doc), replace 

asdoc corr Muslims_want_impose_Islam compatibility_islam women_religious_clothing superiority_own_culture age gender education pol_ideology_cat income_cat opinion_number_migrants know_muslims_personally religion aoi2015 percentage GDP_average RDI if sam==1, title(Correlation values of independent variables) save(correlation_table.doc), replace

tab gender if sam==1
tab age if sam==1

*** MEAN CENTERING and STANDARDIZATION to make AOI2015 comparable to ICRI 2008
sum aoi2015, detail
scalar sd_aoi2015=r(sd)
egen grmean = mean(aoi2015) 
generate aoi_center = (aoi2015 - grmean) / sd_aoi2015

sum icri2008, detail 
scalar sd_icri2008=r(sd)
egen grmean2 = mean(icri2008)
generate icri_center = (icri2008 - grmean2) / sd_icri2008


bysort country: tab aoi_center if Q32b==. [aweight=weight],m
graph bar aoi_center if Q32b==. [pweight=weight], over(country, label (angle(vertical))) subtitle(Accommodation of Islam index centered (weighted), size(small)) blabel(bar, position(upper) format(%4.2f) size(small)) note("Source: S. Kaya (2015)", size(vsmall)) 
save "Graphs/Bar_aoi_center.gph", replace

graph bar icri_center if Q32b==. [pweight=weight], over(country, label (angle(vertical))) subtitle(ICRI centered (weighted), size(small)) blabel(bar, position(upper) format(%4.2f) size(small)) note("Source: Koopmans(2008)", size(vsmall)) 
save "Graphs/Bar_icri_center.gph", replace
 

****GRAPHS
collapse (mean) feelthreatened aoi2015 icri_center aoi_center if Q32b==. [pweight=weight], by(country)

scatter feelthreatened aoi2015, subtitle(Percentage of feelings of threat vs accommodation of Islam index, size(small)) mlabel(country) mlabposition(12) mlabsize(tiny) note("Source: Pew Research Center (2017); S.Kaya (2015)", size (vsmall))
save "Graphs/scatter_aoi2015_feelthreatened.gph", replace

scatter icri_center aoi_center, subtitle(ICRI and AOI, size(small)) mlabel(country) mlabposition(12) mlabsize(tiny) note("Source: Koopmans (2008); S.Kaya (2015)", size (vsmall))
save "Graphs/scatter_aoi2015_icri2008.gph", replace

save church_tax_graphscatter, replace

clear



************************************************************ 2) Multilevel mixed-effects logistic regression ********************************************************

use ICRI_merge5

**** Recode variables
* women religious clothing
recode Q41 (1=1 "Be allowed") (2 3=0 "Not allowed") (98=98 "Don't know") (99=99 "Refused"), gen(women_religious_clothing)
lab var women_religious_clothing "Do you agree that women religious clothing should be allowed in the country?"
recode compatibility_islam (3 = .)

recode education pol_ideology_cat opinion_number_migrants know_muslims_personally religion women_religious_clothing Muslims_want_impose_Islam compatibility_islam superiority_own_culture age (98 99 = .)



******** 2.1) THE NULL MODEL / THE RANDOM INTERCEPT MODEL

meologit feelthreatened_ord if Q32b==. || country:
estimates store m1
outreg2 using "output2.doc", bdec(2) word replace
estat icc
estat ic 


******2.2) Two-level random intercept model: adding in level 1 predictors (demographic characteristics). I look now at variables that are "potential explanation of the observed feelings of alienation" 
meologit feelthreatened_ord i.Muslims_want_impose_Islam i.compatibility_islam i.women_religious_clothing i.superiority_own_culture age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.know_muslims_personally i.religion if Q32b==. || country: 
estimates store m2
outreg2 using "output2.doc", bdec(2) word append
coefplot, ylab(, labs(small))

estat icc 
estat ic 



******2.3) Two-level random intercept model: adding in level 2 predictors

corr Muslims_want_impose_Islam compatibility_islam women_religious_clothing superiority_own_culture age gender education pol_ideology_cat income_cat opinion_number_migrants know_muslims_personally religion aoi2015 percentage GDP_average RDI
// Considering that percentage and RDI are correlated, I will run the model with percentage first and with RDI later for sensibility test

***2.3.1) With percentage
meologit feelthreatened_ord i.Muslims_want_impose_Islam i.compatibility_islam i.women_religious_clothing i.superiority_own_culture age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.know_muslims_personally i.religion aoi2015 percentage GDP_average if Q32b==. || country:
estimates store m3a
outreg2 using "output2.doc", bdec(2) word append
estat icc 
estat ic 
coefplot, ylab(, labs(tiny))
lrtest m2 m3a
lrtest m1 m2 

* Proportion of explained variance
predict p_mod3a
sum p_mod3a, detail
scalar variance_mod3a=r(Var)
scalar list

*The proportion of explained variation
di (variance_mod3a/(variance_mod3a +  .2542845    +3.29)) 
*The proportion of unexplained variation at the country level 
di (.2542845 /(variance_mod3a +  .2542845   +3.29)) 
*The proportion of unexplained variation at the individual level
di (3.29/(variance_mod3a +  .2542845   +3.29))  



******2.4) THe random coefficient model (random effects: women_religious_clothing)

meologit feelthreatened_ord aoi2015 i.women_religious_clothing i.superiority_own_culture i.Muslims_want_impose_Islam i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: women_religious_clothing

estimates store m4a
estat icc
estat ic
coefplot, ylab(, labs(tiny))

******2.4.1)  Interaction terms: aoi2015##women_religious_clothing
**2.4.1.1) With Percentage
meologit feelthreatened_ord c.aoi2015##i.women_religious_clothing i.superiority_own_culture i.Muslims_want_impose_Islam  i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: women_religious_clothing
estimates store m5a
estat icc
estat ic
coefplot, ylab(, labs(tiny))

* MARGINAL EFFECT
meologit feelthreatened_ord c.aoi2015##i.women_religious_clothing i.superiority_own_culture i.Muslims_want_impose_Islam  i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: women_religious_clothing, or


//2 standard deviations
asdoc margins, at (women_religious_clothing=(1) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins: Women religious clothing should be allowed) save(margins_women_religious_clothing_d.doc), replace
margins, at (women_religious_clothing=(1) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Women religious clothing should be fully allowed, size(vsmall)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) name(graph1d, replace) 

asdoc margins, at (women_religious_clothing=(2) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins:Women religious clothing should be allowed with limitations or not be allowed at all) save(margins_women_religious_clothing_d.doc), append
margins, at (women_religious_clothing=(2) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Women religious clothing should be allowed with limitations or not be allowed at all, size(vsmall)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) name(graph2d, replace)

graph combine graph1d graph2d, ycommon title(Predicted margins: women religious clothing, size(small)) note("Model: Multilevel Ordered Logistic Regression", size(vsmall))
save "Graphs/graph_combi_d.gph", replace



************************************************************ROBUSTNESS CHECKS***************************************

*********** 3) MULTILEVEL ORDERED LOGISTIC REGRESSION: Compatibility_islam instead of women_religious_clothing

******3.1) The random coefficient model (random effects: compatibility_islam)
meologit feelthreatened_ord aoi2015 i.compatibility_islam i.superiority_own_culture i.women_religious_clothing i.Muslims_want_impose_Islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: compatibility_islam
estimates store m6

******3.1.1)  Interaction terms: aoi2015##compatibility_islam 
**3.1.1.1) With Percentage
meologit feelthreatened_ord c.aoi2015##i.compatibility_islam i.superiority_own_culture i.women_religious_clothing i.Muslims_want_impose_Islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: compatibility_islam
estimates store m7
estat icc
estat ic
coefplot, ylab(, labs(tiny))


*MARGINAL EFFECT
meologit feelthreatened_ord c.aoi2015##i.compatibility_islam i.superiority_own_culture i.women_religious_clothing i.Muslims_want_impose_Islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: compatibility_islam, or

//2 standard deviations
asdoc margins, at (compatibility_islam=(1) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins: Islam is incompatible) save(compatibility_islam_e.doc), replace
margins, at (compatibility_islam=(1) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Islam is incompatible with the host culture, size(small)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) legend(order( - "Feelings of threat:" 1 "Completely Disagree" 2 "Mostly Disagree" 3 "Mostly Agree" 4 "Completely Agree") size(vsmall) symysize(1)) name(graph1e, replace)

asdoc margins, at (compatibility_islam=(2) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins: Islam is compatible) save(compatibility_islam_e.doc), append
margins, at (compatibility_islam=(2) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Islam is compatible with the host culture, size(small)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) legend(order( - "Feelings of threat:" 1 "Completely Disagree" 2 "Mostly Disagree" 3 "Mostly Agree" 4 "Completely Agree") size(vsmall) symysize(1)) name(graph2e, replace)

graph combine graph1e graph2e, ycommon title(Predicted margins: (In-)Compatibility of Islam, size(small)) note("Model: Multilevel Ordered Logistic Regression", size(vsmall))
save "Graphs/graph_combi_e.gph", replace


*********** 4) MULTILEVEL ORDERED LOGISTIC REGRESSION: superiority_own_culture instead of women_religious_clothing

******4.1) THe random coefficient model (random effects: superiority_own_culture)
meologit feelthreatened_ord aoi2015 i.superiority_own_culture i.Muslims_want_impose_Islam i.women_religious_clothing i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: superiority_own_culture
estimates store m8

******4.1.1)  Interaction terms: aoi2015##superiority_own_culture

**4.1.1.1) With Percentage
meologit feelthreatened_ord c.aoi2015##i.superiority_own_culture i.Muslims_want_impose_Islam i.women_religious_clothing i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: superiority_own_culture
estimates store m9
estat icc
estat ic
coefplot, ylab(, labs(tiny))

* MARGINAL EFFECT
meologit feelthreatened_ord c.aoi2015##i.superiority_own_culture i.Muslims_want_impose_Islam i.women_religious_clothing i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: superiority_own_culture, or

//2 standard deviations
asdoc margins, at (superiority_own_culture=(1) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins. Agree about superiority of own culture) save(superiority_own_culture_f.doc), replace
margins, at (superiority_own_culture=(1) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Agree about superiority of own culture, size(small)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) legend(order( - "Feelings of threat:" 1 "Completely Disagree" 2 "Mostly Disagree" 3 "Mostly Agree" 4 "Completely Agree") size(vsmall) symysize(1)) name(graph1f, replace)

asdoc margins, at (superiority_own_culture=(2) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins. Disagree about superiority of own culture) save(superiority_own_culture_f.doc), append
margins, at (superiority_own_culture=(2) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Disagree about superiority of own culture, size(small)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) legend(order( - "Feelings of threat:" 1 "Completely Disagree" 2 "Mostly Disagree" 3 "Mostly Agree" 4 "Completely Agree") size(vsmall) symysize(1)) name(graph2f, replace)

graph combine graph1f graph2f, ycommon title(Predicted margins: Superiority of own culture, size(small)) note("Model: Multilevel Ordered Logistic Regression", size(vsmall))
save "Graphs/graph_combi_f.gph", replace


*********** 5) MULTILEVEL ORDERED LOGISTIC REGRESSION: Muslims_want_impose_Islam instead of women_religious_clothing

*******5.1) THe random coefficient model (random effects: Muslims_want_impose_Islam)
meologit feelthreatened_ord aoi2015 i.Muslims_want_impose_Islam i.women_religious_clothing i.superiority_own_culture i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: Muslims_want_impose_Islam
estimates store m14

******5.1.1)  Interaction terms: aoi2015##Muslims_want_impose_Islam

**5.1.1.1) With Percentage
meologit feelthreatened_ord c.aoi2015##i.Muslims_want_impose_Islam i.women_religious_clothing i.superiority_own_culture i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: Muslims_want_impose_Islam
estimates store m15
estat icc
estat ic
coefplot, ylab(, labs(tiny))

* MARGINAL EFFECT
meologit feelthreatened_ord c.aoi2015##i.Muslims_want_impose_Islam i.women_religious_clothing i.superiority_own_culture i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion percentage GDP_average if Q32b==. || country: Muslims_want_impose_Islam, or

//2 standard deviations
asdoc margins, at (Muslims_want_impose_Islam=(1) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins. Agree that Muslims want to impose Islam) save(muslims_want_impose_Islam_g.doc), replace
margins, at (Muslims_want_impose_Islam=(1) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Agree that Muslims want to impose Islam, size(small)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall))  legend(order( - "Feelings of threat:" 1 "Completely Disagree" 2 "Mostly Disagree" 3 "Mostly Agree" 4 "Completely Agree") size(vsmall) symysize(1)) note("Model: Multilevel Ordered Logistic Regression", size(vsmall)) name(graph1g, replace)

asdoc margins, at (Muslims_want_impose_Islam=(2) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins. Disagree that Muslims want to impose Islam) save(muslims_want_impose_Islam_g.doc), append
margins, at (Muslims_want_impose_Islam=(2) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Disagree that Muslims want to impose Islam, size(small)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) legend(order( - "Feelings of threat:" 1 "Completely Disagree" 2 "Mostly Disagree" 3 "Mostly Agree" 4 "Completely Agree") size(vsmall) symysize(1)) note("Model: Multilevel Ordered Logistic Regression", size(vsmall)) name(graph2g, replace)

graph combine graph1g graph2g, ycommon title(Predicted margins: Muslims want to impose Islam, size(small))
save "Graphs/graph_combi_g.gph", replace




*********** 6) MULTILEVEL ORDERED LOGISTIC REGRESSION: RDI instead of Percentage
	
******6.1)  Interaction terms: aoi2015##women_religious_clothing
**6.1.2) With RDI
meologit feelthreatened_ord aoi2015 i.women_religious_clothing i.superiority_own_culture i.Muslims_want_impose_Islam i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion RDI GDP_average if Q32b==. || country: women_religious_clothing  
estimates store m12
estat icc
estat ic

* MARGINAL EFFECT
meologit feelthreatened_ord c.aoi2015##i.women_religious_clothing i.superiority_own_culture i.Muslims_want_impose_Islam i.compatibility_islam i.know_muslims_personally age gender i.education i.pol_ideology_cat income_cat i.opinion_number_migrants i.religion RDI GDP_average if Q32b==. || country: women_religious_clothing, or  

//2 standard deviations
asdoc margins, at (women_religious_clothing=(1) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins: Women religious clothing should be allowed) save(margins_women_religious_clothing_h.doc), replace
margins, at (women_religious_clothing=(1) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Women religious clothing should be fully allowed, size(vsmall)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) name(graph1h, replace) 

asdoc margins, at (women_religious_clothing=(0) aoi2015=(.2592058 .5468976 .8345894)), title(Predicted Margins: Women religious clothing should be allowed with limitations or not be allowed at all) save(margins_women_religious_clothing_h.doc), append
margins, at (women_religious_clothing=(0) aoi2015=(.2592058 .5468976 .8345894))
marginsplot, noci x(aoi2015) title(Women religious clothing should be allowed with limitations or not be allowed at all, size(vsmall)) ytitle(Probability, size(vsmall)) xtitle(Accommodation of Islam Index, size(vsmall)) name(graph2h, replace)

graph combine graph1h graph2h, ycommon title(Predicted margins: women religious clothing, size(small)) note("Model: Multilevel Ordered Logistic Regression (with RDI instead of percentage)", size(vsmall))
save "Graphs/graph_combi_h.gph", replace


****

log close 
clear
