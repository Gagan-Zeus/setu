---
name: critic
description: "Hard critique pass on a written deliverable — hackathon/submission copy, README, docs, a pitch, a plan, a design rationale, a PR description. Leads with the framing risk that costs the reader's trust, then buried ledes, unearned claims, contradictions with the repo, and what to cut. Use when the user asks to critique, tear apart, poke holes in, or get honest feedback on writing or a plan, or invokes /critic by name. For defects in code, use /code-review instead."
---

# Critic

A critique is worth the reader's time only if it changes the draft. Ranked
findings that each imply an edit — not an appraisal, not a grade, not praise
with three soft suggestions at the end.

## Scope

Prose and plans: submission copy, READMEs, docs, pitches, PR descriptions,
design rationales, proposals. Code defects belong to `/code-review`; if the
draft is mostly code, say so and hand it over.

If the target is ambiguous, pick the most recently produced or discussed
deliverable and name it in the first line so a wrong guess is cheap to correct.

## Read the sources first

Never critique a draft about a codebase from the draft alone. Before writing
anything, spend real effort establishing ground truth:

- Read the code, schema, config and tests the draft describes.
- Read the commit history. Commit bodies record what actually broke and what
  the fix was; they are the cheapest source of both accuracy and material.
- Look for assets the draft failed to claim — tests, migrations, verification
  notes, benchmarks. A missing asset is a finding, and usually a better one
  than any wording complaint.

Every claim you make about the draft being wrong must be checkable against
something you read. Cite the file.

## The passes, in order

Run all of them. Report them ranked by what changes the reader's decision, not
in this order.

1. **Framing risk.** How does this land on a skeptical reader at their worst
   moment — tired, skimming, looking for a reason to stop? The most valuable
   finding is usually not an error but a true thing arranged so it works
   against the author. Say so plainly and give the reframing.
2. **Buried lede.** What is the single most distinctive thing here, and how far
   down is it? If the best idea is in section four, that is a finding.
3. **Unearned claims.** Anything asserted that the sources do not support:
   invented numbers, "production" for something with no users, features
   described as done that are stubs, adjectives doing an argument's work. Also
   flag claims that are *true but unverifiable by the reader*, and say what
   evidence would make them land.
4. **Scope drift.** Does each section answer the question it is under? A
   feature tour filed under "the problem" is drift, however well written.
5. **Contradictions.** Between the draft and the repo, and between sections of
   the draft. A stale README that a reader can open and compare is a live
   liability — name the file and the line.
6. **Length and the cut list.** Name the specific sections to cut and the ones
   to keep, with a reason for each. "Shorten it" is not a finding; "cut 3 and
   6, keep 2, 4, 5 because that is where the hard thinking shows" is.

## Output

Prose with headers, not a table. Structure:

- **One line naming what you reviewed**, so a wrong target is caught instantly.
- **The headline risk**, first, in a short paragraph. If the draft is
  fundamentally sound, say that in one sentence and move on — do not inflate.
- **Per-area findings**, each: what is wrong, why it costs the author, and the
  concrete fix. Bullets, one finding each, most damaging first.
- **Accuracy flags**, separated from the craft notes. A reader must be able to
  tell "this sentence is false" from "this sentence is weak".
- **What I'd actually do**, closing: the specific restructure, in two or three
  sentences, plus an offer to apply it.

## Rules

- No praise padding. No "great work overall, but". Open on the most useful
  thing. Strengths get mentioned only where the author is *underselling* one —
  that is an actionable finding; a compliment is not.
- Be specific enough to act on without rereading the draft. Quote the phrase.
- Separate taste from defect. When it is taste, say "this is taste" and give
  the reasoning so it can be overruled.
- Argue for the reader of the draft, not for your own preferences. The question
  is always what a judge, reviewer, or maintainer does with this — not what you
  would have written.
- Criticize the draft, never the author, and skip the apology for being harsh.
- Do not rewrite unless asked. End by offering it.
