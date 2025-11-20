set more off


use "$path/data/raw/MHH_BS.dta", clear

replace Q_1_02=. if Q_1_02>1377 & Q_1_02<1908
replace Q_1_02=. if Q_1_02<1287
replace Q_1_02=. if Q_1_02>6000
gen Age=2008-Q_1_02
replace Age=2007-Q_1_02-(2007-1387) if Q_1_02<1900



label var Q_1_10 "Number of Households in Village"
label var Q_1_05 "Number of People in Household"

label var Age "Age of Respondent"

gen Pashtu=(Q_1_12==1) if Q_1_12!=.
label var Pashtu "Respondent Speaks Pashtu as Mother Tongue"

gen Unemployed_BS= (Q_1_03==0 | Q_1_03==1 | Q_1_03==2 | Q_1_03==98) if Q_1_03!=.
label var Unemployed_BS "Respondent is Unemployed"
gen Subsistance_BS= (Q_1_03==5 | Q_1_03==6 |Q_1_03==11) if Q_1_03!=.
label var Subsistance_BS "Respondent Employed in Agriculture or Animal Husbandry"

gen Noeduc=(Q_1_04==1) if Q_1_04!=.
label var Noeduc "Respondent Received No Formal Education"

gen byte MLand_owns=(Q_6_68==2 | Q_6_68==3) if Q_6_68!=.
label var MLand_owns "Respondent Owns Land"

gen Electricity=(Q_2_07==2) if Q_2_07!=.
label var Electricity "Household has Access to Electricity"


gen Male_healthworker=(Q_2_18==2) if Q_2_18!=.
label var Male_healthworker "Male Health Worker is Available to Treat Villagers"
gen Female_healthworker=(Q_2_19==2) if Q_2_19!=.
label var Female_healthworker "Female Health Worker is Available to Treat Villagers"
gen Water_spring=(Q_2_01==7) if Q_2_01!=.
label var Water_spring "Main Source of Drinking Water is Unprotected Spring"
gen Dispute=(Q_5_01==2) if Q_5_01!=.
label var Dispute "Dispute among Villagers Occurred in Past Year"
gen Food=(Q_6_42==1 | Q_6_42==2) if Q_6_42!=.
label var Food "Household has No Problems Meeting Food Needs"
gen Loan=(Q_7_01==2) if Q_7_01!=.
label var Loan "Household Borrowed Money in Past Year"
gen AttendShura=(Q_3_13==2) if Q_3_13!=.
label var AttendShura "Respondent Attended Village Council Meeting in Past Year"
gen WomenShura=(Q_3_31==2) if Q_3_31!=.
label var WomenShura "Respondent Believes Women Should be Council Members"


egen Land_nonmis=rownonmiss( Q_6_69_Garden_Own Q_6_69_Irrigated_Own Q_6_69_Rainfeed_Own)
foreach var of varlist  Q_6_69_Garden_Own Q_6_69_Irrigated_Own Q_6_69_Rainfeed_Own {
replace `var'=0 if Land_nonmis!=0 & `var'==.
}


gen Land_Owned=Q_6_69_Garden_Own+Q_6_69_Irrigated_Own+Q_6_69_Rainfeed_Own
replace Land_Owned=0 if  (Q_6_68==1 |  Q_6_68==4)

foreach var of varlist  Land_Owned  Q_6_61 Q_6_62 Q_6_63 Q_6_64 Q_6_65 Q_6_66 Q_6_44- Q_6_60 {
qui sum `var'
gen `var'Z=(`var'-r(mean))/r(sd)
}
egen  Assets_BS=rowmean(Land_OwnedZ- Q_6_60Z)
drop Land_OwnedZ- Q_6_60Z	  
label var Assets_BS "Index of Assets"

gen Primary_Secondary_income_ln_BS=ln(Q_6_04_First+Q_6_08_Second)
label var Primary_Secondary_income_ln_BS "Natural Log of Income"

egen Exp_Month=rowtotal(Q_6_13 -Q_6_18)
egen Exp_Year=rowtotal(Q_6_19 -Q_6_29)
gen LnExpenditures_BS=ln(Exp_Month*12+Exp_Year)
qui sum LnExpenditures_BS, d
replace LnExpenditures_BS =r(p1) if LnExpenditures_BS <r(p1)
replace LnExpenditures_BS =r(p99) if LnExpenditures_BS>r(p99) & LnExpenditures_BS!=.
label var LnExpenditures_BS "Natural Log of Consumption"


global file="Table 2 $S_DATE"

putexcel set "$file", replace

putexcel A1="Variable"
putexcel B1="Mean Level in Control Group"
putexcel C1="Mean Level in Treatment Group"
putexcel D1="Normalized Difference"
putexcel E1="t-Statistic"


local row=2
***Generating Table 2.


gen Treatment=treatment-1
foreach var of varlist  Q_1_10   Q_1_05 Age Pashtu Unemployed_BS  Subsistance_BS Noeduc MLand_owns Electricity  Male_healthworker Female_healthworker Water_spring  Dispute   Food    Loan  AttendShura  WomenShura Assets_BS Primary_Secondary_income_ln_BS   LnExpenditures_BS {
local lab: var label `var'
qui sum `var' if treatment==1
local MeanContr=r(mean)
qui: sum `var' if treatment==2
local MeanTreat=r(mean)
qui: sum `var'
local SD=r(sd)
local Norm=((`MeanTreat'-`MeanContr')/`SD')
reg `var' Treatment, cluster (Geocode)
local tstatistics=_b[Treatment]/_se[Treatment]
putexcel A`row'="`lab'"
putexcel B`row'=`MeanContr', nformat(number_d2)
putexcel C`row'=`MeanTreat', nformat(number_d2)
putexcel D`row'=`Norm', nformat(number_d2)
putexcel E`row'=`tstatistics', nformat(number_d2)
local row=`row'+1
*n: di %-60s "`lab'" %-9.2f `MeanContr' %-9.2f `MeanTreat' %-9.2f `MaenContr' %-9.2f `Norm'
}


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
foreach km in 1 2 5 10 15 {
	label var Inc`km'km "Security Incident w/in `km' km of Village btw. Jan. 2006 and NSP Start"
	}

foreach var of varlist Inc1km Inc2km Inc5km Inc10km Inc15km  {
qui replace `var'=(`var'>0)
local lab: var label `var'
qui sum `var' if treatment==0
local MeanContr=r(mean)
qui: sum `var' if treatment==1
local MeanTreat=r(mean)
qui: sum `var'
local SD=r(sd)
local Norm=((`MeanTreat'-`MeanContr')/`SD')
qui reg `var' treatment, cluster (Geocode)

local tstatistics=_b[treatment]/_se[treatment]
putexcel A`row'="`lab'"
putexcel B`row'=`MeanContr', nformat(number_d2)
putexcel C`row'=`MeanTreat', nformat(number_d2)
putexcel D`row'=`Norm', nformat(number_d2)
putexcel E`row'=`tstatistics', nformat(number_d2)
local row=`row'+1
}




