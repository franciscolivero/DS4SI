*Table A1
tempfile NRVA_male  NRVA_female


global file="Table A1"

putexcel set "$file", replace
putexcel A1="Indicator"
putexcel B1="National Risk and Vulnerability Assessment 2007-08"
putexcel E1="Midline Survey"
putexcel H1="t-statistic"
putexcel B2="Mean"
putexcel C2="S.D."
putexcel D2="Obs."
putexcel E2="Mean"
putexcel F2="S.D."
putexcel G2="Obs."


use "$path/data/raw/NRVA Male.dta", clear

rename q_8_4  Income
gen byte Agriculture=(q_8_1_1<12 | q_8_1_2<12 | q_8_1_3<12 | q_8_1_4<12 | q_8_1_5<12 | q_8_1_6<12)
egen byte Electricity=rowmin(q_2_20_*)
replace Electricity=2-Electricity
rename  q_1_3 Age
keep if urbrur==2
keep Income Agriculture Electricity Age
gen byte NRVA=1
save `NRVA_male'

use "$path/data/raw/NRVA Female.dta", clear
gen byte Last_Child_Alive=2-q_18_3
gen byte Birth_Home= (q_18_7==4) if  q_18_7!=.
gen byte Birth_Hospital= (q_18_7==1) if  q_18_7!=.
keep if urbrur==2
keep Last_Child_Alive Birth_Home Birth_Hospital
gen byte NRVA=1
save `NRVA_female'

use "$path/data/raw/MHH_FU1_for_NRVA_comparison.dta", clear

local row=3

* Mover from USD to Afganies income 

gen Income= q_8_03*50
drop q_8_03
rename q_9_03a Agriculture
rename q_2_04 Electricity
rename q_1_01 Age 
append using `NRVA_male'


	
local var="Age"
	qui sum `var' if NRVA==1
	local var_NRVA_mean=r(mean)
	local var_NRVA_sd=r(sd)
	local var_NRVA_N=r(N)

	qui sum `var' if NRVA==0
	local var_NSP_mean=r(mean)
	local var_NSP_sd=r(sd)
	local var_NSP_N=r(N)
	local x=+1
	
	ttest `var', by (NRVA)
	local tstat=r(t)
	
putexcel A`row'="Age of Male Respondent"
putexcel B`row'=`var_NRVA_mean', nformat(#.000)
putexcel C`row'=`var_NRVA_sd', nformat(#.000)
putexcel D`row'=`var_NRVA_N', nformat(number_sep)
putexcel E`row'=`var_NSP_mean', nformat(#.000)
putexcel F`row'=`var_NSP_sd', nformat(#.000)
putexcel G`row'=`var_NSP_N', nformat(number_sep)
putexcel H`row'=`tstat', nformat(#.000)
local row=`row'+1
	




local var="Income"
	qui sum `var' if NRVA==1
	local var_NRVA_mean=r(mean)
	local var_NRVA_sd=r(sd)
	local var_NRVA_N=r(N)

	qui sum `var' if NRVA==0
	local var_NSP_mean=r(mean)
	local var_NSP_sd=r(sd)
	local var_NSP_N=r(N)
	local x=+1
	
	ttest `var', by (NRVA)
	local tstat=r(t)
	
putexcel A`row'="Income from Primary Source (Afghanis)"
putexcel B`row'=`var_NRVA_mean', nformat(number_sep)
putexcel C`row'=`var_NRVA_sd', nformat(number_sep)
putexcel D`row'=`var_NRVA_N', nformat(number_sep)
putexcel E`row'=`var_NSP_mean', nformat(number_sep)
putexcel F`row'=`var_NSP_sd', nformat(number_sep)
putexcel G`row'=`var_NSP_N', nformat(number_sep)
putexcel H`row'=`tstat', nformat(#.000)
local row=`row'+1

		
label var Agriculture "Household Engaged in Agriculture"
label var Electricity "Access to Electricity"
	
foreach var of varlist    Agriculture Electricity{
	qui sum `var' if NRVA==1
	local var_NRVA_mean=r(mean)
	local var_NRVA_sd=r(sd)
	local var_NRVA_N=r(N)

	qui sum `var' if NRVA==0
	local var_NSP_mean=r(mean)
	local var_NSP_sd=r(sd)
	local var_NSP_N=r(N)
	local x=+1
	
	ttest `var', by (NRVA)
	local tstat=r(t)
	
local lab: var label `var'	
putexcel A`row'="`lab''"
putexcel B`row'=`var_NRVA_mean', nformat(#.000)
putexcel C`row'=`var_NRVA_sd', nformat(#.000)
putexcel D`row'=`var_NRVA_N', nformat(number_sep)
putexcel E`row'=`var_NSP_mean', nformat(#.000)
putexcel F`row'=`var_NSP_sd', nformat(#.000)
putexcel G`row'=`var_NSP_N', nformat(number_sep)
putexcel H`row'=`tstat', nformat(#.000)
local row=`row'+1
	
	
}
 


use "$path/data/raw/FHH_FU1_for_NRVA_comparison.dta", clear
gen Birth_Home= (q_13_07=="Home") if q_13_07!="" & q_13_07!="." & q_13_07!="Don't Know"
gen Birth_Hospital= (q_13_07=="Hospital") if q_13_07!="" & q_13_07!="." & q_13_07!="Don't Know"
rename q_13_03a Last_Child_Alive
drop q_13_07
append using `NRVA_female'

label var Last_Child_Alive "Last Child Born is Alive"
label var Birth_Home "Last Birth Delivered at Home"
label var Birth_Hospital "Last Birth Delivered in Hospital"

 foreach var of varlist  Last_Child_Alive Birth_Home  Birth_Hospital{
	qui sum `var' if NRVA==1
	local var_NRVA_mean=r(mean)
	local var_NRVA_sd=r(sd)
	local var_NRVA_N=r(N)

	qui sum `var' if NRVA==0
	local var_NSP_mean=r(mean)
	local var_NSP_sd=r(sd)
	local var_NSP_N=r(N)
	local x=+1
	
	ttest `var', by (NRVA)
	local tstat=r(t)
	
local lab: var label `var'	
putexcel A`row'="`lab''"
putexcel B`row'=`var_NRVA_mean', nformat(#.000)
putexcel C`row'=`var_NRVA_sd', nformat(#.000)
putexcel D`row'=`var_NRVA_N', nformat(number_sep)
putexcel E`row'=`var_NSP_mean', nformat(#.000)
putexcel F`row'=`var_NSP_sd', nformat(#.000)
putexcel G`row'=`var_NSP_N', nformat(number_sep)
putexcel H`row'=`tstat', nformat(#.000)
local row=`row'+1
}
 
