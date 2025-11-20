*******New Analysis************************
set more off
clear all
set mem 500m

use "$path/data/processed/Combined_data_H_M_Full_SIGACTS_new.dta", clear


global cond=""
local suffix=""


global economic_perspectives "M9_05z M9_06z F13_01x F13_02z"

global ngo_perception "M11_09z"

global education_improvements "FCalculation_correct MRead_correct MCalculation_correct"

global loan "M9_03_wins_ln"

global female_owners "FLand_owns"


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
