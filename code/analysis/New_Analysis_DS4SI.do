*******New Analysis************************
set more off
clear all
set mem 500m

*If you want to run only this do-file please set your global path in the lines below, activate, and run it. 
*global path "C:/Users/Francisco Olivero/Dropbox/NYU/Subjects/01. I Semester/DataScience/Final Project/198483-V1"

*If you want to run only this do-file please deactivate the run below to export tables. 
*cd "$path/results/"


*set working directory.
use "$path/data/processed/Combined_data_H_M_Full_SIGACTS_new.dta", clear


global cond=""
local suffix=""

* Creating global variables.
global economic_perspectives "M9_05z M9_06z F13_01x F13_02z"

global ngo_perception "M11_09z"

global education_improvements "MRead_correct MCalculation_correct FRead_attempt FCalculation_correct"

global loan "M9_03_wins_ln"

global female_owners "FLand_owns"

*Note: In order to mantain consistency with the original paper, all the results here are export in the same format as the original paper. 

*Results for individual outcomes - Economic Perspectives Table P1

global file_treatment="Table P1 $S_DATE"
global opt="replace"


foreach question of varlist $economic_perspectives {
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


*Results for individual outcomes - NGO Perceptions Table P2

global file_treatment="Table P2 $S_DATE"
global opt="replace"
foreach question of varlist $ngo_perception {
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

*Results for individual outcomes - Education Improvements Table P3

global file_treatment="Table P3 $S_DATE"
global opt="replace"
foreach question of varlist $education_improvements {
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

*Results for individual outcomes - Loans Table P4

global file_treatment="Table P4 $S_DATE"
global opt="replace"
foreach question of varlist $loan {
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

*Results for individual outcomes - Education Improvements Table P5

global file_treatment="Table P5 $S_DATE"
global opt="replace"
foreach question of varlist $female_owners {
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
