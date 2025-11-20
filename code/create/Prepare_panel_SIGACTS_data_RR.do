set more off
tempfile first district


use  "$path/data/raw/SIGACTS_cleaned.dta", clear
gen byte Before=(year<2007 | (year==2007 & month<10))
gen byte OldSample=((Before==0) & ((year<2010) |(year==2010 & month<4)))

*keep if Before
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
335	ShirzadSIGACTS_panel_ready_FU

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
 keep  ID Geocode1 
duplicates drop
collapse (count)  ID, by  (Geocode1)
rename ID Incs_District_Near
merge 1:1 Geocode1 using `district', nogen
replace Incs_District_Inside=0 if Incs_District_Inside==.
save `district', replace



**
use "$path/data/raw/SIGACTS_cleaned_distances.dta", clear
*Only Incs within 15km
drop if distance>15000

*Drop criminal activity (arson and assault)
drop if PrimaryCategory==1 | PrimaryCategory==3
gen byte year_month=(year-2007)*12+(month-10)




*October 2007 is set to zero
*Threshold for FU1 is October 2009,  year_month=24
*Threshold for FU2 is October 2011,  year_month=48
*The last year_month if 86 (December 2014)
*Used to be until December 2011, year_month=50

*Defince variables for different aggregations

*All together
gen byte Pull=(year_month>=0)



*Three periods FU1, FU2, post FU2
gen byte FU=(year_month>=0)
replace FU=1 if (year_month>=0 & year_month<24)
replace FU=2 if (year_month>=24 & year_month<48)
replace FU=3 if (year_month>=48)

*Three periods as they were defined in 2012 working paper
gen byte OLD=(year_month>=0) 
replace OLD=1 if (year_month>=0 & year_month<15)
replace OLD=2 if (year_month>=15 & year_month<30)
replace OLD=3 if (year_month>=30)

*By year
gen byte Year=(year_month>=0)
forvalues x=1/6 {
replace Year=`x' if (year_month>=(`x'-1)*12 & year_month<`x'*12)
}
replace Year=7 if (year_month>=72)

*By Halfyear
gen byte Halfyear=(year_month>=0)
forvalues x=1/12 {
replace Halfyear=`x' if (year_month>=(`x'-1)*6 & year_month<`x'*6)
}
replace Halfyear=13 if (year_month>=78)

*By quarter
gen byte Quarter=(year_month>=0)
forvalues x=1/29 {
replace Quarter=`x' if (year_month>=(`x'-1)*3 & year_month<`x'*3)
}


*****************************
*Gen measures of security by km


foreach x of numlist 1/15 {
gen byte Inc`x'km=(( distance <`x'000))
gen byte Inc`x'km_Clear=(( distance <`x'000)  & PrimaryCategory==7)
gen byte Inc`x'km_Expld=(( distance <`x'000) & (PrimaryCategory==6 | PrimaryCategory==8 | PrimaryCategory==11))
gen byte Inc`x'km_IED=(( distance <`x'000)  & (PrimaryCategory==6 | PrimaryCategory==8 | PrimaryCategory==11| PrimaryCategory==7))
gen byte Inc`x'km_Fire=(( distance <`x'000)  & (PrimaryCategory==2 | PrimaryCategory==4 | PrimaryCategory==5| PrimaryCategory==9 ))
}




merge m:1 Geocode using "$path/data/raw/Treatment assignment00000.dta", keepusing(Geocode1) nogen
merge m:1 Geocode1 using `district', nogen
save "$path/data/processed/SIGACTS_cleaned_panel_prepared.dta", replace
