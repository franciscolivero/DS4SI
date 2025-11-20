tempfile Tribe_MHH MHH district



use  "$path/data/raw/SIGACTS_cleaned.dta", clear
gen byte Before=(year<2007 | (year==2007 & month<10))
keep if Before
drop if PrimaryCategory==1 | PrimaryCategory==3
/*
4	Adraskan
36	Balkh
67	Chishti Sharif
99	Du Layna
105	Farsi
126	Gulran
132	Hesarak
183	Khost Wa Firing
300	Sangi Takht
335	Shirzad

DISTRICT_N	Geocode1
SHER ZAD	1009
HESARAK	1010
KHOST WA FIRING	1613
BALKH	1909
GULRAN	2407
ADRASKAN	2411
FERSI	2413
CHISHTI SHARIF	2415
DULEENA	3105
SANG TAKHT	3405
*/
gen Geocode1=.
keep if District==4 |  District==36 |  District==67 |  District==99 |  District==105 |  District==126 |  District==132 |  District==183 |  District==300 |  District==335
replace Geocode1=2411 if District==4
replace Geocode1=1909 if District==36
replace Geocode1=2415 if District==67
replace Geocode1=3105 if District==99
replace Geocode1=2413 if District==105
replace Geocode1=2407 if District==126
replace Geocode1=1010 if District==132
replace Geocode1=1613 if District==183
replace Geocode1=3405 if District==300
replace Geocode1=1009 if District==335
gen byte Incs_District_Inside=1
collapse (count) Incs_District_Inside, by (Geocode1)
save `district'


use "$path/data/raw/SIGACTS_cleaned_distances.dta", clear
drop if distance>15000
gen byte Before=(year<2007 | (year==2007 & month<10))
keep if Before
drop if PrimaryCategory==1 | PrimaryCategory==3


merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta"

keep  ID Geocode1 DISTRICT_N PROVINCE_N
duplicates drop
collapse (count)  ID, by  (Geocode1 DISTRICT_N PROVINCE_N)
rename ID Incs_District_Near
merge 1:1 Geocode1 using `district', nogen
replace Incs_District_Inside=0 if Incs_District_Inside==.
drop DISTRICT_N PROVINCE_N
save `district', replace


use "$path/data/raw/MHH_BS.dta", clear


preserve
keep Geocode Q_1_11
drop if Q_1_11==.
gen byte Number_Tribe=1
collapse (sum) Number_Tribe , by(Geocode Q_1_11)
reshape wide Number_Tribe, i(Geocode) j(Q_1_11)
egen Total=rowtotal(Number_Tribe*)
forvalues x=1/8 {
replace Number_Tribe`x'=0 if Number_Tribe`x'==.
gen Tribe_Share`x'_sq= (Number_Tribe`x'/Total)^2
}
egen Frac_Tribe_MHH= rowtotal(Tribe_Share*_sq)
replace Frac_Tribe_MHH=1-Frac_Tribe_MHH
gen Share_Pashtun_Tribe_MHH=Number_Tribe1/Total
keep Geocode Frac_Tribe_MHH Share_Pashtun_Tribe_MHH
save `Tribe_MHH'
restore

keep Geocode Q_1_12
gen byte Number_Lang=1
drop if Q_1_12==.
replace Q_1_12=4 if Q_1_12==7
collapse (sum) Number_Lang, by(Geocode Q_1_12)
reshape wide Number_Lang, i(Geocode) j(Q_1_12)
egen Total=rowtotal(Number_Lang*)
forvalues x=1/6 {
replace Number_Lang`x'=0 if Number_Lang`x'==.
gen Lang_Share`x'_sq= (Number_Lang`x'/Total)^2
}
egen Frac_Lang_MHH= rowtotal(Lang_Share*_sq)
replace Frac_Lang_MHH =1-Frac_Lang_MHH
gen Share_Pashtun_Lang_MHH = Number_Lang1/Total
keep Geocode Frac_Lang_MHH Share_Pashtun_Lang_MHH

merge 1:1 Geocode using "`Tribe_MHH'", nogen
save `MHH'

use "$path/data/raw/MS_BS.dta", clear
rename Q_2_01Average Population
keep Geocode  Q_2_08_Pashton- Q_2_14_Other Population
replace Q_2_08_Pashton=1 if Q_2_08_Pashton==.
foreach var of varlist  Q_2_08_Pashton- Q_2_14_Other {
replace `var'=`var'-1
}

egen Mixed_MS=rowtotal(Q_2_08_Pashton- Q_2_14_Other)

 
keep Geocode Mixed_MS  Population
gen Mixed_MS_Binary=(Mixed_MS>1)
merge 1:1 Geocode using "`MHH'", nogen
replace Geocode=Geocode/100000

replace Geocode=10090090 if Geocode==10090111
replace Geocode=16130097 if Geocode==16130107
replace Geocode=19090000 if Geocode==19090039
replace Geocode=19090017 if Geocode==19090056
replace Geocode=24070138 if Geocode==24070077
replace Geocode=24071000 if Geocode==24070166
replace Geocode=24070000 if Geocode==24070174
replace Geocode=24110051 if Geocode==24110011
replace Geocode=24150000 if Geocode==24150016
replace Geocode=10100012 if Geocode==10100005
replace Geocode=10100007 if Geocode==10100029
replace Geocode=10100011 if Geocode==10100042
replace Geocode=10100009 if Geocode==10100089
replace Geocode=10100014 if Geocode==10100096
replace Geocode=10100021 if Geocode==10100094
replace Geocode=10100024 if Geocode==10100093
replace Geocode=10100087 if Geocode==10100092
replace Geocode=10100048 if Geocode==10100047
*Different geocode for Iragi Mughula if Gulran
replace Geocode=24071000 if Geocode==24070163


*merge 1:1 Geocode using "$path/Afganistan/1FU/Hearts and Minds/Projects_implementation_data.dta", gen (_merge_projects)
*drop if _merge_projects==2
*merge 1:1 Geocode using "$path/Afganistan/1FU/Hearts and Minds/Matching_variables.dta", gen(_merge_matching)
merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta", keepusing(Geocode1) nogen
merge m:1 Geocode1 using `district', gen(_merge_security)

gen byte East=(Geocode1==1010 | Geocode1==1009)

keep  Geocode Geocode1 East Share_Pashtun_Tribe_MHH Incs_District_Near 
save "$path/data/processed/Interactions_Ethnic_Security.dta", replace
