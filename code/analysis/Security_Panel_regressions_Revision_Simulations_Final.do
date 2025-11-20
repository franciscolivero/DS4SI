set more off
clear all

local per="FU"

use "$path/data/processed/SIGACTS_cleaned_panel_prepared_indices.dta", clear


	merge m:1 Geocode using "$path/data/processed/Interactions_Ethnic_Security.dta", nogen
	bysort Geocode1: egen Pashtun_Share_District=mean( Share_Pashtun_Tribe_MHH)
	qui sum Pashtun_Share_District
	replace Pashtun_Share_District=Pashtun_Share_District-r(mean)
	
	gen Incidents_District_Near_ln=ln(1+Incs_District_Near)
	qui sum Incidents_District_Near_ln
	replace Incidents_District_Near_ln=Incidents_District_Near_ln-r(mean)
	
	
	merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta", keepusing (Geocode1 treatment  POINT_X POINT_Y atlarge referendum C5 C2) nogen
	merge m:1 Geocode using "$path/data/raw/Villages_Distance_Pakistan.dta", nogen keepusing(near_dist)
	merge m:1 Geocode1 using "$path/data/raw/OpiumProductionDistricts.dta", nogen
	replace Y2006=0 if Y2006==.	
	gen Opium2006_2007=(Y2006+Y2007)/2
	gen Opium2006_2007_ln=ln(1+Opium2006_2007)
	qui sum Opium2006_2007_ln
	replace Opium2006_2007_ln=Opium2006_2007_ln-r(mean)	
	
	replace near_dist=near_dist/1000000
	
	xi i.`per'
	
	foreach var of varlist _I* {
		gen treatment_`var'=treatment*`var'
		gen treatmentEast`var'=treatment*East*`var'
		gen treatmentPashtun`var'=`var'*treatment*Pashtun_Share_District
		gen treatmentIncid`var'=`var'*treatment*Incidents_District_Near_ln
		gen treatmentOpium`var'=`var'*treatment*Opium2006_2007_ln
		gen treatmentPK_dist`var'=`var'*treatment*near_dist
		
	}

merge m:1 Geocode using "$path/data/raw/Simulation_assignment.dta"
set obs 10000


*Generate variable that will preserve the results

local  question="Inc_dum_Anderson" 

 

	foreach var of varlist treatment_* {
			*Note slight abuse of notationin variable names. NonEast here refers to the coefficient for treatment, not for NonEasttreatment
			gen double coef_NonEast`var'=.
			label var coef_NonEast`var' "Coefficient for treatment"
			gen double t_NonEast`var'=.
			label var t_NonEast`var' "t-stat for treatment"	
		
		
			gen double coef_BS_NonEast`var'=.
			label var coef_BS_NonEast`var' "Coefficient for treatment controlling for BS"
			gen double t_BS_NonEast`var'=.
			label var t_BS_NonEast`var' "t-stat for treatment controlling for BS"	
			
			
			gen double coef_F_NonEast`var'=.
			label var coef_F_NonEast`var' "Coefficient for treatment full heterogeneity"
			gen double t_F_NonEast`var'=.
			label var t_F_NonEast`var' "t-stat for treatment full heterogeneity"	

			gen double coef_BSF_NonEast`var'=.
			label var coef_BSF_NonEast`var' "Coefficient for treatment full heterogeneity controlling for BS"
			gen double t_BSF_NonEast`var'=.
			label var t_BSF_NonEast`var' "t-stat for treatment full heterogeneity controlling for BS"	


			
			gen double coef_East`var'=.
			label var coef_East`var' "Coefficient for treatment for East"
			gen double t_East`var'=.
			label var t_East`var' "t-stat for treatment for East"	
		
		
			gen double coef_BS_East`var'=.
			label var coef_BS_East`var' "Coefficient for treatment for East controlling for BS"
			gen double t_BS_East`var'=.
			label var t_BS_East`var' "t-stat for treatment for East controlling for BS"	
			
			
			gen double coef_F_East`var'=.
			label var coef_F_East`var' "Coefficient for treatment for East full heterogeneity"
			gen double t_F_East`var'=.
			label var t_F_East`var' "t-stat for treatment for East full heterogeneity"	

			gen double coef_BSF_East`var'=.
			label var coef_BSF_East`var' "Coefficient for treatment for East full heterogeneity controlling for BS"
			gen double t_BSF_East`var'=.
			label var t_BSF_East`var' "t-stat for treatment for East full heterogeneity controlling for BS"		
			
			
			gen double coef_7_`var'=.
			label var coef_7_`var' "Coefficient for treatment controlling for distance to Pakistan"
			gen double t_7_`var'=.
			label var t_7_`var' "t-stat for treatment controlling for distance to Pakistan"
			
			
			gen double coef_7_dist_`var'=.
			label var coef_7_dist_`var' "Coefficient for treatment inteacted with distance to Pakistan"
			gen double t_7_dist_`var'=.
			label var t_7_dist_`var' "t-stat for treatment inteacted with  distance to Pakistan"
			
			gen double coef_BS_7_`var'=.
			label var coef_BS_7_`var' "Coefficient for treatment controlling for distance to Pakistan"
			gen double t_BS_7_`var'=.
			label var t_BS_7_`var' "t-stat for treatment controlling for distance to Pakistan"
			
			
			gen double coef_BS_7_dist_`var'=.
			label var coef_BS_7_dist_`var' "Coefficient for treatment inteacted with distance to Pakistan"
			gen double t_BS_7_dist_`var'=.
			label var t_BS_7_dist_`var' "t-stat for treatment inteacted with  distance to Pakistan"

		
			
		}	
	
	foreach var of varlist treatment*_* {
			gen double coef_`var'=.
			label var coef_`var' "Coefficient for `var'"
			gen double t_`var'=.
			label var t_`var' "t-stat for `var'"		
			
			
			gen double coef_BS_`var'=.
			label var coef_BS_`var' "Coefficient for `var'  controlling for BS"
			gen double t_BS_`var'=.
			label var t_BS_`var' "t-stat  for `var'  controlling for BS"	
			
			gen double coef_F_`var'=.
			label var coef_F_`var' "Coefficient for `var' full heterogeneity"
			gen double t_F_`var'=.
			label var t_F_`var' "t-stat  for `var' full heterogeneity"	
			
			gen double coef_BSF_`var'=.
			label var coef_BSF_`var' "Coefficient for `var' full heterogeneity controlling for BS"
			gen double t_BSF_`var'=.
			label var t_BSF_`var' "t-stat  for `var' full heterogeneity controlling for BS"	

			
			
		}
		
	gen double coef_`question'_BS=.
	label var coef_`question'_BS "Coefficient for  BS control without heterogeneity"
	gen double t_`question'_BS=.
	label var t_`question'_BS "t-stat for BS control without heterogeneity"

	gen double coef_`question'_BS_Heter=.
	label var coef_`question'_BS_Heter "Coefficient for BS control with heterogeneity"
	gen double t_`question'_BS_Heter=.
	label var t_`question'_BS_Heter "t-stat for BS control with heterogeneity"


	gen double coef_`question'_BS_HeterF=.
	label var coef_`question'_BS_HeterF "Coefficient for BS control with multiple heterogeneity"
	gen double t_`question'_BS_HeterF=.
	label var t_`question'_BS_HeterF "t-stat for BS control with multiple heterogeneity"

	
	
foreach var of varlist _I* {
	rename treatment_`var' original_treatment_`var'
	rename treatmentEast`var' original_treatmentEast`var'
	rename treatmentPashtun`var' original_treatmentPashtun`var'
	rename treatmentIncid`var'  original_treatmentIncid`var'
	rename treatmentOpium`var'  original_treatmentOpium`var'
 	rename treatmentPK_dist`var' original_treatmentPK_dist`var'
}




foreach dep in Inc_dum_Anderson {	
	gen `dep'_BSS=`dep' if `per'==0
	bysort Geocode: egen `dep'_BS=mean(`dep'_BSS)	
	drop *_BSS
*   gen `dep'_BS_East=`dep'_BS*East
}	





	
*********************************************************************
***Run 10,000 simulations and record the results

forvalues x=1/10000{
	
	*Generate variable for simulated treatment 
	replace treatment`x'=treatment`x'-1

	foreach var of varlist _I* {
		gen treatment_`var'=`var'*treatment`x'
		gen treatmentNonEast`var'=`var'*treatment`x'*(1-East)
		gen treatmentEast`var'=`var'*treatment`x'*East
		gen treatmentPashtun`var'=`var'*treatment`x'*Pashtun_Share_District
		gen treatmentIncid`var'=`var'*treatment`x'*Incidents_District_Near_ln
		gen treatmentOpium`var'=`var'*treatment`x'*Opium2006_2007_ln
		gen treatmentPK_dist`var'=`var'*treatment*near_dist
	}
	


	*Run regression with no interaction  and no BS controls
	areg `question'  treatment_* if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_treatment_`var'=_b[treatment_`var'] in `x'
		replace t_treatment_`var'=_b[treatment_`var']/_se[treatment_`var'] in `x'
		}
		
		
	*Run regression with no interaction  and  BS controls	
	
	areg `question'  treatment_* `question'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_BS_treatment_`var'=_b[treatment_`var'] in `x'
		replace t_BS_treatment_`var'=_b[treatment_`var']/_se[treatment_`var'] in `x'
		replace coef_`question'_BS=_b[`question'_BS] in `x'
		replace t_`question'_BS=_b[`question'_BS]/_se[`question'_BS] in `x'
		}	
	
	
	*Run regression with  interaction  and no BS controls	
	areg `question'  treatment_* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_NonEasttreatment_`var'=_b[treatment_`var'] in `x'
		replace t_NonEasttreatment_`var'=_b[treatment_`var']/_se[treatment_`var'] in `x'
		replace coef_treatmentEast`var'=_b[treatmentEast`var'] in `x'
		replace t_treatmentEast`var'=_b[treatmentEast`var']/_se[treatmentEast`var'] in `x'
	}
	*Effect for Eastern provinces
	areg `question'  treatmentNonEast* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_Easttreatment_`var'=_b[treatmentEast`var'] in `x'
		replace t_Easttreatment_`var'=_b[treatmentEast`var']/_se[treatmentEast`var'] in `x'
	}
	
	
			
			
	*Run regression with  interaction  and  BS controls	
	areg `question'  treatment_* treatmentEast*  `question'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_BS_NonEasttreatment_`var'=_b[treatment_`var'] in `x'
		replace t_BS_NonEasttreatment_`var'=_b[treatment_`var']/_se[treatment_`var'] in `x'
		replace coef_BS_treatmentEast`var'=_b[treatmentEast`var'] in `x'
		replace t_BS_treatmentEast`var'=_b[treatmentEast`var']/_se[treatmentEast`var'] in `x'
		replace coef_`question'_BS_Heter=_b[`question'_BS] in `x'
		replace t_`question'_BS_Heter=_b[`question'_BS]/_se[`question'_BS] in `x'
	}
	*Effect for Eastern provinces
	areg `question'  treatmentNonEast_* treatmentEast*  `question'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_BS_Easttreatment_`var'=_b[treatmentEast`var'] in `x'
		replace t_BS_Easttreatment_`var'=_b[treatmentEast`var']/_se[treatmentEast`var'] in `x'
	}					

	*Run regression with full set of interaction  and no BS controls	
	areg `question'  treatment_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncid*  if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_F_NonEasttreatment_`var'=_b[treatment_`var'] in `x'
		replace t_F_NonEasttreatment_`var'=_b[treatment_`var']/_se[treatment_`var'] in `x'

		replace coef_F_treatmentEast`var'=_b[treatmentEast`var'] in `x'
		replace t_F_treatmentEast`var'=_b[treatmentEast`var']/_se[treatmentEast`var'] in `x'
		
		replace coef_F_treatmentPashtun`var'=_b[treatmentPashtun`var'] in `x'
		replace t_F_treatmentPashtun`var'=_b[treatmentPashtun`var']/_se[treatmentPashtun`var'] in `x'
		
		replace coef_F_treatmentOpium`var'=_b[treatmentOpium`var'] in `x'
		replace t_F_treatmentOpium`var'=_b[treatmentOpium`var']/_se[treatmentOpium`var'] in `x'
		
		replace coef_F_treatmentIncid`var'=_b[treatmentIncid`var'] in `x'
		replace t_F_treatmentIncid`var'=_b[treatmentIncid`var']/_se[treatmentIncid`var'] in `x'		
	}
	*Effect for Eastern provinces		
	areg `question'  treatmentNonEast_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncid*  if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_F_Easttreatment_`var'=_b[treatmentEast`var'] in `x'
		replace t_F_Easttreatment_`var'=_b[treatmentEast`var']/_se[treatmentEast`var'] in `x'
	}
					
	*Run regression with full set of interaction and  BS controls	
	areg `question'  treatment_* treatmentEast*   treatmentPashtun* treatmentOpium*  treatmentIncid*  `question'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_BSF_NonEasttreatment_`var'=_b[treatment_`var'] in `x'
		replace t_BSF_NonEasttreatment_`var'=_b[treatment_`var']/_se[treatment_`var'] in `x'

		replace coef_BSF_treatmentEast`var'=_b[treatmentEast`var'] in `x'
		replace t_BSF_treatmentEast`var'=_b[treatmentEast`var']/_se[treatmentEast`var'] in `x'
		
		replace coef_BSF_treatmentPashtun`var'=_b[treatmentPashtun`var'] in `x'
		replace t_BSF_treatmentPashtun`var'=_b[treatmentPashtun`var']/_se[treatmentPashtun`var'] in `x'
		
		replace coef_BSF_treatmentOpium`var'=_b[treatmentOpium`var'] in `x'
		replace t_BSF_treatmentOpium`var'=_b[treatmentOpium`var']/_se[treatmentOpium`var'] in `x'
		
		replace coef_BSF_treatmentIncid`var'=_b[treatmentIncid`var'] in `x'
		replace t_BSF_treatmentIncid`var'=_b[treatmentIncid`var']/_se[treatmentIncid`var'] in `x'
		
		replace coef_`question'_BS_HeterF=_b[`question'_BS] in `x'
		replace t_`question'_BS_HeterF=_b[`question'_BS]/_se[`question'_BS] in `x'
	}
	*Run regression with full set of interaction and  BS controls									
	areg `question'  treatment_* treatmentEast*   treatmentPashtun* treatmentOpium*  treatmentIncid*  `question'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
	foreach var of varlist _I* {
		replace coef_BSF_Easttreatment_`var'=_b[treatmentEast`var'] in `x'
		replace t_BSF_Easttreatment_`var'=_b[treatmentEast`var']/_se[treatmentEast`var'] in `x'
	}		
	
	
	
	*Run regressions for distance to Pakistan (table 7)
		
		areg `question'  treatment_* treatmentPK_dist* near_dist if `per'!=0 & East==1, a(Pair_`per') cluster(Cluster)
		foreach var of varlist _I* {
		replace coef_7_treatment_`var'=_b[treatment_`var'] in `x'
		replace t_7_treatment_`var'=_b[treatment_`var']/_se[treatment_`var'] in `x'

		replace coef_7_dist_treatment_`var'=_b[treatmentPK_dist`var'] in `x'
		replace t_7_dist_treatment_`var'=_b[treatmentPK_dist`var']/_se[treatmentPK_dist`var'] in `x'
		}
		
		areg `question'  treatment_* treatmentPK_dist* near_dist `question'_BS if `per'!=0 & East==1, a(Pair_`per') cluster(Cluster)
		foreach var of varlist _I* {
		replace coef_BS_7_treatment_`var'=_b[treatment_`var'] in `x'
		replace t_BS_7_treatment_`var'=_b[treatment_`var']/_se[treatment_`var'] in `x'

		replace coef_BS_7_dist_treatment_`var'=_b[treatmentPK_dist`var'] in `x'
		replace t_BS_7_dist_treatment_`var'=_b[treatmentPK_dist`var']/_se[treatmentPK_dist`var'] in `x'
		}
		
	

	drop treatment*_* 

	noisily di "`x'"
}


foreach var of varlist _I* {
	rename  original_treatment_`var' treatment_`var'
	rename  original_treatmentEast`var' treatmentEast`var'
	rename 	original_treatmentPashtun`var' treatmentPashtun`var' 
	rename 	original_treatmentIncid`var' treatmentIncid`var'  
	rename 	original_treatmentOpium`var' treatmentOpium`var'  
 	rename  original_treatmentPK_dist`var' treatmentPK_dist`var' 	
	
	gen treatmentNonEast`var'=treatment_`var'*(1-East)
}


local per="FU"		
save "$path/results/Simulation_results_100000_security_dummy_`per'_Anderson.dta", replace

