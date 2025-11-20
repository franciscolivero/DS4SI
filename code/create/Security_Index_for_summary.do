*Run after Prepare_panel_SIGACTS

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
	
	
keep *Anderson* *Katz* *pca* FU East treatment Geocode

label var Inc_dum_Anderson "Index for Occurrence of at Least One Security Incident"
save "$path/data/processed/Security_indices_summary.dta", replace
