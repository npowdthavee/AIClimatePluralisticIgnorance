

import delimited "/Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/AI pluralistic ignorance/Data/For Github/predictions_all_stages_long.csv", clear 

keep if stage == 8
sort countrynew

save "/Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/AI pluralistic ignorance/Data/For Github/llm_predicted.dta", replace

import delimited "/Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/AI pluralistic ignorance/Data/For Github/data_final.csv", clear

sort countrynew

merge 1:1 countrynew using "/Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/AI pluralistic ignorance/Data/For Github/llm_predicted.dta" 

save "/Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/AI pluralistic ignorance/Data/For Github/llm_predicted.dta", replace

*mean_age
replace mean_age = "" if mean_age == "NA"
destring mean_age, replace
gen missing_mage = 0
replace missing_mage = 1 if mean_age==.
replace mean_age = 0 if mean_age ==.

* mean_gender
replace mean_gender = "" if mean_gender == "NA"
destring mean_gender, replace
gen missing_mgender = 0
replace missing_mgender = 1 if mean_gender==.
replace mean_gender = 0 if mean_gender ==.

* mean_edu
replace mean_edu = "" if mean_edu == "NA"
destring mean_edu, replace
gen missing_medu = 0
replace missing_medu = 1 if mean_edu==.
replace mean_edu = 0 if mean_edu ==.

* mean_religion
replace mean_religion = "" if mean_religion == "NA"
destring mean_religion, replace
gen missing_mreligion = 0
replace missing_mreligion = 1 if mean_religion==.
replace mean_religion = 0 if mean_religion ==.

* hdi_2021
replace hdi_2021 = "" if hdi_2021 == "NA"
destring hdi_2021, replace
gen missing_hdi = 0
replace missing_hdi = 1 if hdi_2021==.
replace hdi_2021 = 0 if hdi_2021 ==. 

* temp_mean_2010_2019
gen missing_temp = 0  
replace missing_temp = 1 if temp_mean_2010_2019==. & missing_temp~=.
replace temp_mean_2010_2019 = 0 if temp_mean_2010_2019 ==.

foreach var in wtc_own wtc_other mean_age mean_gender mean_edu mean_religion hdi_2021 gdp_capita_2021 top1pct_income temp_mean_2010_2019 pred_gpt pred_claude pred_llama pred_gemini {
    egen `var'_std = std(`var')
}
 
* Label the variables
label variable wtc_own_std "Own willingness to contribute"
label variable wtc_other_std "Actual perceived others' willingness"
label variable pred_gpt_std "GPT: perceived others' willingness"
label variable pred_claude_std "Claude: perceived others' willingness"
label variable pred_gemini_std "Gemini: perceived others' willingness"
label variable pred_llama_std "Llama: perceived others' willingness"
label variable mean_age_std "Average age"
label variable mean_gender_std "Average gender"
label variable mean_edu_std "Average education level"
label variable mean_religion_std "Average religiosity"
label variable hdi_2021_std "HDI index (2021)"
label variable gdp_capita_2021_std "GDP per capita (2021)"
label variable top1pct_income_std "Share of income held by the top 1% (2021)"
label variable temp_mean_2010_2019_std "Average temperature 2010-2019"

* Run the five regressions with robust standard errors
reg wtc_other_std wtc_own_std mean_age_std mean_gender_std mean_edu_std mean_religion_std hdi_2021_std gdp_capita_2021_std top1pct_income_std temp_mean_2010_2019_std, robust
estimates store model1

reg pred_gpt_std wtc_own_std mean_age_std mean_gender_std mean_edu_std mean_religion_std hdi_2021_std gdp_capita_2021_std top1pct_income_std temp_mean_2010_2019_std, robust
estimates store model2

reg pred_claude_std wtc_own_std mean_age_std mean_gender_std mean_edu_std mean_religion_std hdi_2021_std gdp_capita_2021_std top1pct_income_std temp_mean_2010_2019_std, robust
estimates store model3

reg pred_gemini_std wtc_own_std mean_age_std mean_gender_std mean_edu_std mean_religion_std hdi_2021_std gdp_capita_2021_std top1pct_income_std temp_mean_2010_2019_std, robust
estimates store model4

reg pred_llama_std wtc_own_std mean_age_std mean_gender_std mean_edu_std mean_religion_std hdi_2021_std gdp_capita_2021_std top1pct_income_std temp_mean_2010_2019_std, robust
estimates store model5

* Display results in one table
esttab model1 model2 model3 model4 model5, ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Actual" "GPT" "Claude" "Gemini" "Llama") ///
    title("Regression Results") ///
    r2 ar2 scalars(N) label

	* Export results to Word document
esttab model1 model2 model3 model4 model5 using "/Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/AI pluralistic ignorance/Data/For Github/regression_results.rtf", ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Actual" "GPT" "Claude" "Gemini" "Llama") ///
    title("Regression Results") ///
    r2 ar2 scalars(N) label replace

