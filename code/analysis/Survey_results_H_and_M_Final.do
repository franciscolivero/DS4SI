set more off
clear all
set mem 500m

use "$path/data/processed/Combined_data_H_M_Full_SIGACTS_new.dta", clear




global cond=""
local suffix=""

*global full_outcomes "M7_93z_wins_ln M8_91z_wins_ln MUnemployed MSubsistance M9_05z M9_06z		F13_01x F13_02z  	G2_04_5z_wins_ln  F2_01x F2_034x_wins_ln  F2_05x  F2_05y  M1_05_6z_wins_ln    M11_01z M11_02z M11_03z M11_04z M11_05z M11_10z M11_11z M11_09z M11_13z   M12_19z M12_19X  	F13_06_better F13_06_worse F13_07_better F13_07_worse  M12_17a M12_17B  M12_20z M12_20y" 

global economic_outcomes "M7_93z_wins_ln  M7_92z  M7_91z M8_91z_wins_ln  M8_92z Assets_Household_pca Assets_Livestock_pca M9_03_wins_ln  M9_99z  F8_03y_wins_ln    F8_01z   F2_01x F2_034x_wins_ln  F2_05x  F2_05y  M1_05_6z_wins_ln M9_05z M9_06z		F13_01x F13_02z  "
global security_perc_putcomes "M12_19z M12_19X  	F13_06_better F13_06_worse F13_07_better F13_07_worse  M12_17a M12_17B  M12_20z M12_20y"
global attitudes_outcomes "M11_01z M11_02z M11_03z M11_04z M11_05z M11_10z M11_11z M11_09z M11_13z  "


global indices_survey_Andr "index_Economic_Andr_M    index_PublicGoods_Andr  index_Economic_Andr_Subj G2_04_5z_wins_ln index_Attitudes_Andr_M" 
global indices_secPerc_Andr "index_Security_perc_Andr_M index_Security_perc_Andr_F index_Security_exp_Andr_M"


global indices_survey_Katz "index_Economic_Katz_M    index_PublicGoods_Katz  index_Economic_Katz_Subj  index_Attitudes_Katz_M" 
global indices_secPerc_Katz "index_Security_perc_Katz_M index_Security_perc_Katz_F index_Security_exp_Katz_M"


global indices_survey_pca "index_Economic_pca_M    index_PublicGoods_pca  index_Economic_pca_Subj  index_Attitudes_pca_M" 
global indices_secPerc_pca "index_Security_perc_pca_M index_Security_perc_pca_F index_Security_exp_pca_M"

*Main
local per="FU"

*Table 5
global file_treatment="Table 5 $S_DATE"
global opt="replace"

preserve
	use "$path/results/Simulation_results_100000revision.dta", replace
	local i=1
	foreach question of varlist $indices_survey_Andr  {
						qui areg `question' treatment_FU1 treatment_FU2 , a(Pair_FU) cluster(Cluster)
						qui count if abs(treatment_FU1_`i'_t)>abs(_b[treatment_FU1]/_se[treatment_FU1])
						local p`i'_1=r(N)/10000
						qui count if abs(treatment_FU2_`i'_t)>abs(_b[treatment_FU2]/_se[treatment_FU2])
						local p`i'_2=r(N)/10000							
						local i=`i'+1
				}		
restore	


local i=1
foreach question of varlist $indices_survey_Andr {
 local lab: variable label `question'							
	local lab=subinstr("`lab'","(","[",.)
	local lab=subinstr("`lab'",")","]",.)

					areg `question' treatment_FU1 treatment_FU2 $cond, a(Pair_Survey) cluster(Cluster)
					test treatment_FU1=treatment_FU2
					outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se)  label  ct("`question'", "`lab'") addstat ("Randomized P-values Midline", `p`i'_1', "Randomized P-values Endline", `p`i'_2') se $opt 
					global opt="append"			
					local i=`i'+1
						
}


*Table 8
global file_treatment="Table 8 $S_DATE"
global opt="replace"

preserve
	use "$path/results/Simulation_results_100000revision.dta", replace
	local i=1
	foreach question of varlist $indices_survey_Andr  {		
					qui areg `question' treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2, a(Pair_FU) cluster(Cluster)
					qui count if abs(NonEast_Treat_FU1_`i'_t)>abs(_b[treatment_FU1]/_se[treatment_FU1])
					local p`i'_1=r(N)/10000	
					qui count if abs(NonEast_Treat_FU2_`i'_t)>abs(_b[treatment_FU2]/_se[treatment_FU2])
					local p`i'_2=r(N)/10000	
					
					qui count if abs(East_Treat_FU1_`i'_t)>abs(_b[EastTreat_FU1]/_se[EastTreat_FU1])
					local p`i'_East_1=r(N)/10000	
					qui count if abs(East_Treat_FU2_`i'_t)>abs(_b[EastTreat_FU2]/_se[EastTreat_FU2])
					local p`i'_East_2=r(N)/10000	
					
					local i=`i'+1
		}				
		
restore
local i=1

foreach question of varlist $indices_survey_Andr {
 local lab: variable label `question'							
	local lab=subinstr("`lab'","(","[",.)
	local lab=subinstr("`lab'",")","]",.)
	
	areg `question' treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2 $cond, a(Pair_Survey) cluster(Cluster)			
	outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se)  label  ct("`question'", "`lab'") addstat ("Randomized P-values Midline", `p`i'_1', "Randomized P-values Endline", `p`i'_2', "Randomized P-values PakistanxMidline", `p`i'_East_1', "Randomized P-values PakistanxEndline", `p`i'_East_2') se $opt  		
global opt="append"
local i=`i'+1
}



*Table 8 for the effect in the East
global file_treatment="Table 8 East $S_DATE"
global opt="replace"

preserve
	use "$path/results/Simulation_results_100000revision.dta", replace
	local i=1
	foreach question of varlist $indices_survey_Andr  {		
					qui areg `question' NonEastTreat_FU1 NonEastTreat_FU2 EastTreat_FU1 EastTreat_FU2, a(Pair_FU) cluster(Cluster)
					qui count if abs(East_Only_Treat_FU1_`i'_t)>abs(_b[EastTreat_FU1]/_se[EastTreat_FU1])
					local p`i'_1=r(N)/10000	
					n: di %-60s  "`question' EastTreat_FU1 percent smaller" %9.3f _b[EastTreat_FU1] %9.3f   r(N)/10000					
					qui count if abs(East_Only_Treat_FU2_`i'_t)>abs(_b[EastTreat_FU2]/_se[EastTreat_FU2])
					local p`i'_2=r(N)/10000	
					
					local i=`i'+1
		}		
restore		

local i=1

foreach question of varlist $indices_survey_Andr {
	local lab: variable label `question'							
	local lab=subinstr("`lab'","(","[",.)
	local lab=subinstr("`lab'",")","]",.)
	
	areg `question' NonEastTreat_FU1 NonEastTreat_FU2 EastTreat_FU1 EastTreat_FU2 $cond, a(Pair_Survey) cluster(Cluster)			
	outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se)  label  ct("`question'", "`lab'") addstat ("Randomized P-values Pakistan Midline", `p`i'_1', "Randomized P-values Pakistan Endline", `p`i'_2')  se $opt 
	local i=`i'+1
					
							
global opt="append"
}

****Table 9
global file_treatment="Table 9 $S_DATE"
global opt="replace"

preserve
	use "$path/results/Simulation_results_100000revision.dta", replace
	local i=6
	foreach question of varlist $indices_secPerc_Andr  {	
					qui areg `question' treatment_FU1 treatment_FU2 , a(Pair_FU) cluster(Cluster)
					qui count if abs(treatment_FU1_`i'_t)>abs(_b[treatment_FU1]/_se[treatment_FU1])
					local p`i'_1=r(N)/10000	
					qui count if abs(treatment_FU2_`i'_t)>abs(_b[treatment_FU2]/_se[treatment_FU2])
					local p`i'_2=r(N)/10000	
					
					qui areg `question' treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2, a(Pair_FU) cluster(Cluster)
					qui count if abs(NonEast_Treat_FU1_`i'_t)>abs(_b[treatment_FU1]/_se[treatment_FU1])
					local p`i'_NonEast_1=r(N)/10000	
					qui count if abs(NonEast_Treat_FU2_`i'_t)>abs(_b[treatment_FU2]/_se[treatment_FU2])
					local p`i'_NonEast_2=r(N)/10000	
					
					qui count if abs(East_Treat_FU1_`i'_t)>abs(_b[EastTreat_FU1]/_se[EastTreat_FU1])
					local p`i'_East_1=r(N)/10000	
					qui count if abs(East_Treat_FU2_`i'_t)>abs(_b[EastTreat_FU2]/_se[EastTreat_FU2])
					local p`i'_East_2=r(N)/10000	
							
					local i=`i'+1
		}		
restore		


local i=6
foreach question of varlist $indices_secPerc_Andr {
	local lab: variable label `question'							
	local lab=subinstr("`lab'","(","[",.)
	local lab=subinstr("`lab'",")","]",.)
	
					areg `question' treatment_FU1 treatment_FU2 $cond, a(Pair_Survey) cluster(Cluster)
					outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se) label  addstat ("Randomized P-values Midline", `p`i'_1', "Randomized P-values Endline", `p`i'_2')   se `opt' 
					global opt="append"			
	
	
					areg `question' treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2 $cond, a(Pair_Survey) cluster(Cluster)			
					outreg2 using "$file_treatment.xls",dec(3) adec(3) aster(se) label  addstat ("Randomized P-values Midline", `p`i'_NonEast_1', "Randomized P-values Endline", `p`i'_NonEast_2', "Randomized P-values PakistanxMidline", `p`i'_East_1', "Randomized P-values PakistanxEndline", `p`i'_East_2')   se `opt'
					local i=`i'+1
}


*Table 9 or the effect in the East
global file_treatment="Table 9 East $S_DATE"
global opt="replace"

preserve
	use "$path/results/Simulation_results_100000revision.dta", replace
	local i=6
	foreach question of varlist $indices_secPerc_Andr  {					
					
					qui areg `question' NonEastTreat_FU1 NonEastTreat_FU2 EastTreat_FU1 EastTreat_FU2, a(Pair_FU) cluster(Cluster)
					qui count if float(abs(East_Only_Treat_FU1_`i'_t))>float(abs(_b[EastTreat_FU1]/_se[EastTreat_FU1]))
					local p`i'_1=r(N)/10000	
					qui count if float(abs(East_Only_Treat_FU2_`i'_t))>float(abs(_b[EastTreat_FU2]/_se[EastTreat_FU2]))
					local p`i'_2=r(N)/10000	
					local i=`i'+1
		}		
restore		

local i=6
foreach question of varlist $indices_secPerc_Andr {
					local lab: variable label `question'							
					local lab=subinstr("`lab'","(","[",.)
					local lab=subinstr("`lab'",")","]",.)
					
					areg `question' NonEastTreat_FU1 NonEastTreat_FU2 EastTreat_FU1 EastTreat_FU2 $cond, a(Pair_Survey) cluster(Cluster)
					outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se) label  addstat ("Randomized P-values Pakistan Midline", `p`i'_1', "Randomized P-values Pakistan Endline", `p`i'_2')  se $opt 
					local i=`i'+1					
					global opt="append"
}




****ONLINE APPENDIX


*Correlation between measures of violence (Table A.10)
gen District_Survey=Geocode1*10+Survey
rename Survey FU
merge m:1 Geocode FU using "$path/data/processed/Security_indices_summary.dta", nogen


global file_treatment="Table  A10 $S_DATE"
global opt="replace"
foreach inc in "dum"  "wins_ln"  {
	areg index_Security_perc_Andr_M Inc_`inc'_Anderson ,cluster(Cluster) a(District_Survey)
	outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label se $opt 
	global opt="append"
	areg index_Security_perc_Andr_M Inc_`inc'_Anderson ,cluster(Cluster) a(Pair_Survey)
	outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label se $opt 

	areg index_Security_perc_Andr_F Inc_`inc'_Anderson ,cluster(Cluster) a(District_Survey)
	outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label se $opt 


	areg index_Security_perc_Andr_F Inc_`inc'_Anderson ,cluster(Cluster) a(Pair_Survey)
	outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label se $opt 

	areg index_Security_exp_Andr_M Inc_`inc'_Anderson ,cluster(Cluster) a(District_Survey)
	outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label se $opt 

	areg index_Security_exp_Andr_M Inc_`inc'_Anderson ,cluster(Cluster) a(Pair_Survey)
	outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label se $opt 
}




*Resuts for individual outcomes - Security Perceptions Table A11
global file_treatment="Table A11 $S_DATE"
global opt="replace"
foreach question of varlist $security_perc_putcomes {
 local lab: variable label `question'							
	local lab=subinstr("`lab'","(","[",.)
	local lab=subinstr("`lab'",")","]",.)
	

					areg `question' treatment_FU1 treatment_FU2 $cond, a(Pair_Survey) cluster(Cluster)
					test treatment_FU1=treatment_FU2
					outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label  ct("`question'", "`lab'") addstat("p-value for equality of effects", r(p)) se $opt 
					global opt="append"			
					areg `question' treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2 $cond, a(Pair_Survey) cluster(Cluster)			
					test treatment_FU1+EastTreat_FU1=0
					local EastFU1=r(p) 
					if r(p)==. {
					local EastFU1=1				
					}					
					test treatment_FU2+EastTreat_FU2=0
					local EastFU2=r(p)
					test treatment_FU1=treatment_FU2
					outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label  ct("`question'", "`lab'") addstat("p-value for equality of effects", r(p),"p-value for Effect in East FU1", `EastFU1', "p-value for Effect in East FU2", `EastFU2') se $opt 

global opt="append"
}







*Resuts for individual outcomes - Economic outcomes Table A12
global file_treatment="Table A12 $S_DATE"
global opt="replace"
foreach question of varlist $economic_outcomes {
 local lab: variable label `question'							
	local lab=subinstr("`lab'","(","[",.)
	local lab=subinstr("`lab'",")","]",.)
	

					areg `question' treatment_FU1 treatment_FU2 $cond, a(Pair_Survey) cluster(Cluster)
					test treatment_FU1=treatment_FU2
					outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label  ct("`question'", "`lab'") addstat("p-value for equality of effects", r(p)) se $opt 
					global opt="append"			
					areg `question' treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2 $cond, a(Pair_Survey) cluster(Cluster)			
					test treatment_FU1+EastTreat_FU1=0
					local EastFU1=r(p) 
					if r(p)==. {
					local EastFU1=1				
					}					
					test treatment_FU2+EastTreat_FU2=0
					local EastFU2=r(p)
					test treatment_FU1=treatment_FU2
					outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label  ct("`question'", "`lab'") addstat("p-value for equality of effects", r(p),"p-value for Effect in East FU1", `EastFU1', "p-value for Effect in East FU2", `EastFU2') se $opt 

global opt="append"
}

*Resuts for individual outcomes - Attitudes Table A13

global file_treatment="Table A13 $S_DATE"
global opt="replace"
foreach question of varlist $attitudes_outcomes {
 local lab: variable label `question'							
	local lab=subinstr("`lab'","(","[",.)
	local lab=subinstr("`lab'",")","]",.)
	

					areg `question' treatment_FU1 treatment_FU2 $cond, a(Pair_Survey) cluster(Cluster)
					test treatment_FU1=treatment_FU2
					outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label  ct("`question'", "`lab'") addstat("p-value for equality of effects", r(p)) se $opt 
					global opt="append"			
					areg `question' treatment_FU1 treatment_FU2 EastTreat_FU1 EastTreat_FU2 $cond, a(Pair_Survey) cluster(Cluster)			
					test treatment_FU1+EastTreat_FU1=0
					local EastFU1=r(p) 
					if r(p)==. {
					local EastFU1=1				
					}					
					test treatment_FU2+EastTreat_FU2=0
					local EastFU2=r(p)
					test treatment_FU1=treatment_FU2
					outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label  ct("`question'", "`lab'") addstat("p-value for equality of effects", r(p),"p-value for Effect in East FU1", `EastFU1', "p-value for Effect in East FU2", `EastFU2') se $opt 

global opt="append"
}


