*Just Run this file and all the datasets and analysis will be created. 

set more off



global path "C:/Users/Francisco Olivero/Dropbox/NYU/Subjects/01. I Semester/DataScience/Final Project/198483-V1"


cd "$path/results/"

do "$path/code/analysis/config_stata.do"

do "$path/code/create/Baseline_Village_Characteristics.do"
do "$path/code/create/Combine_data_H_and_M_Full_SIGACTS_RR.do"
do "$path/code/create/Interactions_Ethnic_Projects_Matching_Security_data_RR.do"
do "$path/code/create/Prepare_panel_SIGACTS_data_indices_RR.do"
do "$path/code/create/Prepare_panel_SIGACTS_data_RR.do"
do "$path/code/create/Security_Index_for_summary.do"

do "$path/code/analysis/Security_Panel_regressions_Revision_Simulations_Final"
do "$path/code/analysis/Combined_results_H_and_M_simulation_Revision_Final"


do "$path/code/analysis/Table1.do"
do "$path/code/analysis/Treatment_control_BS_Final.do"
do "$path/code/analysis/Treatment_control_Summary_Outcomes_Final.do"
do "$path/code/analysis/Security_Panel_regressions_Revision_Final.do"
do "$path/code/analysis/Survey_results_H_and_M_Final.do"
do "$path/code/analysis/Security_Incidents_histogram_Final.do"
do "$path/code/analysis/Security_regressions_by_KM_Final.do"
do "$path/code/analysis/Drawing security graphs SIGACTS_Final.do"

do "$path/code/analysis/NSP_NRVA_comparison_Final.do"
do "$path/code/analysis/Attrition_villages_HM_analysis_Final.do"
do "$path/code/analysis/Attrition Analysis Individual_Final.do"

*New Analysis for DS4SI.
do "$path/code/analysis/New_Analysis_DS4SI.do"

