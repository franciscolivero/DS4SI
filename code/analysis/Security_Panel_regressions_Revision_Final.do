*Run after Prepare_panel_SIGACTS and Security_Panel_regressions_Revision_Simulations_Final

clear all
tempfile first district



cd "$path/results/"


program  panel_security
	args  period suff
	
	
	local period="FU"
	foreach var of varlist Inc*km* {
	gen `var'_dum=`var'
	rename `var' `var'_num
	}
	collapse (sum) *_num (max) *_dum, by (Geocode `period')
	replace `period'=0 if `period'==.
	tsset Geocode `period'
	tsfill, full
	merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta", keepusing (Geocode1 treatment  POINT_X POINT_Y atlarge referendum C5 C2) nogen
	egen Cluster=group(Geocode1 C5)
	replace Cluster=Geocode if C5==0
	egen Pair=group(Geocode1 C2)
	drop C5 C2
	replace treatment=treatment-1
	foreach var of varlist  *_num  *_dum {
		replace `var'=0 if `var'==.
	}	

	qui sum `period'
	local MaxPeriod=r(max)
	reshape wide *_num  *_dum, i(Geocode) j(`period')



	forvalues x=`MaxPeriod'(-1)0 {
		foreach suf in "" "_Clear" "_Expld"  {
			forvalues y=1/15 {
					qui sum Inc`y'km`suf'_num`x', d
					gen Inc`y'km`suf'_num_wins`x'=Inc`y'km`suf'_num`x'
					replace Inc`y'km`suf'_num_wins`x'=r(p95) if Inc`y'km`suf'_num`x'>r(p95)
					gen Inc`y'km`suf'_num_wins_ln`x'=ln(1+Inc`y'km`suf'_num_wins`x')
					*drop Inc`y'km`suf'_num_wins`x'

			}	
		order Inc*km`suf'_num_wins_ln`x', alpha after(Pair)
		order Inc*`suf'_dum`x', alpha after(Pair)
		}

	}
	
	
*Creating aggregate index based on PCA	
	forvalues x=`MaxPeriod'(-1)0 {
		foreach suf in "" "_Clear" "_Expld" {
			pca Inc*km`suf'_num_wins_ln`x' if treatment==0
			predict Inc`suf'_wins_ln_pca`x'
			pca Inc*km`suf'_dum`x' if treatment==0
			predict Inc`suf'_dum_pca`x'
		}
	}
	
*Creating aggregate index following Katz et al	

	forvalues x=`MaxPeriod'(-1)0 {
		foreach suf in "" "_Clear" "_Expld"  {
			forvalues i=2/15 {
				qui sum Inc`i'km`suf'_num_wins_ln`x'  if treatment==0
				gen Inc`i'km`suf'_num_wins_ln`x'_nrm=(Inc`i'km`suf'_num_wins_ln`x'-r(mean))/r(sd)
				replace Inc`i'km`suf'_num_wins_ln`x'_nrm=0 if Inc`i'km`suf'_num_wins_ln`x'_nrm==.

				qui sum Inc`i'km`suf'_dum`x'  if treatment==0
				gen Inc`i'km`suf'_dum`x'_nrm=(Inc`i'km`suf'_dum`x'-r(mean))/r(sd)
				replace Inc`i'km`suf'_dum`x'_nrm=0 if Inc`i'km`suf'_dum`x'_nrm==.
			}	
			egen Inc`suf'_wins_ln_Katz`x'=rowmean(Inc*km`suf'_num_wins_ln`x'_nrm)
			egen Inc`suf'_dum_Katz`x'=rowmean(Inc*km`suf'_dum`x'_nrm)
			
		}
	}

	
*Creating aggregate index following Anderson	
	forvalues x=`MaxPeriod'(-1)0{	
		foreach suf in "" {
			capture  { 
				matrix	I= vecdiag(I(14))'
				qui correlate Inc*km`suf'_num_wins_ln`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_num_wins_ln`x'_nrm, matrix(X)
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_wins_ln_Anderson`x'

				qui correlate Inc*km`suf'_dum`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_dum`x'_nrm, matrix(X)				
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_dum_Anderson`x'	
			}
		}
	}
	
*Treat separately cases where there is no variation for smaller radii	

local x=3	
		foreach suf in  "_Expld" {
			capture  { 
				matrix	I= vecdiag(I(14))'
				 correlate Inc*km`suf'_num_wins_ln`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_num_wins_ln`x'_nrm, matrix(X)
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_wins_ln_Anderson`x'

				qui correlate Inc*km`suf'_dum`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_dum`x'_nrm, matrix(X)				
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_dum_Anderson`x'	
			}
		}
	

local x=3	
		foreach suf in  "_Clear" {
			capture  { 
				drop Inc2km`suf'_num_wins_ln`x'_nrm
				matrix	I= vecdiag(I(13))'
				 correlate Inc*km`suf'_num_wins_ln`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_num_wins_ln`x'_nrm, matrix(X)
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_wins_ln_Anderson`x'

				matrix	I= vecdiag(I(14))'
				qui correlate Inc*km`suf'_dum`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_dum`x'_nrm, matrix(X)				
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_dum_Anderson`x'	
			}
		}
	


local x=2	
		foreach suf in "_Clear" "_Expld" {
			capture  { 
				matrix	I= vecdiag(I(14))'
				 correlate Inc*km`suf'_num_wins_ln`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_num_wins_ln`x'_nrm, matrix(X)
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_wins_ln_Anderson`x'

				qui correlate Inc*km`suf'_dum`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_dum`x'_nrm, matrix(X)				
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_dum_Anderson`x'	
			}
		}
	
	

		
local x=1
		foreach suf in "_Clear" "_Expld" {
			capture  { 
				drop Inc2km`suf'_num_wins_ln`x'_nrm 
				matrix	I= vecdiag(I(13))'
				qui correlate Inc*km`suf'_num_wins_ln`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_num_wins_ln`x'_nrm, matrix(X)
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_wins_ln_Anderson`x'

				
				matrix	I= vecdiag(I(14))'
				qui correlate Inc*km`suf'_dum`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_dum`x'_nrm, matrix(X)				
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_dum_Anderson`x'	
			}
		}
	

	
local x=0
		foreach suf in "_Clear" {
			capture  { 
				drop Inc2km`suf'_num_wins_ln`x'_nrm  Inc3km`suf'_num_wins_ln`x'_nrm  Inc4km`suf'_num_wins_ln`x'_nrm Inc10km`suf'_dum`x'_nrm 
				matrix	I= vecdiag(I(11))'
				qui correlate Inc*km`suf'_num_wins_ln`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_num_wins_ln`x'_nrm, matrix(X)
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_wins_ln_Anderson`x'

				
				matrix	I= vecdiag(I(13))'
				qui correlate Inc*km`suf'_dum`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_dum`x'_nrm, matrix(X)				
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_dum_Anderson`x'	
			}
		}
	
local x=0	
		foreach suf in "_Expld" {
			capture  { 
				drop  Inc2km`suf'_num_wins_ln`x'_nrm Inc3km`suf'_num_wins_ln`x'_nrm  Inc4km`suf'_num_wins_ln`x'_nrm  Inc5km`suf'_num_wins_ln`x'_nrm Inc11km`suf'_dum`x'_nrm Inc12km`suf'_dum`x'_nrm 
				matrix	I= vecdiag(I(10))'
				qui correlate Inc*km`suf'_num_wins_ln`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_num_wins_ln`x'_nrm, matrix(X)
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_wins_ln_Anderson`x'

				matrix	I= vecdiag(I(12))'
				qui correlate Inc*km`suf'_dum`x'_nrm , covariance
				matrix C=inv(r(C))
				mkmat Inc*km`suf'_dum`x'_nrm, matrix(X)				
				matrix B=inv(I'*C*I)*(I'*C*X')
				matrix C=B'
				svmat C
				rename C1 Inc`suf'_dum_Anderson`x'	
			}
		}
	
	
	
***********************************************************	
		
	
	
local period="FU"
	keep Geocode treatment POINT_X POINT_Y atlarge referendum Pair Cluster *Anderson* *Katz* *pca*
	local var=""
	foreach suf in "" "_Clear" "_Expld"  {
	local var="`var' Inc`suf'_dum_Anderson Inc`suf'_wins_ln_Anderson Inc`suf'_wins_ln_Katz Inc`suf'_dum_Katz Inc`suf'_wins_ln_pca  Inc`suf'_dum_pca"
	}
	reshape long `var', i(Geocode) j(`period')

	merge m:1 Geocode using "$path/data/processed/Interactions_Ethnic_Security.dta", nogen
	bysort Geocode1: egen Pashtun_Share_District=mean( Share_Pashtun_Tribe_MHH)
	qui sum Pashtun_Share_District
	replace Pashtun_Share_District=Pashtun_Share_District-r(mean)
	
	gen Incidents_District_Near_ln=ln(1+Incs_District_Near)
	qui sum Incidents_District_Near_ln
	replace Incidents_District_Near_ln=Incidents_District_Near_ln-r(mean)
	
	merge m:1 Geocode using "$path/data/raw/Villages_Distance_Pakistan.dta", nogen keepusing(near_dist)
	merge m:1 Geocode1 using "$path/data/raw/OpiumProductionDistricts.dta", nogen
	replace Y2006=0 if Y2006==.	
	gen Opium2006_2007=(Y2006+Y2007)/2
	gen Opium2006_2007_ln=ln(1+Opium2006_2007)
	qui sum Opium2006_2007_ln
	replace Opium2006_2007_ln=Opium2006_2007_ln-r(mean)	
end





local per="FU"
	use "$path/data/processed/SIGACTS_cleaned_panel_prepared.dta", clear
	panel_security `per'
	egen Pair_`per'=group(Pair `per')

	xi i.`per'
	foreach var of varlist _I* {
		gen treatment_`var'=`var'*treatment
		gen treatmentEast`var'=`var'*treatment*East
		gen treatmentNonEast`var'=`var'*treatment*(1-East)
		gen treatmentPashtun`var'=`var'*treatment*Pashtun_Share_District
		gen treatmentIncidents`var'=`var'*treatment*Incidents_District_Near_ln
		gen treatmentOpium`var'=`var'*treatment*Opium2006_2007_ln
		
	}

	

foreach dep in Inc_dum_Katz Inc_wins_ln_Katz  Inc_dum_pca Inc_dum_Anderson Inc_wins_ln_pca Inc_wins_ln_Anderson  Inc_Clear_dum_Katz Inc_Expld_dum_Katz Inc_Clear_wins_ln_Katz Inc_Expld_wins_ln_Katz Inc_Clear_dum_Anderson Inc_Expld_dum_Anderson  {	
	gen `dep'_BSS=`dep' if `per'==0
	bysort Geocode: egen `dep'_BS=mean(`dep'_BSS)	
	drop *_BSS
	gen `dep'_BS_East=`dep'_BS*East
}	
	
*Set dependent variable	
	
local dep="Inc_dum_Anderson"
	
****************************		
*Table 4 
	

preserve
	use "$path/results/Simulation_results_100000_security_dummy_`per'_Anderson.dta", replace
						 areg `dep'  treatment_* if `per'!=0 , a(Pair_`per') cluster(Cluster)
						foreach var of varlist _I* {
							qui count if abs(t_treatment_`var')>abs(_b[treatment_`var']/_se[treatment_`var'])
							local p`var'_1=r(N)/10000							
						}
						
						 areg `dep'  treatment_* `dep'_BS  if `per'!=0 , a(Pair_`per') cluster(Cluster)
						foreach var of varlist _I* {
							qui count if abs(t_BS_treatment_`var')>abs(_b[treatment_`var']/_se[treatment_`var'])
							local p`var'_2=r(N)/10000
						}

restore	
	 
		global file_treatment="Table 4 $S_DATE"
		local opt="replace"
		
			
		areg `dep'  treatment_* if `per'!=0 , a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label addstat ("Randomized P-values Midline", `p_IFU_1_1', "Randomized P-values Endline", `p_IFU_2_1', "Randomized P-values Post-Endline", `p_IFU_3_1')   se `opt' 
		local opt="append"

		areg `dep'  treatment_* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label  addstat ("Randomized P-values Midline", `p_IFU_1_2', "Randomized P-values Endline", `p_IFU_2_2', "Randomized P-values Post-Endline", `p_IFU_3_2')   se `opt' 

****************************		
*Table 6
			
preserve
	use "$path/results/Simulation_results_100000_security_dummy_`per'_Anderson.dta", replace
					n: di "Column 1"

					areg `dep'  treatment_* treatmentEast*  if `per'!=0 , a(Pair_`per') cluster(Cluster)
					foreach var of varlist _I* {
						qui count if abs(t_NonEasttreatment_`var')>abs(_b[treatment_`var']/_se[treatment_`var'])
						local p`var'_1=r(N)/10000	
						qui count if abs(t_treatmentEast`var')>abs(_b[treatmentEast`var']/_se[treatmentEast`var'])
						local p`var'_East_1=r(N)/10000	
					}

					
					
					n: di "Column 2"
					areg `dep'  treatment_* treatmentEast* `dep'_BS  if `per'!=0 , a(Pair_`per') cluster(Cluster)
					foreach var of varlist _I* {
						qui count if abs(t_BS_NonEasttreatment_`var')>abs(_b[treatment_`var']/_se[treatment_`var'])
						local p`var'_2=r(N)/10000	
						qui count if abs(t_BS_treatmentEast`var')>abs(_b[treatmentEast`var']/_se[treatmentEast`var'])
						local p`var'_East_2=r(N)/10000	
						}


restore	
		
		
global file_treatment="Table 6 $S_DATE"
		local opt="replace"
		areg `dep' treatment_* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)


		outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se) label  addstat ("Randomized P-values Midline", `p_IFU_1_1', "Randomized P-values Endline", `p_IFU_2_1', "Randomized P-values Post-Endline", `p_IFU_3_1', "Randomized P-values PakistanxMidline", `p_IFU_1_East_1', "Randomized P-values PakistanxEndline", `p_IFU_2_East_1', "Randomized P-values PakistanxPost-Endline", `p_IFU_3_East_1')   se `opt' 
				
		local opt="append"
		areg `dep'  treatment_* treatmentEast* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)

		outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se) label   addstat ("Randomized P-values Midline", `p_IFU_1_2', "Randomized P-values Endline", `p_IFU_2_2', "Randomized P-values Post-Endline", `p_IFU_3_2', "Randomized P-values PakistanxMidline", `p_IFU_1_East_2', "Randomized P-values PakistanxEndline", `p_IFU_2_East_2', "Randomized P-values PakistanxPost-Endline", `p_IFU_3_East_2')  se `opt' 
		
		

		
	
		
global file_treatment="Table 6 East  $S_DATE"
		local opt="replace"
		
preserve
	use "$path/results/Simulation_results_100000_security_dummy_`per'_Anderson.dta", replace
					n: di "Column 1"

					areg `dep'  treatmentNonEast_* treatmentEast*  if `per'!=0 , a(Pair_`per') cluster(Cluster)
					foreach var of varlist _I* {
						qui count if abs(t_Easttreatment_`var')>abs(_b[treatmentEast`var']/_se[treatmentEast`var'])
						local p`var'_1=r(N)/10000
					}
					
					
					n: di "Column 2"
					areg `dep'  treatmentNonEast_* treatmentEast* `dep'_BS  if `per'!=0 , a(Pair_`per') cluster(Cluster)
					foreach var of varlist _I* {
						qui count if abs(t_BS_Easttreatment_`var')>abs(_b[treatmentEast`var']/_se[treatmentEast`var'])
						local p`var'_2=r(N)/10000
					}	
restore	
				
		
		areg `dep' treatmentNonEast_* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",   dec(3) adec(3) aster(se) label  addstat ("Randomized P-values Pakistan Midline", `p_IFU_1_1', "Randomized P-values Pakistan Endline", `p_IFU_2_1', "Randomized P-values Pakistan Post-Endline", `p_IFU_3_1') se `opt' 
		local opt="append"
				
		areg `dep'  treatmentNonEast_* treatmentEast* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  dec(3) adec(3) aster(se) label  addstat ("Randomized P-values Pakistan Midline", `p_IFU_1_2', "Randomized P-values Pakistan Endline", `p_IFU_2_2', "Randomized P-values Pakistan Post-Endline", `p_IFU_3_2')  se `opt' 
		
		
		
		
	
		

*Within East distance to Pakistan (Table 7)
set more off
replace near_dist=near_dist/1000000

foreach var of varlist _I* {
		gen treatmentPK_distance`var'=`var'*treatment*near_dist
	}

	
	
global file_treatment="Table 7 $S_DATE"
local per="FU"
local opt="replace"
	
	
preserve
	use "$path/results/Simulation_results_100000_security_dummy_`per'_Anderson.dta", replace
		n: di "Column 1"	
		areg `dep'  treatment_* treatmentPK_dist* near_dist if `per'!=0 & East==1, a(Pair_`per') cluster(Cluster)
					foreach var of varlist _I* {
						qui count if abs(t_7_treatment_`var')>abs(_b[treatment_`var']/_se[treatment_`var'])
						local p`var'_1=r(N)/10000
						qui count if abs(t_7_dist_treatment_`var')>abs(_b[treatmentPK_dist`var']/_se[treatmentPK_dist`var'])
						local p`var'_dist_1=r(N)/10000
						}					

						
		n: di "Column 2"	
		areg `dep'  treatment_* treatmentPK_dist* near_dist `dep'_BS   if `per'!=0 & East==1, a(Pair_`per') cluster(Cluster)
					foreach var of varlist _I* {
						qui count if abs(t_BS_7_treatment_`var')>abs(_b[treatment_`var']/_se[treatment_`var'])
						local p`var'_2=r(N)/10000
						qui count if abs(t_BS_7_dist_treatment_`var')>abs(_b[treatmentPK_dist`var']/_se[treatmentPK_dist`var'])
						local p`var'_dist_2=r(N)/10000
						}					
		
restore	
	
		areg `dep'  treatment_* treatmentPK_distance* near_dist if `per'!=0 & East==1, a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  dec(3) adec(4) aster(se) label  addstat("Randomized P-values Midline", `p_IFU_1_1', "Randomized P-values Endline", `p_IFU_2_1', "Randomized P-values Post-Endline", `p_IFU_3_1', "Randomized P-values Distance Pakistan Midline", `p_IFU_1_dist_1', "Randomized P-values Distance Pakistan Endline", `p_IFU_2_dist_1', "Randomized P-values Distance Pakistan Post-Endline", `p_IFU_3_dist_1') se `opt' 
		local opt="append"
		areg `dep'  treatment_* treatmentPK_distance* near_dist `dep'_BS if `per'!=0 & East==1, a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  dec(3) adec(4) aster(se) label  addstat("Randomized P-values Midline", `p_IFU_1_1', "Randomized P-values Endline", `p_IFU_2_1', "Randomized P-values Post-Endline", `p_IFU_3_1', "Randomized P-values Distance Pakistan Midline", `p_IFU_1_dist_2', "Randomized P-values Distance Pakistan Endline", `p_IFU_2_dist_2', "Randomized P-values Distance Pakistan Post-Endline", `p_IFU_3_dist_2')  se `opt' 


		
		
		
		
		
******Online Appendix Tables


	
****************************		
*Table A5
		local opt="replace"	
foreach dep in Inc_dum_pca Inc_dum_Katz   {
	
	 
		global file_treatment="Table A5 $S_DATE"

		
		areg `dep'  treatment_* if `per'!=0 , a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label    se `opt' 
		local opt="append"

		areg `dep'  treatment_* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label    se `opt' 

	

		areg `dep' treatment_* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)
		local opt="append"
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}		
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label  addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 

		areg `dep'  treatment_* treatmentEast* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label  addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 
		
		

		areg `dep'  treatment_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncidents* if `per'!=0  , a(Pair_`per') cluster(Cluster)		
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}

		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 

		areg `dep'  treatment_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncidents* `dep'_BS if `per'!=0 , a(Pair_`per') cluster(Cluster)
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 
}
		
****************************		
*Table A6
		local opt="replace"	
foreach dep in Inc_wins_ln_Anderson Inc_wins_ln_pca Inc_wins_ln_Katz  {
	
	 
		global file_treatment="Table A6 $S_DATE"

		
		areg `dep'  treatment_* if `per'!=0 , a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label    se `opt' 
		local opt="append"

		areg `dep'  treatment_* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label    se `opt' 

	

		areg `dep' treatment_* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)
		local opt="append"
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}		
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label  addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 

		areg `dep'  treatment_* treatmentEast* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label  addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 
		
		
}
	

	
****************************		
*Table A7
			
local dep="Inc_dum_Anderson"



preserve
	use "$path/results/Simulation_results_100000_security_dummy_`per'_Anderson.dta", replace
					n: di "Column 1"					
						areg `dep'  treatment_* treatmentEast*  treatmentPashtun* treatmentOpium*  treatmentIncid* if `per'!=0 , a(Pair_`per') cluster(Cluster)
						foreach var of varlist _I* {
							qui count if abs(t_F_NonEasttreatment_`var')>abs(_b[treatment_`var']/_se[treatment_`var'])
							local p`var'_1=r(N)/10000
							qui count if abs(t_F_treatmentEast`var')>abs(_b[treatmentEast`var']/_se[treatmentEast`var'])
							local p`var'_East_1=r(N)/10000	
							qui count if abs(t_F_treatmentPashtun`var')>abs(_b[treatmentPashtun`var']/_se[treatmentPashtun`var'])
							local p`var'_Pashtun_1=r(N)/10000
							qui count if abs(t_F_treatmentOpium`var')>abs(_b[treatmentOpium`var']/_se[treatmentOpium`var'])
							local p`var'_Opium_1=r(N)/10000
							qui count if abs(t_F_treatmentIncid`var')>abs(_b[treatmentIncid`var']/_se[treatmentIncid`var'])
							local p`var'_Incid_1=r(N)/10000
							
						}
						
						areg `dep'  treatmentNonEast_* treatmentEast*  treatmentPashtun* treatmentOpium*  treatmentIncid* if `per'!=0 , a(Pair_`per') cluster(Cluster)
						foreach var of varlist _I* {
							qui count if abs(t_F_Easttreatment_`var')>abs(_b[treatmentEast`var']/_se[treatmentEast`var'])
							local p`var'_InEast_1=r(N)/10000	
						}					

						
						
						n: di "Column 2"
						areg `dep'  treatment_* treatmentEast*  treatmentPashtun* treatmentOpium*  treatmentIncid* `dep'_BS  if `per'!=0 , a(Pair_`per') cluster(Cluster)
						foreach var of varlist _I* {
							qui count if abs(t_BSF_NonEasttreatment_`var')>abs(_b[treatment_`var']/_se[treatment_`var'])
							local p`var'_2=r(N)/10000					
							qui count if abs(t_BSF_treatmentEast`var')>abs(_b[treatmentEast`var']/_se[treatmentEast`var'])
							local p`var'_East_2=r(N)/10000	
							qui count if abs(t_BSF_treatmentPashtun`var')>abs(_b[treatmentPashtun`var']/_se[treatmentPashtun`var'])
							local p`var'_Pashtun_2=r(N)/10000
							qui count if abs(t_BSF_treatmentOpium`var')>abs(_b[treatmentOpium`var']/_se[treatmentOpium`var'])
							local p`var'_Opium_2=r(N)/10000
							qui count if abs(t_BSF_treatmentIncid`var')>abs(_b[treatmentIncid`var']/_se[treatmentIncid`var'])
							local p`var'_Incid_2=r(N)/10000
							}					

						areg `dep'  treatmentNonEast_* treatmentEast*  treatmentPashtun* treatmentOpium*  treatmentIncid* `dep'_BS  if `per'!=0 , a(Pair_`per') cluster(Cluster)
						foreach var of varlist _I* {
							qui count if abs(t_BSF_Easttreatment_`var')>abs(_b[treatmentEast`var']/_se[treatmentEast`var'])
							local p`var'_InEast_2=r(N)/10000	
							}					
restore
		
global file_treatment="Table A7  $S_DATE"
		local opt="replace"
		

		areg `dep'  treatment_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncidents* if `per'!=0  , a(Pair_`per') cluster(Cluster)		

		outreg2 using "$file_treatment.xls",  dec(3) adec(3) aster(se) label ///
		addstat ("Randomized P-values Midline", `p_IFU_1_1', "Randomized P-values Endline", `p_IFU_2_1', "Randomized P-values Post-Endline", `p_IFU_3_1', ///
		"Randomized P-values PakistanxMidline", `p_IFU_1_East_1', "Randomized P-values PakistanxEndline", `p_IFU_2_East_1', "Randomized P-values PakistanxPost-Endline", `p_IFU_3_East_1', ///
		"Randomized P-values PashtunxMidline", `p_IFU_1_Pashtun_1', "Randomized P-values PashtunxEndline", `p_IFU_2_Pashtun_1', "Randomized P-values PashtunxPost-Endline", `p_IFU_3_Pashtun_1', /// 
		"Randomized P-values OpiumxMidline", `p_IFU_1_Opium_1', "Randomized P-values OpiumxEndline", `p_IFU_2_Pashtun_1', "Randomized P-values OpiumxPost-Endline", `p_IFU_3_Opium_1', ///  
		"Randomized P-values IncidxMidline", `p_IFU_1_Incid_1', "Randomized P-values IncidxEndline", `p_IFU_2_Incid_1', "Randomized P-values IncidxPost-Endline", `p_IFU_3_Incid_1')  se `opt' 
		
		local opt="append"
		areg `dep'  treatment_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncidents* `dep'_BS if `per'!=0 , a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  dec(3) adec(3) aster(se) label ///
		addstat ("Randomized P-values Midline", `p_IFU_1_2', "Randomized P-values Endline", `p_IFU_2_2', "Randomized P-values Post-Endline", `p_IFU_3_2', ///
		"Randomized P-values PakistanxMidline", `p_IFU_1_East_2', "Randomized P-values PakistanxEndline", `p_IFU_2_East_2', "Randomized P-values PakistanxPost-Endline", `p_IFU_3_East_2', ///
		"Randomized P-values PashtunxMidline", `p_IFU_1_Pashtun_2', "Randomized P-values PashtunxEndline", `p_IFU_2_Pashtun_2', "Randomized P-values PashtunxPost-Endline", `p_IFU_3_Pashtun_2', /// 
		"Randomized P-values OpiumxMidline", `p_IFU_1_Opium_2', "Randomized P-values OpiumxEndline", `p_IFU_2_Pashtun_2', "Randomized P-values OpiumxPost-Endline", `p_IFU_3_Opium_2', ///  
		"Randomized P-values IncidxMidline", `p_IFU_1_Incid_2', "Randomized P-values IncidxEndline", `p_IFU_2_Incid_2', "Randomized P-values IncidxPost-Endline", `p_IFU_3_Incid_2')  se `opt' 

		
*Bottom part of the table for the effect in East		
		
global file_treatment="Table A7 East"
		local opt="replace"


		areg `dep'  treatmentNonEast_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncidents* if `per'!=0  , a(Pair_`per') cluster(Cluster)		
		outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se) label  addstat("Randomized P-values Pakistan Midline", `p_IFU_1_InEast_1', "Randomized P-values Pakistan Endline", `p_IFU_2_InEast_1', "Randomized P-values Pakistan Post-Endline", `p_IFU_3_InEast_1')   se `opt' 
		
		local opt="append"
		areg `dep'  treatmentNonEast_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncidents* `dep'_BS if `per'!=0 , a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls", dec(3) adec(3) aster(se) label   addstat("Randomized P-values Pakistan Midline", `p_IFU_1_InEast_2', "Randomized P-values Pakistan Endline", `p_IFU_2_InEast_2', "Randomized P-values Pakistan Post-Endline", `p_IFU_3_InEast_2') se `opt' 


		
				
	
****************************		
*Table A17
	
local opt="replace"	
foreach dep in Inc_Clear_dum_Anderson Inc_Expld_dum_Anderson {
	
	 
		global file_treatment="Table A17 $S_DATE"
		
		
		areg `dep'  treatment_* if `per'!=0 , a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label    se `opt' 
		local opt="append"

		areg `dep'  treatment_* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label    se `opt' 

	

		areg `dep' treatment_* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)
		local opt="append"
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}		
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label  addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 

		areg `dep'  treatment_* treatmentEast* `dep'_BS if `per'!=0, a(Pair_`per') cluster(Cluster)
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label  addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 
		
		

		areg `dep'  treatment_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncidents* if `per'!=0  , a(Pair_`per') cluster(Cluster)		
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}

		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 

		areg `dep'  treatment_* treatmentEast* treatmentPashtun* treatmentOpium*  treatmentIncidents* `dep'_BS if `per'!=0 , a(Pair_`per') cluster(Cluster)
		forvalues i=1/2 {
			local FU`i'_East="999"
			capture {
			test treatment__IFU_`i'+treatmentEast_IFU_`i'=0
			local FU`i'_East=r(p)
			local FU`i'_East=999 if r(p)==.			
			}
		}
		outreg2 using "$file_treatment.xls",  bdec(3) aster(se) label addstat ("East in FU1", `FU1_East', "East in FU2", `FU2_East')  se `opt' 
}
		
	

	