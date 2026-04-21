# StoryTailor — Evaluation Results

All CSVs and JSONL in this directory are produced by the two evaluation runners under
`app/evals/`:

- **Automated script-based evaluation** — `uv run python -m app.evals.run_automated`
- **LLM-as-judge evaluation**          — `uv run python -m app.evals.run_llm_judge`

Once both have run, aggregate summaries can be built with:

- `uv run python -m app.evals.summarize`

---

## Files

### Raw outputs (one row per trial / scoring call)

| File | Produced by | Rows | Description |
|------|-------------|------|-------------|
| `generated_stories.jsonl` | `run_automated` | 1 line / trial | Full story text + trial metadata. Consumed by the LLM-judge runner. |
| `automated_results.csv`   | `run_automated` | 1 / trial      | All automated metrics M1–M13, M18. See header for exact columns. |
| `llm_rubric_results.csv`  | `run_llm_judge` | 1 / (trial, run_idx) | GPT-4o 1–5 scores on 8 rubric dimensions (D1–D8). |
| `llm_pairwise_results.csv`| `run_llm_judge` | 1 / pair_id    | Baseline-vs-full pairwise winners on D1, D2, D4, D5 (with A/B randomised). |

### Aggregate summaries

| File | Description |
|------|-------------|
| `summary_automated.csv`         | Headline pass-rates per condition, with Δ (full − baseline). |
| `summary_automated_by_age.csv`  | Same pass-rates sliced by age band (6 / 8 / 10). |
| `summary_automated_by_mood.csv` | Pass-rates sliced by mood (happy / sad / scared). |
| `summary_rubric.csv`            | Mean 1–5 rubric score per dimension per condition. |
| `summary_pairwise.csv`          | Win / tie / loss % per dimension (full vs baseline). |

---

## Trial identifiers

`trial_id` format: `A{age:02}_M{mood}_L{location}_G{goal}_S{seed}_C{condition}`
e.g. `A08_Mhappy_Lpark_Gempathy_S42_Cfull`

`pair_id` is the same prefix **without** the condition suffix — the baseline twin
and the full twin share a `pair_id`, which is what the LLM pairwise protocol uses
to compare them.

## Grid

```
age       ∈ {6, 8, 10}                        # 3
mood      ∈ {happy, sad, scared}              # 3
location  ∈ {park, school}                    # 2
goal      ∈ {empathy, persistence}            # 2
seed      ∈ {42, 1337}                        # 2
condition ∈ {baseline, full}                  # 2
————————————————————————————————————————————————
total                                         # = 144 trials, 72 pair_ids
```

## Models

- **Generator:** OpenAI `gpt-4o-mini`, temperature 0.7.
- **LLM judge:** OpenAI `gpt-4o`, temperature 0.0, `response_format=json_object`.

Generator ≠ judge model family is intentional: it reduces same-model
favouritism in the rubric and pairwise protocols.

## Baseline vs. full

- **baseline:** one call to `gpt-4o-mini` with the full system prompt — no
  validator, no refinement.
- **full:** the production `/api/generate_story` path — one initial generation
  plus up to 3 evaluator-guided refinement iterations (Generate–Validate–Refine).
  The `attempts` column records how many model calls were actually used for
  that trial.
