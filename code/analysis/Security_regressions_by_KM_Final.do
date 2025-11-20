
clear all
tempfile first district
use "$path/data/processed/SIGACTS_cleaned_panel_prepared.dta", clear


*Overlapping concentric circles
program  by_KM_security
	args  period 
	foreach var of varlist Inc*km* {
	gen `var'_dum=`var'
	rename `var' `var'_num
	}
	collapse (sum) *_num (max) *_dum, by (Geocode `period')
	replace `period'=0 if `period'==.
	tsset Geocode `period'
	tsfill, full
	merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta", keepusing (Geocode1 treatment   POINT_X POINT_Y  atlarge referendum C5 C2) nogen
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
		foreach suf in "" "_Clear" "_Expld" "_IED" "_Fire" {
			forvalues y=1/15 {
					qui sum Inc`y'km`suf'_num`x', d
					gen Inc`y'km`suf'_num_wins`x'=Inc`y'km`suf'_num`x'
					*replace Inc`y'km`suf'_num_wins`x'=r(p95) if Inc`y'km`suf'_num`x'>r(p95) & r(p95)!=0
					gen Inc`y'km`suf'_num_wins_ln`x'=ln(1+Inc`y'km`suf'_num_wins`x')
					drop Inc`y'km`suf'_num_wins`x'

			}	
		order Inc*km`suf'_num_wins_ln`x', alpha after(Pair)
		order Inc*`suf'_dum`x', alpha after(Pair)
		}

	}
	
	

	keep Geocode treatment  atlarge  POINT_X POINT_Y referendum Pair Cluster *_num_wins_ln* *_dum*
	local var=""
	foreach suf in "" "_Clear" "_Expld"  "_IED" "_Fire" {
		forvalues y=1/15 {
			local var="`var' Inc`y'km`suf'_num_wins_ln Inc`y'km`suf'_dum"
		}
	}	
	reshape long `var', i(Geocode) j(`period')
	merge m:1 Geocode using "$path/data/processed/Interactions_Ethnic_Security.dta", nogen
	*merge m:1 Geocode using "$path/GIS/Villages_Distance_Pakistan.dta", nogen keepusing(near_dist)	
	
	
end



local per="FU"
by_KM_security `per'




	egen Pair_`per'=group(Pair `per')

	xi i.`per'
	foreach var of varlist _I* {
		gen treatment_`var'=`var'*treatment
		gen treatmentEast`var'=`var'*treatment*East
		gen treatmentNonEast`var'=`var'*treatment*(1-East)
	}
	



drop if FU==0
xi i.Pair_`per', pref(_FE)


*Produce results thar are reported in Panels B of Table A.8 and A.9 and used for graphs 3 and 4

global file_treatment="Incidents Intensive by KM $S_DATE"
global file_treatment_ci5="Incidents Intensive by KM ci5 $S_DATE"
global file_treatment_ci10=" Incidents Intensive  by KM ci10 $S_DATE"
global file_treatment_int="Incidents Intensive Interaction by KM  $S_DATE"
global file_treatment_int_diff="Incidents Intensive diff by KM  $S_DATE"
global file_treatment_int_ci5="Incidents Intensive Interaction by KM  ci5 $S_DATE"
global file_treatment_int_ci10="Incidents Intensive Interaction by KM  ci10 $S_DATE"

global opt="replace"
foreach suf in ""  {
	forvalues  x=1/15 {

						areg Inc`x'km`suf'_num_wins_ln treatment_*  if `per'!=0, a(Pair_`per') cluster(Cluster)
						outreg2 using "$file_treatment.xls",  bdec(3)   aster(se) se  label  ct("`suf'", "`x' KM")   $opt 
						outreg2 using "$file_treatment_ci5.xls",  bdec(3)   label  ct("`suf'", "`x' KM")  ci level(95) $opt 
						outreg2 using "$file_treatment_ci10.xls",  bdec(3)   label  ct("`suf'", "`x' KM")  ci level(90) $opt 

						areg Inc`x'km`suf'_num_wins_ln treatment_* treatmentEast* if `per'!=0, a(Pair_`per') cluster(Cluster)
						outreg2 using "$file_treatment_int_diff.xls",  bdec(3)   aster(se) se  label  ct("`suf'", "`x' KM")   $opt 



						areg Inc`x'km`suf'_num_wins_ln treatmentNonEast* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)				
						outreg2 using "$file_treatment_int.xls",  bdec(3)   aster(se) se  label  ct("`suf'", "`x' KM")   $opt 
						outreg2 using "$file_treatment_int_ci5.xls",  bdec(3)   label  ct("`suf'", "`x' KM")  ci level(95) $opt 
						outreg2 using "$file_treatment_int_ci10.xls",  bdec(3)   label  ct("`suf'", "`x' KM")  ci level(90) $opt 

	global opt="append"
	}
}



*Produce results thar are reported in Panels A of Table A.8 and A.9
global file_treatment="Incidents Extensive by KM $S_DATE"
global file_treatment_int="Incidents Extensive Interaction by KM $S_DATE"



global opt="replace"
foreach suf in ""  {
	forvalues  x=1/15 {

						areg Inc`x'km`suf'_dum treatment_*  if `per'!=0, a(Pair_`per') cluster(Cluster)
						outreg2 using "$file_treatment.xls",  bdec(3)   aster(se) se  label  ct("`suf'", "`x' KM")   $opt 
						outreg2 using "$file_treatment_ci5.xls",  bdec(3)   label  ct("`suf'", "`x' KM")  ci level(95) $opt 
						outreg2 using "$file_treatment_ci10.xls",  bdec(3)   label  ct("`suf'", "`x' KM")  ci level(90) $opt 

						areg Inc`x'km`suf'_dum treatment_* treatmentEast* if `per'!=0, a(Pair_`per') cluster(Cluster)
						outreg2 using "$file_treatment_int_diff.xls",  bdec(3)   aster(se) se  label  ct("`suf'", "`x' KM")   $opt 



						areg Inc`x'km`suf'_dum  treatmentNonEast* treatmentEast*  if `per'!=0, a(Pair_`per') cluster(Cluster)				
						outreg2 using "$file_treatment_int.xls",  bdec(3)   aster(se) se  label  ct("`suf'", "`x' KM")   $opt 
						outreg2 using "$file_treatment_int_ci5.xls",  bdec(3)   label  ct("`suf'", "`x' KM")  ci level(95) $opt 
						outreg2 using "$file_treatment_int_ci10.xls",  bdec(3)   label  ct("`suf'", "`x' KM")  ci level(90) $opt 

	global opt="append"
	}
}




local per="FU"

	local x=1

						areg Inc`x'km_dum treatment__IFU_1 treatment__IFU_2  if `per'!=0, a(Pair_`per') cluster(Cluster)
						qui reg Inc`x'km_dum treatment_* _FE* if `per'!=0
						estimates store Inc`x'km_dum_average
						global opt="append"
						
	forvalues  x=2/14 {

						areg Inc`x'km_dum treatment_*  if `per'!=0, a(Pair_`per') cluster(Cluster)
						qui reg Inc`x'km_dum treatment_* _FE* if `per'!=0
						estimates store Inc`x'km_dum_average
						
						
	global opt="append"
	}

	local x=15

						areg Inc`x'km_dum treatment__IFU_1 treatment__IFU_2  if `per'!=0, a(Pair_`per') cluster(Cluster)
						qui reg Inc`x'km_dum treatment_* _FE* if `per'!=0
						estimates store Inc`x'km_dum_average
		



local per="FU"

	forvalues  x=1/15 {

						areg Inc`x'km_num_wins_ln treatment_*  if `per'!=0, a(Pair_`per') cluster(Cluster)
						qui reg Inc`x'km_num_wins_ln treatment_* _FE* if `per'!=0
						estimates store Inc`x'km_num_wins_ln_average


						areg Inc`x'km_num_wins_ln treatmentEast* treatmentNonEast* if `per'!=0, a(Pair_`per') cluster(Cluster)				
						qui reg Inc`x'km_num_wins_ln treatmentEast* treatmentNonEast* _FE* if `per'!=0		
						estimates store Inc`x'km_num_wins_ln_hetero
						*/
						
	global opt="append"
	}
	
	
	
 /*Calculating p-values that are reported on Figures 3 and 4
	

suest Inc1km_num_wins_ln_average Inc2km_num_wins_ln_average Inc3km_num_wins_ln_average Inc4km_num_wins_ln_average Inc5km_num_wins_ln_average Inc6km_num_wins_ln_average Inc7km_num_wins_ln_average Inc8km_num_wins_ln_average Inc9km_num_wins_ln_average Inc10km_num_wins_ln_average Inc11km_num_wins_ln_average Inc12km_num_wins_ln_average Inc13km_num_wins_ln_average Inc14km_num_wins_ln_average Inc15km_num_wins_ln_average, vce(cluster Cluster)

forvalues t=1/3 {
	test [Inc1km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc2km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc3km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc4km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc5km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc6km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc7km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc8km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc9km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc10km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc11km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc12km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc13km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc14km_num_wins_ln_average_mean]treatment__IFU_`t'=[Inc15km_num_wins_ln_average_mean]treatment__IFU_`t'=0
}


suest Inc1km_num_wins_ln_hetero Inc2km_num_wins_ln_hetero Inc3km_num_wins_ln_hetero Inc4km_num_wins_ln_hetero Inc5km_num_wins_ln_hetero Inc6km_num_wins_ln_hetero Inc7km_num_wins_ln_hetero Inc8km_num_wins_ln_hetero Inc9km_num_wins_ln_hetero Inc10km_num_wins_ln_hetero Inc11km_num_wins_ln_hetero Inc12km_num_wins_ln_hetero Inc13km_num_wins_ln_hetero Inc14km_num_wins_ln_hetero Inc15km_num_wins_ln_hetero, vce(cluster Cluster)

forvalues t=1/3 {
	test [Inc1km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc2km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc3km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc4km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc5km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc6km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc7km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc8km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc9km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc10km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc11km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc12km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc13km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc14km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=[Inc15km_num_wins_ln_hetero_mean]treatmentEast_IFU_`t'=0
}

forvalues t=1/3 {
	test [Inc1km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc2km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc3km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc4km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc5km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc6km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc7km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc8km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc9km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc10km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc11km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc12km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc13km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc14km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=[Inc15km_num_wins_ln_hetero_mean]treatmentNonEast_IFU_`t'=0
}


