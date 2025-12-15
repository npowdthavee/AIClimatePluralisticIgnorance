# AIClimatePluralisticIgnorance

This repository accompanies the paper:

**Large language models predict pluralistic ignorance about climate action across countries**

It contains the code and documentation used to analyse whether large language models (LLMs) can predict country-level pluralistic ignorance regarding support for climate action, and whether observed predictive performance reflects structured inference from contextual information rather than direct recall of survey-specific quantities.

---

## Project overview

Pluralistic ignorance arises when individuals systematically misperceive the beliefs or preferences of others. Using data from the Global Climate Change Survey (GCCS), this project evaluates whether LLMs can infer second-order beliefs, beliefs about others’ willingness to contribute to climate action, at the country level.

The analysis proceeds in four steps:

1. Construction of country-level ground-truth measures from survey data  
2. Elicitation of predictions from multiple LLMs using controlled prompts  
3. Evaluation against statistical benchmarks  
4. Diagnostic tests designed to distinguish structured inference from data exposure  

---

## Data sources

### Global Climate Change Survey (GCCS)

Survey outcomes and sociodemographic aggregates are derived from the Global Climate Change Survey administered as part of the Gallup World Poll 2021–2022. The survey covers 125 countries and includes paired questions on:

- Respondents’ own willingness to contribute at least 1 percent of household income to fight global warming (first-order willingness)  
- Respondents’ beliefs about how willing others in their country are to contribute (second-order belief)

All variables are aggregated to the country level using Gallup sampling weights.

### Country-level covariates

Additional country-level inputs include:

- Sociodemographic aggregates from the Gallup World Poll  
- Macroeconomic indicators and long-run average temperature from the same external sources used in Andre et al. (2024)  
- Internet penetration from World Bank Open Data  

No perceived norms, pluralistic ignorance measures, rankings, or second-order beliefs are provided to the models as inputs.

---

## Large language models evaluated

The following models are evaluated:

- GPT-4o mini  
- Claude 3.5 Haiku  
- Gemini 2.5 Flash  
- Llama 4 Maverick (17B)

All models are accessed via their respective APIs. Queries are executed after the public release of the GCCS paper and its accompanying website. Decoding is deterministic, with temperature set to zero where applicable.

---

## Prompting protocol

### System prompt

All models receive a fixed system-level instruction that constrains responses to general reasoning based solely on the information provided in the user prompt and explicitly discourages reliance on memorised statistics, survey results, or academic sources.

The verbatim system prompt is provided in the Supplementary Materials and in the `prompts/` directory of this repository.

### User prompt and staged design

Predictions are elicited using a structured user prompt developed within a staged information framework. Earlier stages progressively restrict the information provided to the model, such as country name only.

The main analysis reports results from the final full-specification stage only. Earlier stages are used exclusively for ablation and diagnostic tests.

In the full-specification condition (Stage 8), models are instructed to estimate second-order beliefs conditional on a clearly specified information set that includes:

- Country name  
- Aggregated sociodemographic characteristics  
- Macroeconomic indicators  
- Long-run average temperature  
- Country-level distribution of first-order willingness  

The verbatim system prompt, the full-specification user prompt, and the 24 prompts used in robustness checks are archived in the prompts/ directory and reproduced in the Supplementary Materials.

---

## Evaluation and diagnostics

Model performance is evaluated primarily using mean absolute error between predicted and observed country-level second-order beliefs. Additional metrics include root mean squared error, correlation, and variance explained.

To distinguish structured inference from direct recall, the analysis includes:

- Feature-removal ablations  
- Counterfactual perturbations of inputs  
- Cross-model comparisons exploiting differences in training cut-off dates  
- Analysis of error heterogeneity by GDP per capita and internet penetration  

Identification relies on the joint pattern across these tests rather than any single diagnostic. Additional robustness analyses include repeating the evaluation across an extended set of 24 alternative pluralistic ignorance variables drawn from prior studies and constructed from the same survey, using the original question wordings implemented verbatim.

---

## Repository structure
```
prompts/
├── system_prompt.txt
└── user_prompt_stage8.txt

notebooks/
├── 1_gen_data_country_fixed.ipynb
├── 2_llm_inference_country.ipynb
├── 3_analysis_llm_predictions.ipynb
├── 4_visualisations.ipynb
├── 5_ml_analysis.ipynb
├── 6_internet_usage_regressions.ipynb
├── 7_PI_ranking_analysis.ipynb
├── 8_GDP_regressions.ipynb
├── 9_Llama_and_Claude_robustness.ipynb
├── 10_error_pattern_analysis.ipynb
├── 11_case_study_analysis.ipynb
├── 12_ablation_original_study.ipynb
├── 13_ablation_structured_study.ipynb
├── 14_visualise_ablation_studies.ipynb
├── 15_testing_other_PIs.ipynb
├── 16_visualise_24_PIs.ipynb
├── 17_world_map_MAEs.ipynb
└── 18_generate_publication_figures.ipynb

figures/
└── (generated outputs)

README.md
```

**Note:** Not all notebooks generate results reported in the final manuscript. Some are exploratory or used for robustness and supplementary analyses.

Not all notebooks generate results reported in the final manuscript. Some are exploratory or used for robustness and supplementary analyses.

---

## Reproducibility and data access

Notebooks are numbered and intended to be run sequentially. Intermediate datasets and predictions are saved at each stage to ensure traceability.

Due to data-use restrictions associated with the Gallup World Poll, raw survey microdata are not redistributed. Scripts assume access to the relevant licensed data.

---

## Notes on data exposure

The GCCS paper reports aggregates and visualisations but does not provide full country-level tables or fixed rankings of perceived norms or pluralistic ignorance. The accompanying website generates country-level values dynamically through user interaction and does not present static country rankings.

Screenshots documenting this interaction-dependent structure are included in the Supplementary Materials.

---

## Contact and issues

For questions or comments, please contact nick.powdthavee@ntu.edu.sg. 
