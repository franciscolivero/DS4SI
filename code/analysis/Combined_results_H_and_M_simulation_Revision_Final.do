set more off
clear all
set mem 500m


use "$path/data/processed/Combined_data_H_M_Full_SIGACTS_new.dta", clear
drop _merge
merge m:1 Geocode using "$path/data/raw/Simulation_assignment.dta"
set obs 10000
rename Survey FU
egen Pair_FU=group(Pair FU)

global indices_survey_Andr "index_Economic_Andr_M    index_PublicGoods_Andr  index_Economic_Andr_Subj G2_04_5z_wins_ln index_Attitudes_Andr_M" 
global indices_secPerc_Andr "index_Security_perc_Andr_M index_Security_perc_Andr_F index_Security_exp_Andr_M"




global outcomes="$indices_survey_Andr $indices_secPerc_Andr "

foreach var of varlist treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2  NonEastTreat_FU1 NonEastTreat_FU2 {
rename `var' `var'_original
}

local i=1
foreach question of varlist $outcomes {
*Security_low_Treat_FU1 Security_low_Treat_FU2 Security_high_Treat_FU1 Security_high_Treat_FU2 
		foreach var in treatment_FU1 treatment_FU2 East_Treat_FU1 East_Treat_FU2 East_Only_Treat_FU1 East_Only_Treat_FU2 NonEast_Treat_FU1 NonEast_Treat_FU2{
		gen double `var'_`i'_coef=.
		label var `var'_`i'_coef "Coefficient for `question'"
		gen double `var'_`i'_t=.
		label var `var'_`i'_t "t-stat for `question'"		
		}
	local i=`i'+1
	}
	
 

forvalues x=1/10000{
replace treatment`x'=treatment`x'-1
gen byte treatment_FU1=treatment`x'*FU1
gen byte treatment_FU2=treatment`x'*FU2

gen byte EastTreat_FU1=East*treatment`x'*FU1
gen byte EastTreat_FU2=East*treatment`x'*FU2

gen byte NonEastTreat_FU1=(1-East)*treatment`x'*FU1
gen byte NonEastTreat_FU2=(1-East)*treatment`x'*FU2


*gen byte Security_high_Treat_FU1= Security_high*treatment_FU1
*gen byte Security_high_Treat_FU2= Security_high*treatment_FU2
*gen byte Security_low_Treat_FU1= Security_low*treatment_FU1
*gen byte Security_low_Treat_FU2= Security_low*treatment_FU2

local i=1
foreach question of varlist $outcomes  {


 local lab: variable label `question'							
					areg `question' treatment_FU1 treatment_FU2 , a(Pair_FU) cluster(Cluster)
					replace treatment_FU1_`i'_coef=_b[treatment_FU1] in `x'
					replace treatment_FU2_`i'_coef=_b[treatment_FU2] in `x'
					replace treatment_FU1_`i'_t=_b[treatment_FU1]/_se[treatment_FU1] in `x'
					replace treatment_FU2_`i'_t=_b[treatment_FU2]/_se[treatment_FU2] in `x'
					
					areg `question' treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2, a(Pair_FU) cluster(Cluster)
					replace NonEast_Treat_FU1_`i'_coef=_b[treatment_FU1] in `x'
					replace NonEast_Treat_FU2_`i'_coef=_b[treatment_FU2] in `x'					
					replace East_Treat_FU1_`i'_coef=_b[EastTreat_FU1] in `x'
					replace East_Treat_FU2_`i'_coef=_b[EastTreat_FU2] in `x'
					
					replace NonEast_Treat_FU1_`i'_t=_b[treatment_FU1]/_se[treatment_FU1] in `x'
					replace NonEast_Treat_FU2_`i'_t=_b[treatment_FU2]/_se[treatment_FU2] in `x'					
					replace East_Treat_FU1_`i'_t=_b[EastTreat_FU1]/_se[EastTreat_FU1] in `x'
					replace East_Treat_FU2_`i'_t=_b[EastTreat_FU2]/_se[EastTreat_FU2] in `x'	
					
					areg `question' NonEastTreat_FU1 NonEastTreat_FU2 EastTreat_FU1 EastTreat_FU2, a(Pair_FU) cluster(Cluster)
					replace East_Only_Treat_FU1_`i'_coef=_b[EastTreat_FU1] in `x'
					replace East_Only_Treat_FU2_`i'_coef=_b[EastTreat_FU2] in `x'
					
					replace East_Only_Treat_FU1_`i'_t=_b[EastTreat_FU1]/_se[EastTreat_FU1] in `x'
					replace East_Only_Treat_FU2_`i'_t=_b[EastTreat_FU2]/_se[EastTreat_FU2] in `x'	

					local i=`i'+1
	}
* Security_low_Treat_FU1 Security_low_Treat_FU2 Security_high_Treat_FU1 Security_high_Treat_FU2
drop treatment_FU1 treatment_FU2  EastTreat_FU1 EastTreat_FU2 NonEastTreat_FU1 NonEastTreat_FU2

noisily di "`x'"
}

foreach var in  treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2 NonEastTreat_FU1 NonEastTreat_FU2  {
rename  `var'_original `var'
}




save "$path/results/Simulation_results_100000revision.dta", replace

