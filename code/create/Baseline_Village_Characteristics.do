set more off
cd "$path/results/"

use "$path/data/raw/MHH_BS.dta", clear


replace Q_1_02=. if Q_1_02>1377 & Q_1_02<1908
replace Q_1_02=. if Q_1_02<1287
replace Q_1_02=. if Q_1_02>6000
gen Age=2008-Q_1_02
replace Age=2007-Q_1_02-(2007-1387) if Q_1_02<1900


*gen Age=Q_1_02
label var Age "Age"
gen Noeduc=(Q_1_04==1) if Q_1_04!=.
label var Noeduc "Do not have formal education"
gen Dari=(Q_1_12==2) if Q_1_12!=.
label var Dari "Mother tongue is dari"
gen Pashtu=(Q_1_12==1) if Q_1_12!=.
label var Pashtu "Mother tongue is Pashtu"

gen Food=(Q_6_42==1 | Q_6_42==2) if Q_6_42!=.
label var Food "Never of rarely have problems supplying food"
gen Water_spring=(Q_2_01==7) if Q_2_01!=.
label var Water_spring "Main source of dinking water is unprotect spring"
gen Electricity=(Q_2_07==2) if Q_2_07!=.
label var Electricity"Have access to electricity "
gen Male_healthworker=(Q_2_18==2) if Q_2_18!=.
label var Male_healthworker "Male healthworker available"
gen Female_healthworker=(Q_2_19==2) if Q_2_19!=.
label var Female_healthworker "Female healthworker available"
gen Loan=(Q_7_01==2) if Q_7_01!=.
label var Loan "Received a loan"
gen Dispute=(Q_5_01==2) if Q_5_01!=.
label var Dispute "Dispute in village"
gen AttendShura=(Q_3_13==2) if Q_3_13!=.
label var AttendShura "Attended shura meetings"
gen WomenShura=(Q_3_31==2) if Q_3_31!=.
label var WomenShura "Women should be shura members"

egen Exp_Month=rowtotal(Q_6_13 -Q_6_18)
egen Exp_Year=rowtotal(Q_6_19 -Q_6_29)
gen LnExpenditures_BS=ln(Exp_Month*12+Exp_Year)
qui sum LnExpenditures_BS, d
replace LnExpenditures_BS =r(p1) if LnExpenditures_BS <r(p1)
replace LnExpenditures_BS =r(p99) if LnExpenditures_BS>r(p99) & LnExpenditures_BS!=.


egen Land_nonmis=rownonmiss( Q_6_69_Garden_Own Q_6_69_Irrigated_Own Q_6_69_Rainfeed_Own)
foreach var of varlist  Q_6_69_Garden_Own Q_6_69_Irrigated_Own Q_6_69_Rainfeed_Own {
replace `var'=0 if Land_nonmis!=0 & `var'==.
}
gen Land_Owned=Q_6_69_Garden_Own+Q_6_69_Irrigated_Own+Q_6_69_Rainfeed_Own
replace Land_Owned=0 if  (Q_6_68==1 |  Q_6_68==4)


gen Unemployed_BS= (Q_1_03==0 | Q_1_03==1 | Q_1_03==2 | Q_1_03==98) if Q_1_03!=.
gen Subsistance_BS= (Q_1_03==5 | Q_1_03==6 |Q_1_03==11) if Q_1_03!=.


foreach var of varlist  Land_Owned  Q_6_61 Q_6_62 Q_6_63 Q_6_64 Q_6_65 Q_6_66 Q_6_44- Q_6_60 {
qui sum `var'
gen `var'Z=(`var'-r(mean))/r(sd)
}


egen  Assets_BS=rowmean(Land_OwnedZ- Q_6_60Z)
drop Land_OwnedZ- Q_6_60Z	
label var Assets_BS "Assets"


gen Primary_Secondary_income_ln_BS=ln(Q_6_04_First+Q_6_08_Second)
label var Primary_Secondary_income_ln_BS "Ln(Income)"

gen Ln_Food_Consumption=ln( Q_6_13)
label var Ln_Food_Consumption "Ln(Food expenditures)"


gen byte MLand_owns=(Q_6_68==2 | Q_6_68==3) if Q_6_68!=.

global file="Balance_check"
global opt="replace"

***Generating Table 1. t-stats in a separate file


*Water_spring  wheelbarrow plow mobilephone radio sheep donkey  Q_6_15   Tax Project_water Project_school Project_health Project_road  Trust
foreach var of varlist  Q_1_10   Q_1_05 Age Pashtu Unemployed_BS  Subsistance_BS Noeduc MLand_owns Electricity  Male_healthworker Female_healthworker Water_spring  Dispute   Food    Loan  AttendShura Q_6_25 Q_6_13 WomenShura Assets_BS Primary_Secondary_income_ln_BS   LnExpenditures_BS {
local lab: var label `var'
qui sum `var' if treatment==1
local MeanContr=r(mean)
qui: sum `var' if treatment==2
local MeanTreat=r(mean)
qui: sum `var'
local SD=r(sd)
local Norm=((`MeanTreat'-`MeanContr')/`SD')
di %-90s "`lab'" %-9.2f `MeanContr' %-9.2f `MeanTreat' %-9.2f `MaenContr' %-9.2f `Norm'
}


gen Treatment=treatment-1

rename Primary_Secondary_income_ln_BS Prima_Sec_income_ln_BS


collapse Q_1_10   Q_1_05 Age Pashtu Unemployed_BS  Subsistance_BS Noeduc MLand_owns Electricity  Male_healthworker Female_healthworker Water_spring  Dispute   Food    Loan  AttendShura Q_6_25 Q_6_13 WomenShura Assets_BS Prima_Sec_income_ln_BS LnExpenditures_BS, by(Geocode)
replace Geocode=Geocode/100000

foreach var of varlist Q_1_10   Q_1_05 Age Pashtu Unemployed_BS  Subsistance_BS  Noeduc MLand_owns Electricity  Male_healthworker Female_healthworker Water_spring  Dispute   Food    Loan  AttendShura Q_6_25 Q_6_13 WomenShura Assets_BS Prima_Sec_income_ln_BS  LnExpenditures_BS{
 label var `var' "`l_`var''"
}

save "$path/data/processed/Baseline_Village_Characteristics", replace

* For security related measures
n: di "Incidents"
use "$path/data/processed/SIGACTS_cleaned_panel_prepared.dta", clear
local period="FU"
collapse (sum) Inc*km* , by (Geocode `period')
replace `period'=0 if `period'==.
tsset Geocode `period'
tsfill, full
merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta", keepusing (Geocode1 treatment  POINT_X POINT_Y atlarge referendum C5 C2) nogen
replace treatment=treatment-1
foreach var of varlist  Inc*km*  {
	replace `var'=0 if `var'==.
}	
keep if FU==0
keep Inc1km Inc2km Inc5km Inc10km Inc15km  Geocode treatment


rename treatment Treatment

merge 1:1 Geocode using "$path/data/processed/Baseline_Village_Characteristics"
drop _merge
foreach var of varlist Inc2km Inc5km Inc10km Inc15km   {
	rename `var' `var'_BS
}

foreach var of varlist Inc2km_BS- Prima_Sec_income_ln_BS {
qui sum `var'
replace `var'=r(mean) if `var'==.
}

save "$path/data/processed/Baseline_Village_Characteristics", replace
