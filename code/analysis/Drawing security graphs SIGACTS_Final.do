*Graphs for average effects
*Results are calculate using Security_regressions_by_KM_RR and then pasted to Stat using Excel



*Same for Dummies
*Graphs for average effects
*Results are calculate using Security_Village_Level_H_and_M_panel_regressions and then pasted to Stat using Excel


use "$path/data/processed/Security_results_intensive_graph.dta", clear
gen km=_n
rename var1 coef_FU1
rename var2 low_FU1
rename var3 high_FU1
rename var4 low_10_FU1
rename var5 high_10_FU1 


rename var6 coef_FU2
rename var7 low_FU2
rename var8 high_FU2
rename var9 low_10_FU2
rename var10 high_10_FU2


rename var11 coef_FU3
rename var12 low_FU3
rename var13 high_FU3
rename var14 low_10_FU3
rename var15 high_10_FU3

*local cond="if km>=2 "
*Eastern regions
twoway ///
(rarea high_FU1 low_FU1 km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU1 low_10_FU1 km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU1 km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off) xscale(range(1 15))   xlabel(5 (10) 15) title("Effect at Midline") name("FU1", replace) note("p-value for the equality of all coefficients to zero is 0.000")

twoway ///
(rarea high_FU2 low_FU2 km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU2 low_10_FU2 km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU2 km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off) xscale(range(1 15))   xlabel(5 10 15) title("Effect at Endline") name("FU2", replace) note("p-value for the equality of all coefficients to zero is 0.000")

twoway ///
(rarea high_FU3 low_FU3 km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU3 low_10_FU3 km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU3 km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off) xscale(range(1 15))  xlabel(5 10 15) title("Effect After Endline") name("FU3", replace) note("p-value for the equality of all coefficients to zero is 0.000")


graph combine FU1 FU2 FU3,  xsize(6) ysize(8) rows(2) cols(1) ycommon
graph save Graph "Figure3", replace


use "$path/data/processed/Security_results_intensive_graph_interaction.dta", clear
gen km=_n
rename var1 coef_FU1
rename var2 low_FU1
rename var3 high_FU1
rename var4 low_10_FU1
rename var5 high_10_FU1 


rename var6 coef_FU2
rename var7 low_FU2
rename var8 high_FU2
rename var9 low_10_FU2
rename var10 high_10_FU2

rename var11 coef_FU3
rename var12 low_FU3
rename var13 high_FU3
rename var14 low_10_FU3
rename var15 high_10_FU3


rename var16 coef_FU1_noneast
rename var17 low_FU1_noneast
rename var18 high_FU1_noneast
rename var19 low_10_FU1_noneast
rename var20 high_10_FU1_noneast 


rename var21 coef_FU2_noneast
rename var22 low_FU2_noneast
rename var23 high_FU2_noneast
rename var24 low_10_FU2_noneast
rename var25 high_10_FU2_noneast

rename var26 coef_FU3_noneast
rename var27 low_FU3_noneast
rename var28 high_FU3_noneast
rename var29 low_10_FU3_noneast
rename var30 high_10_FU3_noneast


*local cond="if km>=2 "
*Eastern regions
twoway ///
(rarea high_FU1 low_FU1 km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU1 low_10_FU1 km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU1 km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off) xscale(range(1 15))  xlabel(5 10 15) title("Effect at Midline") name("FU1_east", replace)  note("p-value for the equality of all coefficients to zero is 0.000")

twoway ///
(rarea high_FU2 low_FU2 km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU2 low_10_FU2 km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU2 km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off) xscale(range(1 15))  xlabel(5 10 15) title("Effect at Endline") name("FU2_east", replace)  note("p-value for the equality of all coefficients to zero is 0.000")

twoway ///
(rarea high_FU3 low_FU3 km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU2 low_10_FU2 km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU2 km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off) xscale(range(1 15))  xlabel(5 10 15) title("Effect After Endline") name("FU3_east", replace)  note("p-value for the equality of all coefficients to zero is 0.000")



*Non-Eastern regions

twoway ///
(rarea high_FU1_noneast low_FU1_noneast km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU1_noneast low_10_FU1_noneast km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU1_noneast km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off)  xscale(range(1 15)) xscale(range(1 15))  xlabel(5 10 15) title("Effect at Midline") name("FU1_noneast", replace)  note("p-value for the equality of all coefficients to zero is 0.004")

twoway ///
(rarea high_FU2_noneast low_FU2_noneast km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU2_noneast low_10_FU2_noneast km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU2_noneast km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off) xscale(range(1 15))  xlabel(5 10 15) title("Effect at Endline") name("FU2_noneast", replace)  note("p-value for the equality of all coefficients to zero is 0.001")

twoway ///
(rarea high_FU3_noneast low_FU3_noneast km `cond', pstyle(ci) color(gs15)) ///
(rarea high_10_FU3_noneast low_10_FU3_noneast km `cond', pstyle(ci) color(gs14)) ///
(line coef_FU3_noneast km `cond')  (pcarrowi  0 1  0 15, msize(zero) lcolor(black)) ///
(pci 0 1 0 15, color(black)),  legend(off) xscale(range(1 15))  xlabel(5 10 15) title("Effect After Endline") name("FU3_noneast", replace)  note("p-value for the equality of all coefficients to zero is 0.000")


graph combine FU1_noneast FU2_noneast FU3_noneast,   rows(2) cols(1) ycommon title("Region Not Bordering Pakistan") xsize(4) ysize(6)

graph save Graph  "Figure4_nonEast", replace

graph combine FU1_east FU2_east FU3_east,   rows(2) cols(1) ycommon title("Region Bordering Pakistan") xsize(4) ysize(6)
graph save Graph  "Figure4_East", replace
 
