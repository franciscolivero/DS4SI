clear all

use "$path/data/processed/SIGACTS_cleaned_panel_prepared.dta", clear



local period="FU"
collapse (sum) Inc*km* , by (Geocode `period')
replace `period'=0 if `period'==.
tsset Geocode `period'
tsfill, full
merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta", keepusing (DISTRICT_N Geocode1 treatment  POINT_X POINT_Y atlarge referendum C5 C2) nogen
replace treatment=treatment-1
foreach var of varlist  Inc*km*  {
	replace `var'=0 if `var'==.
}	

gen byte East=(DISTRICT_N =="HESARAK" | DISTRICT_N =="SHER ZAD")	

*TABLE 3

global file="Table 3 $S_DATE"

putexcel set "$file", replace


putexcel B1="Control Group"
putexcel F1="Treatment Group"
putexcel B2="Mean Level"
putexcel C2="Standard Deviation"
putexcel D2="Mean Level"
putexcel E2="Standard Deviation"
putexcel F2="Mean Level"
putexcel G2="Standard Deviation"
putexcel H2="Mean Level"
putexcel I2="Standard Deviation"
putexcel B3="Midline"
putexcel D3="Endline"
putexcel F3="Midline"
putexcel H3="Endline"

local row=4

*Whole sample

foreach km in 1 2 5 10 15 {
	label var Inc`km'km "Occurance of Security Incidents within `km' km of a Village"
	}

foreach var of varlist Inc1km Inc2km Inc5km Inc10km Inc15km  {
	qui replace `var'=(`var'>0)
	local lab: var label `var'
	qui sum `var' if treatment==0 & FU==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & FU==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & FU==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & FU==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)

	
	

putexcel A`row'="`lab'"
putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
putexcel C`row'=`SDContr_FU1', nformat(number_d2)
putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
local row=`row'+1
}

preserve 
use "$path/data/processed/Security_indices_summary.dta", clear


foreach var of varlist Inc_dum_Anderson {
	qui replace `var'=(`var'>0)
	local lab: var label `var'
	qui sum `var' if treatment==0 & FU==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & FU==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & FU==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & FU==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)


putexcel A`row'="`lab'"
putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
putexcel C`row'=`SDContr_FU1', nformat(number_d2)
putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
putexcel I`row'=`SDTreat_FU2', nformat(number_d2)

}
restore 



*TABLE A.18


global file="Table A18 $S_DATE"
putexcel set "$file", replace


putexcel B1="Control Group"
putexcel F1="Treatment Group"
putexcel B2="Mean Level"
putexcel C2="Standard Deviation"
putexcel D2="Mean Level"
putexcel E2="Standard Deviation"
putexcel F2="Mean Level"
putexcel G2="Standard Deviation"
putexcel H2="Mean Level"
putexcel I2="Standard Deviation"
putexcel B3="Midline"
putexcel D3="Endline"
putexcel F3="Midline"
putexcel H3="Endline"
putexcel A4="Panel A"
putexcel A5="Region Bordering Pakistan"
local row=6


*Whole East
foreach var of varlist Inc1km Inc2km Inc5km Inc10km Inc15km  {
	qui replace `var'=(`var'>0)
	local lab: var label `var'
	qui sum `var' if treatment==0 & FU==1 & East==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & FU==2 & East==1
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & FU==1 & East==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & FU==2 & East==1
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)

putexcel A`row'="`lab'"
putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
putexcel C`row'=`SDContr_FU1', nformat(number_d2)
putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
local row=`row'+1
}


preserve 
use "$path/data/processed/Security_indices_summary.dta", clear

foreach var of varlist Inc_dum_Anderson {
	qui replace `var'=(`var'>0)
	local lab: var label `var'
	qui sum `var' if treatment==0 & FU==1 & East==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & FU==2 & East==1
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & FU==1 & East==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & FU==2 & East==1
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)

putexcel A`row'="`lab'"
putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
putexcel C`row'=`SDContr_FU1', nformat(number_d2)
putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
local row=`row'+1
}
restore 



*Whole NonEast

putexcel A`row'="Panel B"
local row=`row'+1
putexcel A`row'="Region Not Bordering Pakistan"
local row=`row'+1

foreach var of varlist Inc1km Inc2km Inc5km Inc10km Inc15km  {
	qui replace `var'=(`var'>0)
	local lab: var label `var'
	qui sum `var' if treatment==0 & FU==1 & East==0
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & FU==2 & East==0
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & FU==1 & East==0
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & FU==2 & East==0
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)

putexcel A`row'="`lab'"
putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
putexcel C`row'=`SDContr_FU1', nformat(number_d2)
putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
local row=`row'+1
}

preserve 
use "$path/data/processed/Security_indices_summary.dta", clear


foreach var of varlist Inc_dum_Anderson {
	qui replace `var'=(`var'>0)
	local lab: var label `var'
	qui sum `var' if treatment==0 & FU==1 & East==0
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & FU==2 & East==0
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & FU==1 & East==0
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & FU==2 & East==0
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)

putexcel A`row'="`lab'"
putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
putexcel C`row'=`SDContr_FU1', nformat(number_d2)
putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
local row=`row'+1
}
restore 



use "$path/data/processed/Combined_data_H_M_Full_SIGACTS_new.dta", clear



* TABLE A.4
global file="Table A4 $S_DATE"


putexcel set "$file", replace


putexcel B1="Control Group"
putexcel F1="Treatment Group"
putexcel B2="Mean Level"
putexcel C2="Standard Deviation"
putexcel D2="Mean Level"
putexcel E2="Standard Deviation"
putexcel F2="Mean Level"
putexcel G2="Standard Deviation"
putexcel H2="Mean Level"
putexcel I2="Standard Deviation"
putexcel B3="Midline"
putexcel D3="Endline"
putexcel F3="Midline"
putexcel H3="Endline"
putexcel A4="Panel А"
putexcel A5="Economic Outcomes"

local row=6

foreach var of varlist M7_93z_wins_ln  M7_92z  M7_91z M8_91z_wins_ln  M8_92z Assets_Household_pca Assets_Livestock_pca M9_03_wins_ln  M9_99z  F8_03y_wins_ln   F8_01z	{
	local lab: var label `var'
	qui sum `var' if treatment==0 & Survey==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & Survey==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & Survey==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & Survey==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)
	
	putexcel A`row'="`lab'"
	putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
	putexcel C`row'=`SDContr_FU1', nformat(number_d2)
	putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
	putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
	putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
	putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
	putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
	putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
		
	local row=`row'+1
}

putexcel A`row'="Access to Public Goods"
local row=`row'+1


foreach var of varlist   F2_01x F2_034x_wins_ln F2_05x F2_05y M1_05_6z_wins_ln  	{
	local lab: var label `var'
	qui sum `var' if treatment==0 & Survey==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & Survey==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & Survey==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & Survey==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)
	
	putexcel A`row'="`lab'"
	putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
	putexcel C`row'=`SDContr_FU1', nformat(number_d2)
	putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
	putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
	putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
	putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
	putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
	putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
		
	local row=`row'+1
}	

putexcel A`row'="Economic Perceptions"
local row=`row'+1

foreach var of varlist M9_05z M9_06z   F13_01x F13_02z      G2_04_5z_wins_ln {
	local lab: var label `var'
	qui sum `var' if treatment==0 & Survey==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & Survey==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & Survey==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & Survey==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)
	
	putexcel A`row'="`lab'"
	putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
	putexcel C`row'=`SDContr_FU1', nformat(number_d2)
	putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
	putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
	putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
	putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
	putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
	putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
		
	local row=`row'+1
}

putexcel A`row'="Panel B"
local row=`row'+1
putexcel A`row'="Attitudes toward Government, Civil Society, and ISAF Soldiers"
local row=`row'+1
foreach var of varlist    M11_01z M11_02z M11_03z  M11_04z M11_05z M11_10z M11_11z M11_09z M11_13z  {
	local lab: var label `var'
	qui sum `var' if treatment==0 & Survey==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & Survey==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & Survey==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & Survey==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)
	
	putexcel A`row'="`lab'"
	putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
	putexcel C`row'=`SDContr_FU1', nformat(number_d2)
	putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
	putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
	putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
	putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
	putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
	putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
		
	local row=`row'+1
}



putexcel A`row'="Panel C"
local row=`row'+1
putexcel A`row'="Security Perception by Male Respondents"
local row=`row'+1

foreach var of varlist    M12_19z M12_19X  {
	local lab: var label `var'
	qui sum `var' if treatment==0 & Survey==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & Survey==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & Survey==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & Survey==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)
	
	putexcel A`row'="`lab'"
	putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
	putexcel C`row'=`SDContr_FU1', nformat(number_d2)
	putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
	putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
	putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
	putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
	putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
	putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
		
	local row=`row'+1
}

putexcel A`row'="Security Perception by Female Respondents"
local row=`row'+1

foreach var of varlist   F13_06_better F13_06_worse F13_07_better F13_07_worse  {
	local lab: var label `var'
	qui sum `var' if treatment==0 & Survey==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & Survey==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & Survey==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & Survey==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)
	
	putexcel A`row'="`lab'"
	putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
	putexcel C`row'=`SDContr_FU1', nformat(number_d2)
	putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
	putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
	putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
	putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
	putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
	putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
		
	local row=`row'+1
}


putexcel A`row'="Self-Reprted Security Incidents"
local row=`row'+1

foreach var of varlist    M12_17a M12_17B  M12_20z M12_20y   {
	local lab: var label `var'
	qui sum `var' if treatment==0 & Survey==1
	local MeanContr_FU1=r(mean)
	local SDContr_FU1=r(sd)
	qui sum `var' if treatment==0 & Survey==2
	local MeanContr_FU2=r(mean)
	local SDContr_FU2=r(sd)
	qui sum `var' if treatment==1 & Survey==1
	local MeanTreat_FU1=r(mean)
	local SDTreat_FU1=r(sd)
	qui sum `var' if treatment==1 & Survey==2
	local MeanTreat_FU2=r(mean)
	local SDTreat_FU2=r(sd)
	
	putexcel A`row'="`lab'"
	putexcel B`row'=`MeanContr_FU1' , nformat(number_d2)
	putexcel C`row'=`SDContr_FU1', nformat(number_d2)
	putexcel D`row'=`MeanContr_FU2' , nformat(number_d2)
	putexcel E`row'=`SDContr_FU2' , nformat(number_d2)
	putexcel F`row'=`MeanTreat_FU1', nformat(number_d2)
	putexcel G`row'=`SDTreat_FU1', nformat(number_d2)
	putexcel H`row'=`MeanTreat_FU2' , nformat(number_d2)
	putexcel I`row'=`SDTreat_FU2', nformat(number_d2)
		
	local row=`row'+1
}
