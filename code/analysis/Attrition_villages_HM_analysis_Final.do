set more off
tempfile attr
set seed 123456789




use "$path/data/processed/Combined_data_H_M_Full_SIGACTS_new.dta", clear
drop _merge
merge m:1 Geocode Survey using "$path/data/raw/Attrition_villages_FU1_FU2.dta"
drop if _merge==1
drop _merge
merge m:1 Geocode using "$path/data/processed/Baseline_Village_Characteristics", update


global predictors="Inc15km_BS Q_1_10 Q_1_05 Age Pashtu Unemployed_BS Subsistance_BS Noeduc MLand_owns LnExpenditures_BS"

foreach secur of varlist $predictors {
	gen `secur'_FU1=`secur'*FU1
	gen `secur'_FU2=`secur'*FU2
}


preserve
collapse Surveyed_* treatment Cluster $predictors, by(Geocode Survey)


* Panel A of Table A.14

global file_treatment="Attrition Village Table A14 $S_DATE"


global opt="replace"
*Checking whether village-level attrition is correlated with treatment status
foreach instr in MHH  {
	reg Surveyed_`instr' treatment if Survey==1, cluster(Cluster)
	outreg2 using "$file_treatment.xls",  bdec(3)  label  se $opt 
	global opt="append"
	reg Surveyed_`instr' treatment if Survey==2, cluster(Cluster)
	outreg2 using "$file_treatment.xls",  bdec(3)  label  se $opt 
	
	reg Surveyed_`instr'   $predictors  if Survey==1,  cluster(Geocode)
	outreg2 using "$file_treatment.xls",  bdec(3)   se  $opt
	predict prob_nonattrition_`instr' if Survey==1
	
	reg Surveyed_`instr'    $predictors   if Survey==2,  cluster(Geocode)
	outreg2 using "$file_treatment.xls",  bdec(3)   se  $opt
	predict prob_nonattrition_`instr'FU2 if Survey==2
	replace prob_nonattrition_`instr'=prob_nonattrition_`instr'FU2 if Survey==2
	drop prob_nonattrition_`instr'FU2
	
	reg prob_nonattrition_`instr' treatment if Survey==1, cluster(Cluster)
	outreg2 using "$file_treatment.xls",  bdec(3)  label  se $opt 
	reg prob_nonattrition_`instr' treatment if Survey==2, cluster(Cluster)
	outreg2 using "$file_treatment.xls",  bdec(3)  label  se $opt 
	
}

keep Geocode Survey prob_nonattrition_*
save `attr'
restore
drop _merge
merge m:1 Geocode Survey using "`attr'"

global indices_Andr " index_Economic_Andr_M index_PublicGoods_Andr  index_Economic_Andr_Subj    index_Attitudes_Andr_M index_Security_perc_Andr_M index_Security_perc_Andr_F index_Security_exp_Andr_M"


*Checking whether village-level attrition is correlated with violence and treatment status 
*Incidents_wins_ln_AndrFU Incidents_wins_ln_pcaFU

*global indices_Katz "Inc_wins_ln_Katz index_Economic_Katz_M  index_Economic_Katz_Subj  index_PublicGoods_Katz  index_Attitudes_Katz_M index_Security_perc_Katz_M index_Security_perc_Katz_F *index_Security_exp_Katz_M"


* Panel A of Table A.15

global file_treatment="Attrition Village Table A15 $S_DATE"
global opt="replace"


foreach instr in MHH  {
gen TrFU1_prob_nonattritionFU_`instr'=treatment_FU1*prob_nonattrition_`instr'
gen TrFU2_prob_nonattritionFU_`instr'=treatment_FU2*prob_nonattrition_`instr'
gen prob_nonattritionFU1_`instr'=prob_nonattrition_`instr'*FU1
gen prob_nonattritionFU2_`instr'=prob_nonattrition_`instr'*FU2


foreach var in   $indices_Andr  {

	areg `var' treatment_FU1 treatment_FU2 TrFU1_prob_nonattritionFU_`instr' TrFU2_prob_nonattritionFU_`instr' prob_nonattrition_`instr'  , a(Pair_Survey) cluster(Cluster)
	outreg2 using "$file_treatment.xls",  bdec(3)  label  se $opt 
global opt="append"
	}
}



*keep if Instrument=="HH"
*merge m:1 HH_Code using  `bsobs', nogen
xi i.Pair


*global indices_Katz " index_Economic_Katz_M  index_Economic_Katz_Subj  index_PublicGoods_Katz  index_Attitudes_Katz_M index_Security_perc_Katz_M index_Security_perc_Katz_F index_Security_exp_Katz_M"

global file_treatment_leebound="Attrition Village Table A16 $S_DATE "
 	global opt="replace" 
	



foreach question of varlist $indices_Andr {
	forvalues survey=1/2 {
		reg `question' _I*  if Survey==`survey'
		predict `question'_Flt`survey', res
		leebounds `question'_Flt`survey' treatment if Survey==`survey', select(Surveyed_MHH) cieffect vce(bootstrap, reps(1000)) 
		outreg2 using "$file_treatment_leebound.xls", bdec(3)  label addstat("Lower bound FU1", e(cilower), "Upper bound FU1", e(ciupper))   se $opt 
		global opt="append" 
	}	
}
