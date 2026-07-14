# Reproducibility Guide

## *Can large language models predict public perceptions of support for climate action across 125 countries?*

This guide reconstructs the computational workflow from the 25 notebooks in `Archive.zip` and maps it to the revised manuscript figure sequence after the former resource-gradient Figure 2 was removed from the paper. That analysis is retained below only as a referee-response figure.

## 1. What the supplied archive can and cannot reproduce

The archive contains the analysis notebooks, but **does not contain the required source CSV files, saved LLM responses, map data, or website screenshots**. A clean end-to-end rerun therefore requires the missing inputs listed below.

There are two practical modes of reproduction:

1. **Exact-result reproduction**: use the original saved prediction CSV files and rerun only analysis/plotting notebooks. This is the preferred mode because commercial model endpoints and outputs can change over time.
2. **Fresh API reproduction**: regenerate all LLM predictions using the model IDs and prompts in the notebooks. This tests the procedure, but it may not reproduce the paper's exact numerical values if a provider has changed or retired a model.

For minimal path editing, place all notebooks and all data/output files in a **single project directory**. Most notebooks use hard-coded relative filenames rather than `data/` and `figures/` subdirectories.

---

## 2. Canonical notebooks

Use the following notebooks as the current source of truth:

| Role | Notebook |
|---|---|
| Build the eight prompt stages | `1. gen_data_country_fixed.ipynb` |
| Collect the four main-model predictions | `2. llm_inference_country.ipynb` |
| Internet-error analysis for referee-response figure | `6. internet usage regressions.ipynb` |
| Stage-8 scatterplots | `7. PI ranking analysis.ipynb` |
| GDP-error analysis for referee-response figure | `8. GDP regressions.ipynb` |
| Natural-language ablations and counterfactuals | `12. Ablation original study.ipynb` |
| Structured-prompt ablations | `13. Ablation structured study.ipynb` |
| Ablation visualisation for Supplementary Fig. S4 | `14. visualise ablation studies.ipynb` |
| U.S. policy generalisation data collection | `15. Testing other PIs (robustness checks).ipynb` |
| U.S. policy generalisation figure | `16. visualist 24 PIs.ipynb` |
| Supplementary Fig. S4 and referee-response figure assembly | `18. Gen figures for publication.ipynb` |
| Complete-data OLS/Lasso robustness | `19. Robustness check with N=112.ipynb` |
| Memorisation checks | `21_memorisation_robustness_checks.ipynb` |
| Corrected maps and revised Figure 1 | `22. Fix_Crimea_map_and_recreate_Fig1-3.ipynb` |
| Revised Figures 2–4 | `23. Revision_diagnostics_value_add_and_resource_gradient-3.ipynb` |
| Zero-shot cascade and Figure 5 | `24. Cascade_first_order_prediction.ipynb` |
| DeepSeek extension and Fig. S8 | `25. DeepSeek_stage1-8_extension.ipynb` |

Do not use these as the final source for the current paper:

- `3. analysis llm predictions.ipynb`
- `4. visualisations.ipynb` — legacy stage-trajectory figure, superseded by Notebook 23
- `5. ml analysis.ipynb` — superseded benchmark
- `9. Llama and Claude robustness checking.ipynb`
- `10. error pattern analysis.ipynb`
- `11. case study analysis.ipynb`
- `17. Create world map of MAEs.ipynb` — superseded by Notebook 22
- `20. Produce OLS coefficient plots.ipynb` — does not reproduce manuscript Table 1

---

## 3. Software environment

The notebooks do not record a fully pinned environment. A compatible environment should contain:

```text
jupyterlab
pandas
numpy
scipy
scikit-learn
statsmodels
matplotlib
seaborn
adjustText
geopandas
shapely
requests
PyMuPDF
Pillow
openai
anthropic
google-generativeai
together
```

Example setup:

```bash
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
python -m pip install --upgrade pip
python -m pip install \
  jupyterlab pandas numpy scipy scikit-learn statsmodels \
  matplotlib seaborn adjustText geopandas shapely requests \
  pymupdf pillow openai anthropic google-generativeai together
jupyter lab
```

After the first successful clean run, freeze the environment:

```bash
python -m pip freeze > requirements-lock.txt
```

### API environment variables

The notebooks expect some or all of:

```bash
export OPENAI_API_KEY='...'
export CLAUDE_API_KEY='...'
export ANTHROPIC_API_KEY='...'     # Notebook 24 also accepts this name
export GEMINI_API_KEY='...'
export GOOGLE_API_KEY='...'        # Notebook 21 uses this name for Gemini
export LLAMA_API_KEY='...'         # Together AI
export DEEPSEEK_API_KEY='...'
```

### Model identifiers encoded in the notebooks

Main study:

```text
GPT:     gpt-4o-mini
Claude:  claude-3-5-haiku-20241022
Gemini:  gemini-2.5-flash
Llama:   meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8
```

Additional analyses:

```text
Cascade:     claude-haiku-4-5-20251001
Recall test: claude-haiku-4-5-20251001
             meta-llama/Llama-3.3-70B-Instruct-Turbo
DeepSeek:    deepseek-chat
```

Use the original saved predictions whenever possible. If any exact model identifier is unavailable, record the replacement model, date, provider, decoding settings, and resulting deviations rather than silently substituting it.

---

## 4. Required input files

### 4.1 `data_final.csv`

Notebook 1 expects **125 countries and 17 columns**:

```text
countrynew
mean_age
mean_gender
mean_edu
mean_religion
mean_own_willingness
mean_own_willigness_less
mean_other_willingness
wtc_own
wtc_other
hdi_2021
gdp_capita_2021
top1pct_income
top1pct_wealth
temp_mean_2010_2019
other_fight_cc
govt_fight_cc
```

The spelling `mean_own_willigness_less` is intentional in the supplied data/notebooks. Notebook 1 accepts either that spelling or `mean_own_willingness_less`.

### 4.2 `matched_internet_usage.csv`

Required by Notebooks 6 and 23. It must contain:

```text
Country Name
internet_usage
```

`Country Name` is renamed to `countrynew` inside the notebooks.

### 4.3 `pi_effects_llms.csv`

Required by Notebook 15. It should contain 24 rows and at least:

```text
qnum
perceived norm
type of PI
```

The 24 exact prompts are hard-coded in Notebook 15.

### 4.4 Files derived from the core data

`country_names.csv` is required by Notebook 21 but is not created by Notebook 1. Create it with:

```python
import pandas as pd

df = pd.read_csv("data_final.csv")
df[["countrynew"]].drop_duplicates().to_csv("country_names.csv", index=False)
```

`comprehensive_data_for_mapping.csv` is required by Notebook 22 but is not created by another supplied notebook. Create it after Notebook 2:

```python
import pandas as pd


def pct(s):
    s = pd.to_numeric(s, errors="coerce")
    return s * 100 if s.max(skipna=True) <= 1.5 else s


gt = pd.read_csv("data_final.csv")
pred = pd.read_csv("predictions_all_stages_long.csv")
p8 = pred.loc[pred["stage"] == 8].copy()
p8 = p8.groupby("countrynew", as_index=False)[
    ["pred_gpt", "pred_claude", "pred_gemini", "pred_llama"]
].mean()

m = gt.merge(p8, on="countrynew", how="inner")
own = pct(m["mean_own_willingness"])
other = pct(m["mean_other_willingness"])

mapping = pd.DataFrame({
    "countrynew": m["countrynew"],
    # The mapping notebooks use perceived minus personal willingness,
    # so underestimation appears as a negative gap.
    "pi_actual": other - own,
    "pi_pred_gpt": m["pred_gpt"] - own,
    "pi_pred_claude": m["pred_claude"] - own,
    "pi_pred_gemini": m["pred_gemini"] - own,
    "pi_pred_llama": m["pred_llama"] - own,
})
mapping.to_csv("comprehensive_data_for_mapping.csv", index=False)
```

### 4.5 Supplementary Figure S7

S7 uses manually captured screenshots from the GCCS maps and rankings pages. Those images are not produced by any supplied notebook. Preserve the original screenshots, capture date, page URL, and browser/window dimensions.

---

## 5. Preflight checks

Run these checks before any API calls:

```python
import os
import pandas as pd

required = ["data_final.csv"]
for f in required:
    assert os.path.exists(f), f"Missing {f}"

df = pd.read_csv("data_final.csv")
assert len(df) == 125
assert df["countrynew"].nunique() == 125
assert df["mean_other_willingness"].notna().sum() == 125
assert df["mean_own_willingness"].notna().sum() == 125
print("Core data preflight passed")
```

After Notebook 2:

```python
p = pd.read_csv("predictions_all_stages_long.csv")
assert set(p["stage"].dropna().astype(int)) == set(range(1, 9))
assert p[["countrynew", "stage"]].drop_duplicates().shape[0] == 125 * 8
for c in ["pred_gpt", "pred_claude", "pred_gemini", "pred_llama"]:
    assert p[c].between(0, 100).all(), c
print("Main prediction preflight passed")
```

Do not proceed if there are duplicate country-stage rows, missing countries, or predictions outside 0–100.

---

## 6. End-to-end execution order

### Phase A — Core prompts and main LLM predictions

#### Step 1: Build prompts

Run:

```text
1. gen_data_country_fixed.ipynb
```

Input:

```text
data_final.csv
```

Primary output:

```text
country_llm_prompts_outcome2_8stages.csv
```

The file should contain 125 rows and `prompt_stage1` through `prompt_stage8`.

#### Step 2: Generate main-model predictions

Run:

```text
2. llm_inference_country.ipynb
```

Important: Notebook 2 contains two near-duplicate implementations. Run **one complete implementation only**. Prefer the later implementation because it contains the resume/checkpoint logic. Do not execute both full collection cells, or the API calls may be duplicated and later outputs may overwrite earlier ones.

Primary outputs:

```text
predictions_S1_country.csv
...
predictions_S8_country.csv
predictions_all_stages_long.csv
predictions_all_stages_wide.csv
```

Immediately archive these files with a timestamp and checksums. They are the central computational record for the paper.

Expected Stage-8 sanity values from the saved notebook outputs:

| Model | MAE (p.p.) | Pearson r |
|---|---:|---:|
| GPT-4o mini | 13.60 | 0.704 |
| Claude 3.5 Haiku | 5.06 | 0.508 |
| Gemini 2.5 Flash | 14.92 | 0.699 |
| Llama 4 Maverick | 6.83 | 0.548 |

Small graphical or rounding differences are acceptable. Materially different results usually indicate model drift, a scale problem, a changed prompt, or incomplete API collection.

#### Step 3: Create derived helper files

Create:

```text
country_names.csv
comprehensive_data_for_mapping.csv
```

using the code in Section 4.4.

---

### Phase B — Main figures

## Figure 1: Global maps, scatterplots, and OLS/Lasso benchmark

Run in this order:

1. `7. PI ranking analysis.ipynb`
   - retain the Stage-8 scatterplot output:
   - `pi_stage8_scatter_actual_vs_predicted.pdf`
2. `22. Fix_Crimea_map_and_recreate_Fig1-3.ipynb`
   - run Sections 1–8
   - downloads Natural Earth 50m data
   - applies the Crimea/Ukraine geometry patch
   - reconstructs the OLS/Lasso benchmark
   - assembles the final Figure 1

Expected outputs:

```text
map_pi_ground_truth.pdf
map_pi_claude.pdf
map_pi_llama.pdf
map_pi_gpt.pdf
map_pi_gemini.pdf
Fig_maps_2x2_VECTOR.pdf
ml_comparison_llm_vs_ols_vs_lasso_simplified.pdf
Fig_ABCD_2x2_BALANCED_VECTOR.pdf
Fig_ABCD_2x2_BALANCED_600dpi.png
```

### Required patch in Notebook 22

The source data uses:

```text
temp_mean_2010_2019
```

but Notebook 22 refers to:

```text
mean_temp_2010_2019
```

in its OLS/Lasso feature lists. As written, temperature is silently omitted. Replace both occurrences of `mean_temp_2010_2019` with `temp_mean_2010_2019` before running the benchmark.

The benchmark uses 10 stratified 80:20 train-test splits with seeds 42–51 and standardises predictors within each split.

## Figure 2: MAE and Pearson correlation by information stage

Run:

```text
23. Revision_diagnostics_value_add_and_resource_gradient-3.ipynb
```

Required sections/cells:

- Section 1: load and merge
- Section 15: publication-ready stage-trajectory figure (labelled Figure 3 inside the notebook)
- code cells 53–54 in the supplied notebook

Inputs:

```text
predictions_all_stages_long.csv
data_final.csv
```

Outputs:

```text
fig3_revised_data.csv
fig3_revised.pdf
```

These output filenames retain the former manuscript numbering; `fig3_revised.pdf` is now manuscript **Figure 2**. The bootstrap uses 3,000 resamples and seed 42.

## Figure 3: Feature-removal ablations

1. Run the collection portion of:

```text
12. Ablation original study.ipynb
```

This produces:

```text
ablation_revised_raw_results.csv
```

Conditions:

```text
full
no_econ
no_religion
no_demo
no_climate
no_own_willingness
country_only
cf_gdp_flip
cf_name_mismatch
cf_willingness_flip
```

2. Run Notebook 23, Section 16 (code cells 56–57).

Outputs:

```text
fig4_revised_data.csv
fig4_revised.pdf
```

These filenames retain the former numbering; `fig4_revised.pdf` is now manuscript **Figure 3**.

## Figure 4: Counterfactual robustness tests

Use the same `ablation_revised_raw_results.csv` from Notebook 12, then run Notebook 23, Section 17 (code cells 60–61).

Output:

```text
fig5_counterfactual_combined.pdf
```

The filename retains the former numbering; this file is now manuscript **Figure 4**.

The figure compares changes in MAE and Pearson correlation for:

```text
cf_willingness_flip
cf_name_mismatch
cf_gdp_flip
```

The confidence intervals use 3,000 bootstrap resamples and seed 42.

## Figure 5: Zero-shot first-order cascade

Run all substantive sections of:

```text
24. Cascade_first_order_prediction.ipynb
```

Before collection, inspect:

```python
DRY_RUN = False
```

The markdown says the notebook defaults to dry-run, but the supplied code currently sets it to `False`. Set the value deliberately and record it.

Run in this order:

1. Stage A: predict first-order willingness from Stage-7 country information
2. Stage B: feed that predicted first-order value into second-order prediction
3. Stage 5-real: same Claude model with real first-order willingness
4. Combine and evaluate
5. Run the scale-fix cell in Section 6b
6. Run the 5,000-resample bootstrap in Section 6c
7. Create the cascade figure (now manuscript Figure 5)

Outputs:

```text
cascade_stageA_predictions.csv
cascade_stageB_predictions.csv
cascade_stage5real_predictions.csv
cascade_combined_results.csv
fig6_cascade_validation.pdf
```

The output filename retains the former numbering; `fig6_cascade_validation.pdf` is now manuscript **Figure 5**.

Expected validation values:

| Analysis | MAE | Pearson r |
|---|---:|---:|
| Stage A, zero-shot first-order | 34.73 | -0.054 |
| Stage 5-real | 8.47 | 0.720 |
| Stage B, cascaded | 17.35 | -0.077 |

Expected paired differences, cascade minus real-input:

```text
Delta MAE = +8.88 p.p.
Delta r   = -0.797
```

Do not omit the Section 6b scale patch. It corrects `actual_own_willingness` to the same 0–100 scale as the model predictions.


## Referee-response figure: Internet penetration and GDP gradients

The former manuscript Figure 2 has been removed from the paper. Retain this workflow only to reproduce the figure reported in the response letter; it is **not part of the manuscript's numbered figure sequence**.

Run:

1. `6. internet usage regressions.ipynb`
2. `8. GDP regressions.ipynb`
3. the former Figure 2 assembly cell in `18. Gen figures for publication.ipynb`

Expected component files:

```text
internet_usage_aggregate_regression_clean.pdf
gdp_aggregate_regression_clean.pdf
```

Combined output:

```text
Figure3_1x2_VECTOR.pdf
Figure3_1x2_VECTOR_600dpi.png
```

The output filename is legacy. Notebooks 6 and 8 calculate each country's mean absolute error **averaged across all eight information stages**, then relate that average to internet penetration or GDP per capita. The response-letter caption should therefore describe the estimand as “MAE averaged across Stages 1–8,” not Stage-8 MAE.

Notebook 23, Section 5, compares the pooled and Stage-8 gradients and may be used to explain why this analysis was removed from the reframed manuscript.

---

## 7. Main table

### Table 1: OLS regressions of actual and predicted second-order beliefs

No supplied notebook exactly reproduces the manuscript's Table 1.

`20. Produce OLS coefficient plots.ipynb` converts predictors to categories and produces coefficient plots. The manuscript table instead reports continuous, standardised predictors and robust standard errors.

For full reproducibility, add a dedicated script/notebook that:

1. selects Stage-8 predictions;
2. merges them with `data_final.csv`;
3. converts actual second-order willingness to 0–100;
4. standardises the dependent and independent variables;
5. estimates separate OLS models for Actual, GPT, Claude, Gemini, and Llama;
6. uses heteroskedasticity-robust standard errors;
7. exports coefficients, SEs, N, R², and adjusted R².

The explanatory variables should be:

```text
mean_own_willingness
mean_age
mean_edu
mean_religion
hdi_2021
gdp_capita_2021
top1pct_income
temp_mean_2010_2019
```

The manuscript table does not include top-1% wealth share, even though that variable appears in the prompts.

Until this script is added, Table 1 is not independently reproducible from the supplied notebook set.

---

## 8. Supplementary figures

| Figure | Workflow | Output |
|---|---|---|
| **S1 Direct recall probe** | Notebook 21, Test 1 | `t1_recall_vs_stage8_figure.pdf` |
| **S2 Training-cutoff natural experiment** | Notebook 21, Test 3 | `t3_cutoff_figure.pdf` |
| **S3 Pre/post-publication comparison** | Not fully implemented; see below | — |
| **S4 Prompt-format robustness** | Notebooks 12, 13, 14, then relevant assembly cells in 18 | `Ablation_COMPARE_ORIGINAL_vs_CF_2x1.pdf`; `Fig_Structured_AB_2x1_VECTOR.pdf` |
| **S5 Complete-data benchmark** | Notebook 19 | `ml_comparison_llm_vs_ols_vs_lasso_noNA13.pdf` |
| **S6 U.S. policy generalisation** | Notebook 15 then 16 | `llm_prediction_accuracy.pdf` |
| **S7 GCCS website interfaces** | Manual screenshots | no notebook output |
| **S8 DeepSeek extension** | Notebook 25 | `fig_S_deepseek_staged_trajectory.pdf` |

### S1

Notebook 21 requires:

```text
country_names.csv
data_final.csv
predictions_S1_country.csv and predictions_S8_country.csv
or predictions_all_stages_long.csv
```

It creates `t1_recall_predictions.csv`, compares direct-recall predictions with Stages 1 and 8, and plots 10,000-resample bootstrap confidence intervals.

### S2

Notebook 21, Test 3 uses the existing Stage-8 MAEs and the hard-coded training cutoff dates. No new API calls are required.

### S3 reproducibility gap

The manuscript's S3 contains:

- three Claude versions; and
- two Llama versions.

Notebook 21's implemented Test 4 only creates a two-model Claude comparison. It does not create the full five-panel figure described in the manuscript.

To close the gap, add code that:

1. imports main-study Stage-8 Claude 3.5 and Llama 4 predictions;
2. runs or imports Stage-8 predictions for Claude 3 Haiku, Claude Haiku 4.5, and Llama 3.3 70B;
3. merges all five series with actual second-order beliefs;
4. creates the five scatterplots with a common 0–100 scale and diagonal reference line.

### S4

Run both API notebooks:

```text
12. Ablation original study.ipynb
13. Ablation structured study.ipynb
```

Then run Notebook 14 to create the natural-language and structured-prompt heatmaps and counterfactual panels. Finally, use the relevant assembly cells in Notebook 18.

### S5

Notebook 19 restricts the data to countries with complete values, uses 10 repeated 80:20 splits stratified by continent, and produces:

```text
ml_detailed_results_10iterations_noNA13.csv
ml_summary_comparison_noNA13.csv
ml_comparison_llm_vs_ols_vs_lasso_noNA13.pdf
```

Check the manuscript's stated complete-case N against the actual number printed by the notebook; filenames refer to “noNA13” while the manuscript caption describes 112 countries.

### S6

Notebook 15 collects predictions for 24 U.S. policy items and saves:

```text
pi_effects_llms_predictions.csv
```

Notebook 16 then creates:

```text
llm_mae_by_question.csv
llm_prediction_accuracy.pdf
```

Gemini is excluded from the plotted analysis because the saved run contains no Gemini predictions.

### S8

Notebook 25 makes 1,000 DeepSeek API calls for 125 countries × 8 stages, with checkpoint/resume support.

Primary outputs:

```text
deepseek_predictions_all_stages.csv
deepseek_staged_trajectory.csv
fig_S_deepseek_staged_trajectory.pdf
deepseek_recall_probe.csv
deepseek_bootstrap_cis.csv
```

Expected Stage-8 values:

```text
MAE = 12.68 p.p.
r   = 0.628
```

Caveat: Notebook 25 states that Stages 2–5 were reconstructed as extensions of the original prompt format rather than copied verbatim from Notebook 1. Preserve this qualification in the reproducibility statement.

---

## 9. Recommended run matrix

### Exact-results route, assuming saved API outputs are available

```text
1  (only if prompt archive is needed)
7
14
16
18 (S4 assembly cells only)
19
22
23 (Sections 15–17; manuscript Figures 2–4)
24 (analysis/plot cells only, if cascade CSVs are saved; manuscript Figure 5)
25 (analysis/plot cells only, if DeepSeek CSVs are saved)
```

For the referee-response resource-gradient figure only, additionally run Notebooks 6 and 8 and the corresponding assembly cell in Notebook 18.

### Full fresh-API route

```text
1 → 2
12 → 13
15
21
24
25
then
7 → 14 → 16 → 19 → 22 → 23 → 18 selected S4 assembly cells
```

For the referee-response resource-gradient figure only, run `6 → 8 → 18` after the main prediction files are available. Notebook 18 should generally be run **last**, because it only assembles component PDFs generated elsewhere.

---

## 10. File-level reproducibility record

For every API-generated CSV, store:

- notebook name and Git commit/hash;
- execution date and timezone;
- provider and exact model identifier;
- API/library version;
- system prompt and user prompt hash;
- temperature and other decoding parameters;
- number of attempts/retries;
- missing or failed calls;
- SHA-256 checksum of the final CSV.

Example:

```bash
sha256sum predictions_all_stages_long.csv \
  ablation_revised_raw_results.csv \
  ablation_structured_revised_raw_results.csv \
  pi_effects_llms_predictions.csv \
  cascade_combined_results.csv \
  deepseek_predictions_all_stages.csv \
  > checksums.sha256
```

Do not regenerate API outputs merely to redraw figures. Treat the original response files as raw data.

---

## 11. Final checklist

- [ ] `data_final.csv` has 125 unique countries and the expected columns.
- [ ] Notebook 1 creates eight prompts per country.
- [ ] Notebook 2 produces 1,000 unique country-stage rows.
- [ ] Main-model predictions are complete and constrained to 0–100.
- [ ] Raw prediction CSVs are archived before analysis.
- [ ] `country_names.csv` and `comprehensive_data_for_mapping.csv` are created.
- [ ] Notebook 22's temperature-column typo is corrected.
- [ ] Main figures are renumbered consistently: former Figures 3–6 are now Figures 2–5.
- [ ] Legacy output filenames (`fig3_...` through `fig6_...`) are mapped explicitly to manuscript Figures 2–5.
- [ ] The resource-gradient analysis is excluded from the manuscript and, if reproduced for the response letter, is captioned as MAE averaged across Stages 1–8.
- [ ] Notebook 24's scale-fix cell is run.
- [ ] Table 1 receives a dedicated continuous-predictor regression script.
- [ ] S3 receives a complete five-model/version plotting script.
- [ ] S7 screenshots and capture metadata are archived.
- [ ] All final PDFs are regenerated from clean kernels.
- [ ] Package versions, model IDs, run dates, and checksums are recorded.

