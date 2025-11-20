set more off
clear all
set mem 500m
set matsize 11000
tempfile VilInd MHHAnderson FHHAnderson  FHHMHHAnderson Village_BS Anderson_Ind_BS VilInd_BS sigacts sigactsBS sigactsKM opium



*Data on opium production
use "$path/data/raw/MHH_BS.dta", clear
gen byte Opium_Production_BS=(Q_6_01_First==5 | Q_6_01_First==10 | Q_6_05_Second==5 | Q_6_05_Second==10 | Q_6_09_Third==5 | Q_6_09_Third==10)
collapse Opium_Production_BS, by(Geocode)
replace Geocode=Geocode/100000
save `opium'

use "$path/data/processed/SIGACTS_cleaned_panel_prepared.dta", clear
keep if FU==0
keep  Geocode Inc*km 
collapse (sum) Inc*km, by(Geocode)
forvalues x=1/15 {
 rename Inc`x'km Num_Incident`x'km_Bef
}
save `sigactsBS'

/*
use "$path/data/processed/SIGACTS_cleaned_panel_prepared.dta", clear
drop if FU==3 | FU==0
gen byte FU1=(FU==1)
gen byte FU2=(FU==2)
rename FU Survey

*drop _merge*
save `sigacts'
*/
use "$path/data/processed/SIGACTS_cleaned_panel_prepared.dta", clear
local period="FU"
	foreach var of varlist Inc*km* {
	gen `var'_dum=`var'
	rename `var' `var'_num
	}
	collapse (sum) *_num (max) *_dum, by (Geocode `period')
	replace `period'=0 if `period'==.
	tsset Geocode `period'
	tsfill, full
	foreach var of varlist  *_num  *_dum {
		replace `var'=0 if `var'==.
	}	

	

	drop if FU==3 | FU==0

	forvalues y=1/15 {
		gen Inc`y'km_num_wins=Inc`y'km_num
		forvalues x=1/2 {
				qui sum Inc`y'km`suf'_num if FU==`x', d
				replace Inc`y'km`suf'_num_wins=r(p99) if Inc`y'km_num>r(p99) &  FU==`x'
			}	

		gen Inc`y'km_num_wins_ln=ln(1+Inc`y'km_num_wins)
		drop Inc`y'km_num_wins

		}	
	

	keep Geocode FU *_num_wins_ln* Inc*km_dum



gen byte FU1=(FU==1)
gen byte FU2=(FU==2)
rename FU Survey


keep Geocode Survey  *num_wins_ln* *_dum*
save `sigactsKM'


use "$path/data/raw/Combined_FU1_FU2_H_M.dta", replace
*drop if HH_Code==.
merge m:1 HH_Code Survey using "$path/data/raw/Combined_FU1_FU2_Report_Economic.dta", nogen
drop treatment Cluster Pair

*merge m:1 Geocode Survey using `sigacts', gen(_merge_insidents) update

merge m:1 Geocode Survey using `sigactsKM', gen(_merge_insidentsKM) update


merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta", nogenerate update
replace treatment=treatment-1

*** Normalizing and combining into an index
global individual_outcomes "M7_93z_wins_ln  M7_92z  M7_91z M8_91z_wins_ln  M8_92z Assets_Household_pca Assets_Livestock_pca M9_03_wins_ln  M9_99z  F8_03y_wins_ln    F8_01z 	F2_01x F2_034x_wins_ln  F2_05x  F2_05y  M1_05_6z_wins_ln  G6_03z M6_08_s11z 	M9_05z M9_06z		F13_01x F13_02z  	G2_04_5z_wins_ln  M11_01z M11_02z M11_03z M11_04z M11_05z M11_10z M11_11z M11_09z M11_13z	 M12_19X M12_19z	 	F13_06_better F13_06_worse F13_07_better F13_07_worse 	 M12_17a M12_17B  M12_20z M12_20y" 



foreach x of global individual_outcomes{


	qui sum `x' if treatment==0 & Survey==1
	gen this_mean_control=r(mean) if Survey==1
	
	qui sum `x' if treatment==0 & Survey==2
	replace this_mean_control=r(mean) if Survey==2
	
	qui sum `x' if treatment==0 & Survey==1
	gen this_sd_control=r(sd)  if Survey==1
	
	qui sum `x' if treatment==0 & Survey==2
	replace this_sd_control=r(sd)  if Survey==2
			
	gen Katz_`x'=(`x'-this_mean_control)/this_sd_control
	drop  this_mean_control this_sd_control
	
}

****************************************************************************************************************************************
*Continue with individual level data

*Reverting the sign so that bigger is better

gen  Katz_M12_19X_neg =-1*Katz_M12_19X
gen Katz_M12_17a_neg =-1*Katz_M12_17a
gen Katz_M12_17B_neg =-1*Katz_M12_17B
gen  Katz_M12_20z_neg =-1*Katz_M12_20z
gen  Katz_M12_20y_neg =-1*Katz_M12_20y
gen  Katz_F13_06_worse_neg =-1*Katz_F13_06_worse
gen  Katz_F13_07_worse_neg =-1*Katz_F13_07_worse
gen Katz_F8_03y_wins_ln_neg=-1*Katz_F8_03y_wins_ln
*gen Katz_F8_02_neg=-1*Katz_F8_02
gen Katz_F8_01z_neg=-1*Katz_F8_01z
    

gen  Katz_F2_034x_wins_ln_neg=-1*Katz_F2_034x_wins_ln
gen  Katz_F2_05x_neg=-1*Katz_F2_05x
gen  Katz_F2_05y_neg=-1*Katz_F2_05y




********************************************************************
*Generate Indices for FU measures
********************************************************************
egen index_Economic_Katz_M=rowmean(Katz_M7_93z_wins_ln  Katz_M7_92z  Katz_M7_91z Katz_M8_91z_wins_ln  Katz_M8_92z Katz_Assets_Household_pca Katz_Assets_Livestock_pca Katz_M9_03_wins_ln  Katz_M9_99z Katz_F8_03y_wins_ln_neg  Katz_F8_01z_neg)
pca Katz_M7_93z_wins_ln  Katz_M7_92z  Katz_M7_91z Katz_M8_91z_wins_ln  Katz_M8_92z Katz_Assets_Household_pca Katz_Assets_Livestock_pca Katz_M9_03_wins_ln  Katz_M9_99z Katz_F8_03y_wins_ln_neg  Katz_F8_01z_neg   if treatment==0
predict index_Economic_pca_M 

egen index_Attitudes_Katz_M=rowmean(Katz_M11_01z Katz_M11_02z Katz_M11_03z Katz_M11_04z Katz_M11_05z Katz_M11_10z Katz_M11_11z Katz_M11_09z Katz_M11_13z)
pca Katz_M11_01z Katz_M11_02z Katz_M11_03z Katz_M11_04z Katz_M11_05z Katz_M11_10z Katz_M11_11z Katz_M11_09z Katz_M11_13z   if treatment==0
predict index_Attitudes_pca_M 

egen index_Security_perc_Katz_M=rowmean(Katz_M12_19z Katz_M12_19X_neg)
pca Katz_M12_19z Katz_M12_19X_neg  if treatment==0
predict index_Security_perc_pca_M 

egen index_Security_perc_Katz_F=rowmean(Katz_F13_06_better  Katz_F13_06_worse_neg Katz_F13_07_better Katz_F13_07_worse_neg)
pca Katz_F13_06_better  Katz_F13_06_worse_neg Katz_F13_07_better Katz_F13_07_worse_neg  if treatment==0
predict index_Security_perc_pca_F 


egen index_Security_exp_Katz_M=rowmean(Katz_M12_17a_neg Katz_M12_17B_neg Katz_M12_20z_neg Katz_M12_20y_neg)
pca Katz_M12_17a_neg Katz_M12_17B_neg Katz_M12_20z_neg Katz_M12_20y_neg  if treatment==0
predict index_Security_exp_pca_M

egen index_Economic_Katz_Subj=rowmean(Katz_M9_05z Katz_M9_06z Katz_F13_01x Katz_F13_02z)
pca  Katz_M9_05z Katz_M9_06z Katz_F13_01x Katz_F13_02z if treatment==0
predict index_Economic_pca_Subj

egen index_PublicGoods_Katz=rowmean(Katz_F2_01x Katz_F2_034x_wins_ln_neg Katz_F2_05x_neg Katz_F2_05y_neg  Katz_M1_05_6z_wins_ln)
pca  Katz_F2_01x Katz_F2_034x_wins_ln_neg Katz_F2_05x_neg Katz_F2_05y_neg  Katz_M1_05_6z_wins_ln if treatment==0
predict index_PublicGoods_pca


**Generating indices based on Anderson for  MHH
preserve 
egen NMis=rownonmiss(Katz_M7_93z_wins_ln  Katz_M7_92z  Katz_M7_91z Katz_M8_91z_wins_ln  Katz_M8_92z Katz_Assets_Household_pca Katz_Assets_Livestock_pca Katz_M9_03_wins_ln  Katz_M9_99z Katz_F8_03y_wins_ln_neg  Katz_F8_01z_neg	 M11_01z M11_02z M11_03z M11_04z M11_05z M11_10z M11_11z M11_09z M11_13z	 M12_19X  M12_19z	 M12_17a M12_17B  M12_20z M12_20y)
drop if NMis==0

matrix	I= vecdiag(I(11))'
qui correlate Katz_M7_93z_wins_ln  Katz_M7_92z  Katz_M7_91z Katz_M8_91z_wins_ln  Katz_M8_92z Katz_Assets_Household_pca Katz_Assets_Livestock_pca Katz_M9_03_wins_ln  Katz_M9_99z Katz_F8_03y_wins_ln_neg  Katz_F8_01z_neg, covariance
matrix C=inv(r(C))
mkmat Katz_M7_93z_wins_ln  Katz_M7_92z  Katz_M7_91z Katz_M8_91z_wins_ln  Katz_M8_92z Katz_Assets_Household_pca Katz_Assets_Livestock_pca Katz_M9_03_wins_ln  Katz_M9_99z Katz_F8_03y_wins_ln_neg  Katz_F8_01z_neg, matrix(X)
matrix B=inv(I'*C*I)*(I'*C*X')
matrix C=B'
svmat C
rename C1 index_Economic_Andr_M



matrix	I= vecdiag(I(9))'
qui correlate Katz_M11_01z Katz_M11_02z Katz_M11_03z Katz_M11_04z Katz_M11_05z Katz_M11_10z Katz_M11_11z Katz_M11_09z Katz_M11_13z, covariance
matrix C=inv(r(C))
mkmat Katz_M11_01z Katz_M11_02z Katz_M11_03z Katz_M11_04z Katz_M11_05z Katz_M11_10z Katz_M11_11z Katz_M11_09z Katz_M11_13z, matrix(X)
matrix B=inv(I'*C*I)*(I'*C*X')
matrix C=B'
svmat C
rename C1 index_Attitudes_Andr_M

matrix	I= vecdiag(I(2))'
qui correlate Katz_M12_19z Katz_M12_19X_neg, covariance
matrix C=inv(r(C))
mkmat Katz_M12_19z Katz_M12_19X_neg, matrix(X)
matrix B=inv(I'*C*I)*(I'*C*X')
matrix C=B'
svmat C
rename C1 index_Security_perc_Andr_M


matrix	I= vecdiag(I(4))'
qui correlate Katz_M12_17a_neg Katz_M12_17B_neg Katz_M12_20z_neg Katz_M12_20y_neg, covariance
matrix C=inv(r(C))
mkmat Katz_M12_17a_neg Katz_M12_17B_neg Katz_M12_20z_neg Katz_M12_20y_neg, matrix(X)
matrix B=inv(I'*C*I)*(I'*C*X')
matrix C=B'
svmat C
rename C1 index_Security_exp_Andr_M 
keep HH_Code Instrument Survey *Andr_M
save `MHHAnderson'
restore

**Generating indices based on Anderson for FHH
preserve

egen NMis=rownonmiss(Katz_F13_06_better  Katz_F13_06_worse_neg Katz_F13_07_better Katz_F13_07_worse_neg)
drop if NMis==0

matrix	I= vecdiag(I(4))'
qui correlate Katz_F13_06_better  Katz_F13_06_worse_neg Katz_F13_07_better Katz_F13_07_worse_neg, covariance
matrix C=inv(r(C))
mkmat Katz_F13_06_better  Katz_F13_06_worse_neg Katz_F13_07_better Katz_F13_07_worse_neg, matrix(X)
matrix B=inv(I'*C*I)*(I'*C*X')
matrix C=B'
svmat C
rename C1 index_Security_perc_Andr_F
keep HH_Code Instrument  Survey *Andr_F
save `FHHAnderson'
restore

**Generating indices based on Anderson for FHH and MHH
preserve

egen NMis=rownonmiss( Katz_M9_05z Katz_M9_06z Katz_F13_01x Katz_F13_02z 	 Katz_F2_01x Katz_F2_034x_wins_ln_neg Katz_F2_05x_neg Katz_F2_05y_neg  Katz_M1_05_6z_wins_ln)
drop if NMis==0

matrix	I= vecdiag(I(4))'
qui correlate  Katz_M9_05z Katz_M9_06z Katz_F13_01x Katz_F13_02z , covariance
matrix C=inv(r(C))
mkmat  Katz_M9_05z Katz_M9_06z Katz_F13_01x Katz_F13_02z , matrix(X)
matrix B=inv(I'*C*I)*(I'*C*X')
matrix C=B'
svmat C
rename C1 index_Economic_Andr_Subj 

matrix	I= vecdiag(I(5))'
qui correlate  Katz_F2_01x Katz_F2_034x_wins_ln_neg Katz_F2_05x_neg Katz_F2_05y_neg  Katz_M1_05_6z_wins_ln , covariance
matrix C=inv(r(C))
mkmat  Katz_F2_01x Katz_F2_034x_wins_ln_neg Katz_F2_05x_neg Katz_F2_05y_neg  Katz_M1_05_6z_wins_ln  , matrix(X)
matrix B=inv(I'*C*I)*(I'*C*X')
matrix C=B'
svmat C
rename C1 index_PublicGoods_Andr 

keep HH_Code Instrument  Survey index_Economic_Andr_Subj index_PublicGoods_Andr
save `FHHMHHAnderson'
restore



*Add Anderson measures for MHH & FHH
merge m:1 HH_Code Instrument Survey using `MHHAnderson', nogen
merge m:1 HH_Code Instrument Survey using `FHHAnderson', nogen
merge m:1 HH_Code Instrument Survey using `FHHMHHAnderson', nogen


bysort Geocode Survey: gen N=_n


replace Respondent_is_Same=1 if  G2_04_5z_wins_ln!=.


merge m:1 Geocode using "$path/data/processed/Interactions_Ethnic_Security.dta", nogen
merge m:1 Geocode1 using "$path/data/raw/OpiumProductionDistricts.dta", nogen
forvalues x=2001/2014{
 rename Y`x' Opium`x'
}
bysort Geocode1: egen Pashtun_Share_District=mean( Share_Pashtun_Tribe_MHH)


gen byte NonEastTreat=1-East
drop EastTreat_FU1 EastTreat_FU2 treatment_FU1 treatment_FU2
gen byte treatment_FU1=treatment*FU1
gen byte treatment_FU2=treatment*FU2
gen EastTreat_FU1=East*treatment_FU1
gen EastTreat_FU2=East*treatment_FU2
gen byte NonEastTreat_FU1=NonEastTreat*treatment_FU1
gen byte NonEastTreat_FU2=NonEastTreat*treatment_FU2


gen byte Security_high=(Incs_District_Near>40)
gen byte Security_low=(Incs_District_Near<=40)

gen byte Security_high_nonEast=(Incs_District_Near>40 & East==0)

gen byte Opium2007_dum=(Opium2007>100)
gen Opium2007_dum_FU1=Opium2007_dum*treatment_FU1
gen Opium2007_dum_FU2=Opium2007_dum*treatment_FU2

replace Opium2006=0 if Opium2006==.
gen Opium2007_ln=ln(1+Opium2007)
qui sum Opium2007_ln
replace   Opium2007_ln=Opium2007_ln-r(mean)

gen Opium2006_ln=ln(1+Opium2006)
qui sum Opium2006_ln
replace   Opium2006_ln=Opium2006_ln-r(mean)

gen Opium2006_2007=(Opium2006+Opium2007)/2
gen Opium2006_2007_ln=ln(1+Opium2006_2007)
qui sum Opium2006_2007_ln
replace Opium2006_2007_ln=Opium2006_2007_ln-r(mean)
gen Opium2006_2007_ln_FU1=Opium2006_2007_ln*treatment_FU1
gen Opium2006_2007_ln_FU2=Opium2006_2007_ln*treatment_FU2

gen Opium2006_ln_FU1=ln(1+Opium2006)*treatment_FU1
gen Opium2006_ln_FU2=ln(1+Opium2006)*treatment_FU2
gen Opium2007_ln_FU1=Opium2007_ln*treatment_FU1
gen Opium2007_ln_FU2=Opium2007_ln*treatment_FU2

gen Incidents_District_Near_ln=ln(1+Incs_District_Near)
qui sum Incidents_District_Near_ln
replace Incidents_District_Near_ln=Incidents_District_Near_ln-r(mean)

gen Incidents_District_Near_ln_FU1=Incidents_District_Near_ln*treatment_FU1
gen Incidents_District_Near_ln_FU2=Incidents_District_Near_ln*treatment_FU2

qui sum Pashtun_Share_District
gen Pashtun_Share_District_dem=Pashtun_Share_District-r(mean)
gen Pashtun_ShareTreat_FU1=Pashtun_Share_District_dem*treatment_FU1
gen Pashtun_ShareTreat_FU2=Pashtun_Share_District_dem*treatment_FU2

gen byte Security_high_nonEast_Treat_FU1= Security_high_nonEast*treatment_FU1
gen byte Security_high_nonEast_Treat_FU2= Security_high_nonEast*treatment_FU2
gen byte Security_high_Treat_FU1= Security_high*treatment_FU1
gen byte Security_high_Treat_FU2= Security_high*treatment_FU2
gen byte Security_low_Treat_FU1= Security_low*treatment_FU1
gen byte Security_low_Treat_FU2= Security_low*treatment_FU2

gen NonPashtun_NonEast=(Pashtun==0 & East==0)
gen byte NonPashtun_NonEast_FU1=NonPashtun_NonEast*treatment_FU1
gen byte NonPashtun_NonEast_FU2=NonPashtun_NonEast*treatment_FU2


egen Cluster=group(Geocode1 C5)
replace Cluster=Geocode if  C5==0
egen Pair=group(Geocode1 C2)
egen Pair_Survey=group(Pair Survey)

*Leave one observation per village for security measures
egen a=group(Geocode Survey)
bysort a: gen byte b=_n

drop a
drop if treatment==.

label var M7_93z_wins_ln "Income Earned in Past Year"
label var M7_92z "Seasons in Which Income Was Earned"
label var M7_91z "Sources of Income Include Sectors Other than Subsistence Agriculture"
label var M8_91z_wins_ln "Annual Expenditure"
label var M8_92z "Ratio of Food Expenditure to Total Expenditure"
label var Assets_Household_pca "Principal Component of Livestock Assets (Aggregate)"
label var Assets_Livestock_pca "Principal Component of Household Assets (Aggregate)"
label var M9_03_wins_ln "Amount Borrowed in Past Year"
label var M9_99z "Borrowed for Food or Medical Needs in Past Year"
label var F8_03y_wins_ln "Daily Caloric Intake Per Household Member During Past Week"
label var F8_01z "Household Experienced Hunger On At Least One Day in Past Week"
label var F2_01x "Primary Source of Drinking Water is Protected Source"
label var F2_034x_wins_ln "Estimated Hours Spent Collecting Water in Past Week"
label var F2_05x "Number of seasons in Past Year Water Was of Poor Quality"
label var F2_05y "Number of seasons in Past Year Water Was Not Available"
label var M1_05_6z_wins_ln "Logarithm of Hours of Electricity in Past Month"
label var M9_05z "Perceived Improvement in Household's Situation in Past Year (Male)"
label var M9_06z "Expected Improvement in Household's Situation Next Year (Male)"
label var F13_01x "Perceived Improvement in Household's Situation in Past Year (Female)"
label var F13_02z "Expected Improvement in Household's Situation Next Year (Female)"
label var G2_04_5z_wins_ln "Ln(Net Number of Families Migrating to the Village)"
label var M11_01z "District Governor Acts for the Benefit of All Villagers"
label var M11_02z "Provincial Governor Acts for the Benefit of All Villagers"
label var M11_03z "Central Government Officials Act for the Benefit of All Villagers"
label var M11_04z "President of Afghanistan Acts for the Benefit of All Villagers"
label var M11_05z "Members of Parliament Act for the Benefit of All Villagers"
label var M11_10z "Government Judges Act for the Benefit of All Villagers"
label var M11_11z "National Police Act for the Benefit of All Villagers"
label var M11_09z "NGO Employees Act for the Benefit of All Villagers"
label var M11_13z "ISAF Soldiers Act for the Benefit of All Villagers"
label var M12_19z "Security in and around Village Has Improved in Past Two Years"
label var M12_19X "Security in and around Village Has Deteriorated in Past Two Years"
label var F13_06_better "Compared to Two Years Ago Women Feel More Safe in Working for NGOs or the Government or Attending Training Courses"
label var F13_06_worse "Compared to Two Years Ago Women Feel Less Safe in Working for NGOs or the Government or Attending Training Courses"
label var F13_07_better "Compared to Two Years Ago Teenage Girls Feel More Safe when Traveling to and from School or  Socializing"
label var F13_07_worse "Compared to Two Years Ago Teenage Girls Feel Less Safe when Traveling to and from School or  Socializing"
label var M12_17a "Village has Experienced Attack in the Past Year"
label var M12_17B "Village has Experienced Attack by Anti-Government Elements in the Past Year"
label var M12_20z "Respondent Household has been Affected by Insecurity in Village during the Past Year"
label var M12_20y "Respondent Household has been Affected by Insecurity on Roads around District during the Past Year"



save  "$path/data/processed/Combined_data_H_M_Full_SIGACTS_new.dta", replace 
