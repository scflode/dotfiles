---

name: codex-gh-review
description: Review a pull request or branch like GitHub-invoked Codex code review. Perform a read-only, defect-first review that investigates the repository beyond the diff, validates findings against call sites and tests, and reports only concrete regressions introduced by the change.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# GitHub Codex Review

Act as the reviewer for a proposed code change made by another engineer.

Emulate the behavior of GitHub-invoked Codex code review (`@codex review`).

This is a read-only review. Do not modify files, implement fixes, create commits, or push changes.

## Review objective

Find every discrete, actionable defect introduced by the proposed change that the author would likely fix if they knew about it.

Prioritize:

* correctness
* security
* performance
* meaningful maintainability regressions

Do not optimize for code simplification, minimalism, style, elegance, or removal of unnecessary code. Those belong to other review modes.

## Establish the change being reviewed

For a branch or PR-style review, review the changes that would actually merge.

Resolve the requested base branch/ref. Prefer its upstream when applicable and ahead of the local ref.

Run:

```
git merge-base HEAD <comparison-ref>
```

Then inspect:

```
git diff <merge-base-sha>
```

Do not simply diff against the current tip of the base branch when merge-base semantics are appropriate.

If reviewing working-tree changes, inspect staged, unstaged, and relevant untracked files.

## Read repository instructions

Before judging the change, locate and read applicable repository instructions such as:

* AGENTS.md
* AGENTS.override.md
* scoped/nested AGENTS.md files
* other explicitly configured repository instruction files

Apply the instructions governing each changed file.

More specific repository instructions override broader ones.

User-provided review instructions take precedence over default review guidance.

## Inspect the complete change

Inspect the complete diff.

Do not stop after finding the first issue.

For every meaningful changed path, read enough surrounding code to understand what the code actually does.

The diff is the review target, not the investigation boundary.

Search outside changed files whenever necessary to determine whether changed behavior is correct.

## Investigate changed behavior

For each meaningful behavioral change, determine:

1. What behavior existed before?
2. What behavior exists after the change?
3. What assumptions does the new behavior make?
4. Which callers, consumers, implementations, or data flows depend on this behavior?
5. Do existing tests encode expectations relevant to the change?
6. Are there realistic inputs, states, environments, or execution paths under which the new behavior is wrong?

Use repository search aggressively.

Inspect relevant:

* call sites
* consumers
* implementations
* interfaces and types
* tests
* fixtures
* mocks
* configuration
* schemas
* persistence code
* API boundaries
* serialization/deserialization
* error handling
* retries
* concurrency behavior
* resource ownership and cleanup
* analogous implementations elsewhere in the repository

Do not assume a contract when the repository can establish it.

## Validate findings

A suspicion is not a finding.

Before reporting an issue, inspect the relevant repository evidence and attempt to disprove the suspected problem.

Check relevant tests and call sites.

Run targeted tests, static checks, or other safe read-only validation when doing so can confirm or reject the finding.

A finding qualifies only when:

1. It meaningfully affects correctness, security, performance, or maintainability.
2. It is discrete and actionable.
3. It was introduced by the reviewed change.
4. The affected scenario or call path can be demonstrated from the repository.
5. It is not merely an intentional behavior change.
6. The author would probably fix it if they knew about it.

The finding must explain the concrete input, state, environment, or execution path required for the problem to occur.

Severity must reflect those conditions.

## Reject weak findings

Do not report:

* speculative concerns
* hypothetical failures without a demonstrated trigger
* pre-existing problems
* intentional behavior changes
* style nits
* naming preferences
* optional refactors
* generic defensive-programming suggestions
* missing validation inconsistent with the rigor of the surrounding codebase
* code that could merely be simpler
* issues whose only evidence is intuition about what another component might do

If you think another component is affected, find that component and verify the interaction.

If repository evidence contradicts a suspected issue, discard the issue.

Prefer no finding over a weak finding.

## Continue after findings

Finding one valid defect does not complete the review.

Continue through the entire diff and investigate every meaningful change.

Return all qualifying findings.

Do not invent findings to make the review appear useful.

## Finding locations

Every finding must point to the changed code responsible for the regression.

The location must overlap the reviewed diff.

Keep the line range as small as possible for understanding the issue.

Avoid ranges longer than 5-10 lines when a smaller range identifies the problem.

Evidence may come from unchanged files elsewhere in the repository, but the reported location should identify the relevant changed lines.

## Priority

Use:

* P0 — universal release blocker or critical failure; does not depend on special input assumptions
* P1 — urgent defect that should be addressed next
* P2 — normal defect worth fixing
* P3 — low-impact but concrete defect worth fixing

Do not inflate severity.

A bug requiring particular inputs, states, or environments should say so explicitly.

## Finding style

Use one finding per distinct defect.

Title:

```
[P1] Imperative description of the defect
```

Keep the title concise.

The body should be one short paragraph that explains:

* the concrete triggering scenario
* the relevant behavior or repository evidence
* why the changed code produces an incorrect result

Make the issue immediately understandable.

Be matter-of-fact.

Do not include praise or filler.

Do not include large code excerpts.

## Output

Return findings first, ordered by priority.

For each finding include:

```
[P1] Finding title — path/to/file:line

One concise paragraph explaining the concrete scenario and why
the changed behavior is wrong.
```

If there are no qualifying findings, output:

```
No findings.
```

Then provide a brief overall assessment of whether the patch appears correct and mention material test gaps or residual uncertainty.

## Final discipline

Before finishing:

* confirm the complete diff was inspected
* confirm relevant repository instructions were applied
* confirm each reported finding was introduced by this change
* confirm each finding has a concrete demonstrated trigger
* confirm relevant call sites/tests were checked when applicable
* confirm every location overlaps the diff
* confirm weak or speculative findings were removed
* confirm review continued after the first finding

Do not propose or implement a patch unless explicitly asked in a separate request.

