set more off
set matsize 11000
tempfile FU1 FU2 prob bsobs
set seed 123456789



use "$path/data/raw/2FU-1FU-BS MHH Name Matches BS.dta", clear
rename  bs HH_Code
rename A2FU HH_Code_FU
rename Respondent_is_Same_in_BS Respondent_is_Same_in_FU2
rename HH_is_Same_in_BS HH_is_Same_in_FU2

duplicates tag HH_Code, gen(tag)
drop if tag & Respondent_is_Same_in_FU2==0
drop tag
save `FU2'


use "$path/data/raw/Respondents continuity BS-FU Ready.dta", clear
drop Geocode
rename Same_respondent Respondent_is_Same_in_FU1
gen HH_is_Same_in_FU1=(Respondent_is_Same_in_FU1 <3)
replace Respondent_is_Same_in_FU1=0 if Respondent_is_Same_in_FU1!=1
drop Household_Code
save `FU1'



use "$path/data/raw/MHH_BS.dta", clear
rename Household_Code HH_Code
preserve
gen byte BS_observation=1
gen Instrument="MHH"
keep HH_Code BS_observation Instrument
save `bsobs'



restore 
merge 1:1 HH_Code using `FU1', gen (merge_FU1)
merge 1:1 HH_Code using `FU2', gen (merge_FU2)

foreach var of varlist Respondent_is_Same_in_FU1 HH_is_Same_in_FU1 Respondent_is_Same_in_FU2 HH_is_Same_in_FU2 {
replace `var'=0 if `var'!=1
}

sort  HH_Code

**Variables used to control for baseline characteristics

gen Unemployed_BS= (Q_1_03==0 | Q_1_03==1 | Q_1_03==2 | Q_1_03==98) if Q_1_03!=.
gen Subsistance_BS= (Q_1_03==5 | Q_1_03==6 |Q_1_03==11) if Q_1_03!=.

egen Income_BS=rowtotal(Q_6_04_First Q_6_08_Second Q_6_12_Third)
gen LnIncome_BS=ln(Income*12)
qui sum LnIncome_BS, d
replace LnIncome_BS=r(p1) if LnIncome_BS<r(p1)
replace LnIncome_BS=r(p99) if LnIncome_BS>r(p99) & LnIncome_BS!=.



egen Exp_Month=rowtotal(Q_6_13 -Q_6_18)
egen Exp_Year=rowtotal(Q_6_19 -Q_6_29)
gen LnExpenditures_BS=ln(Exp_Month*12+Exp_Year)
qui sum LnExpenditures_BS, d
replace LnExpenditures_BS =r(p1) if LnExpenditures_BS <r(p1)
replace LnExpenditures_BS =r(p99) if LnExpenditures_BS>r(p99) & LnExpenditures_BS!=.

gen Q_8_14z=(Q_8_14==1) if Q_8_14!=.
 
 label var  Q_8_14z "Has your household condition improved"
 
 foreach x of numlist 7/9 {
egen Nonmissing=rownonmiss(Q_5_0`x'_* ) 
replace Q_5_0`x'_All_People=0 if Q_5_0`x'_All_People==. & Nonmissing>0
drop Nonmissing
}

rename  Q_5_15_Themseleves  Q_5_15_Themselves
replace Q_6_31=. if Q_6_31>=8888

foreach x of numlist 10/16 {
egen Nonmissing=rownonmiss(Q_5_`x'_* ) 
replace Q_5_`x'_All_People=0 if Q_5_`x'_All_People==. & Nonmissing>0
drop Nonmissing
}



* Additional variables

replace Q_1_02=. if Q_1_02>1377 & Q_1_02<1908
replace Q_1_02=. if Q_1_02<1287
replace Q_1_02=. if Q_1_02>6000
gen Age=2008-Q_1_02
replace Age=2007-Q_1_02-(2007-1387) if Q_1_02<1900
replace Age =. if Age <15


*Q_1_05 size of household

gen Noeduc=(Q_1_04==1) if Q_1_04!=.
label var Noeduc "Do not have formal education"
gen Pashtun=(Q_1_12==1) if Q_1_12!=.
label var Pashtun "Mother tongue is pashtu"
gen Food=(Q_6_42==1 | Q_6_42==2) if Q_6_42!=.
label var Food "Never of rarely have problems supplying food"

gen Happy=(Q_1_01==1 | Q_1_01==2) if Q_1_01!=.
label var Happy "Happy or very happy"
gen Water_spring=(Q_2_01==7) if Q_2_01!=.
label var Water_spring "Main source of dinking water is unprotect spring"
gen Electricity=(Q_2_07==2) if Q_2_01!=.
label var Electricity"Have access to electricity "

gen Geocode1=floor(Geocode/1000000000)
egen Pair=group(Geocode1 C2)

gen byte MLand_owns=(Q_6_68==2 | Q_6_68==3) if Q_6_68!=.




**************************************************

* Panel B of Table A.14

global  file_treatment="Attrition Individual Table A14 $S_DATE"
global opt="replace"


	reg Respondent_is_Same_in_FU1 treatment,  cluster(Geocode)
	outreg2 using "$file_treatment.xls",  bdec(3)   se  $opt
	global opt="append"	
	reg Respondent_is_Same_in_FU2  treatment, cluster(Geocode) 
	outreg2 using "$file_treatment.xls",  bdec(3)   se  $opt

	
	reg Respondent_is_Same_in_FU1 Q_1_05 Age   Pashtun Unemployed_BS Subsistance_BS  Noeduc MLand_owns LnExpenditures_BS,  cluster(Geocode)
	outreg2 using "$file_treatment.xls",  bdec(3)   se  $opt
	predict prob_nonattritionFU1 
	
	reg Respondent_is_Same_in_FU2   Q_1_05 Age   Pashtun Unemployed_BS Subsistance_BS  Noeduc MLand_owns LnExpenditures_BS,  cluster(Geocode)
	outreg2 using "$file_treatment.xls",  bdec(3)   se  $opt
	predict prob_nonattritionFU2

	reg prob_nonattritionFU1 treatment,  cluster(Geocode)
	outreg2 using "$file_treatment.xls",  bdec(3)   se  $opt
	reg prob_nonattritionFU2  treatment, cluster(Geocode) 
	outreg2 using "$file_treatment.xls",  bdec(3)   se  $opt


	

keep HH_Code prob_nonattritionFU1 prob_nonattritionFU2
reshape long prob_nonattritionFU, i(HH_Code) j(Survey)
save `prob'


use "$path/data/processed/Combined_data_H_M_Full_SIGACTS_new.dta", clear
merge m:1 HH_Code Survey using `prob', gen(_merge_attrit)

gen TrFU1_prob_nonattritionFU=treatment_FU1*prob_nonattritionFU
gen TrFU2_prob_nonattritionFU=treatment_FU2*prob_nonattritionFU
gen prob_nonattritionFU1=prob_nonattritionFU*FU1
gen prob_nonattritionFU2=prob_nonattritionFU*FU2

global indices_Andr " index_Economic_Andr_M index_PublicGoods_Andr  index_Economic_Andr_Subj    index_Attitudes_Andr_M index_Security_perc_Andr_M index_Security_perc_Andr_F index_Security_exp_Andr_M"


global  file_treatment="Attrition Individual Table A15 $S_DATE"
global opt="replace"


foreach question of varlist  $indices_Andr {
	

	areg `question' treatment_FU1 treatment_FU2 TrFU1_prob_nonattritionFU TrFU2_prob_nonattritionFU prob_nonattritionFU , a(Pair_Survey) cluster(Cluster)
	outreg2 using "$file_treatment.xls", bdec(3) aster(se)  label  ct("`question'", "`lab'") se $opt 
	global opt="append"

	
	}


*****Lee bounds
preserve
keep if Instrument=="HH"
merge m:1 HH_Code using  `bsobs', nogen
xi i.Pair_Survey


replace HH_is_Same_in_FU1=0 if HH_is_Same_in_FU1==.
replace HH_is_Same_in_FU2=0 if HH_is_Same_in_FU2==.



global file_treatment_leebound="Attrition Individual Table A16 $S_DATE"
 	global opt="replace" 

	

foreach question of varlist $indices_Andr {
	forvalues survey=1/2 {
		reg `question' _I*  if Survey==`survey'
		predict `question'_Flt`survey', res
		leebounds `question'_Flt`survey' treatment if Survey==`survey', select(HH_is_Same_in_FU`survey') cieffect vce(bootstrap, reps(1000)) 
		outreg2 using "$file_treatment_leebound.xls", bdec(3)  label addstat("Lower bound FU1", e(cilower), "Upper bound FU1", e(ciupper))   se $opt 
		global opt="append" 
	}	
}


