set more off


tempfile first  district


use  "$path/data/raw/SIGACTS_cleaned.dta", clear
*Southern provinces - Helmand, Kandahar, Urozgan, Zabol, Nimruz, and Day Kundi
gen byte South=(Province==11 | Province==15 | Province==33 | Province==34 | Province==24 | Province==6)
drop if PrimaryCategory==1 | PrimaryCategory==3
gen year_month=ym(year, month)
format year_month %tm
collapse (count) ID, by (year_month South)
reshape wide ID, i(year_month) j(South)
rename ID0 Incidents_NonSouth
rename ID1 Incidents_South

save `first'


use "$path/data/raw/SIGACTS_cleaned_distances.dta", clear
drop if distance>15000
drop if PrimaryCategory==1 | PrimaryCategory==3
keep  ID year month PrimaryCategory PrimaryType
duplicates drop
gen byte Category=.
replace Category=1 if (PrimaryCategory==2 | PrimaryCategory==4 | PrimaryCategory==5| PrimaryCategory==9 )
replace Category=2 if (PrimaryCategory==6 | PrimaryCategory==8 | PrimaryCategory==11)
replace Category=3 if (PrimaryCategory==7)


merge 1:1 ID using "$path/data/raw/SIGACTS_cleaned.dta", keepusing(District) nogen

gen byte East=((District==132 | District==335 )) if District!=.
gen byte sample_period=(year<2011 | (year==2011 & month<10))
gen byte treatment_period=sample_period
replace treatment_period=0 if year<2007
replace treatment_period=0 if (year==2007 & month<10)



gen year_month=ym(year, month)
format year_month %tm
collapse (count) ID, by (year_month)
rename ID Incidents_Sample
merge 1:1 year_month  using `first'
replace Incidents_Sample=0 if Incidents_Sample==.
sort year_month
drop if year_month==.
drop _merge
gen Date=_n
*In per district terms
gen Incidents_Sample_pd=Incidents_Sample/10
gen Incidents_South_pd=Incidents_South/58
gen Incidents_NonSouth_pd=Incidents_NonSouth/330

label var Incidents_Sample_pd "Within 15 km of Evaluation Villages"
label var Incidents_South_pd "South Only"
label var Incidents_NonSouth_pd "Excluding South"

*Figure 2 in the text
graph twoway (line Incidents_Sample_pd year_month, lpattern(solid) ) (line Incidents_South_pd year_month, lpattern(dash)) (line Incidents_NonSouth_pd year_month, lpattern(shortdash_dot) lcolor(black)), xtitle("")

graph save Graph "Figure2", replace
