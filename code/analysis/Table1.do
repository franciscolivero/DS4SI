tempfile district

	
use "$path/data/processed/Interactions_Ethnic_Security.dta", clear	
bysort Geocode1: egen Pashtun_Share_District=mean( Share_Pashtun_Tribe_MHH)

keep Geocode1  East Pashtun_Share_District Incs_District_Near
duplicates drop

merge 1:1 Geocode1 using "$path/data/raw/OpiumProductionDistricts.dta"
	replace Y2006=0 if Y2006==.	
	gen Opium2006_2007=(Y2006+Y2007)/2
	
keep PROVINCE_N DISTRICT_N Pashtun_Share_District Opium2006_2007 Incs_District_Near East
order PROVINCE_N DISTRICT_N Opium2006_2007 Incs_District_Near Pashtun_Share_District East
sort PROVINCE_N DISTRICT_N


export excel using "$path/results/Table1.xls", replace

	
