---
name: inner-prompt
description: Template for the Ralph Loop prompt used by crochet:execute — filled with issue data at runtime
---

# Inner Loop Prompt Template

This template is filled by `crochet:execute` with data from the current issue.
Variables are marked with `{{double braces}}`.

---

Execute issue {{issue_id}}: {{issue_title}}

## Acceptance Criteria

{{acceptance_criteria}}

## Context Files

{{context_paths}}

## Review Findings to Address

{{review_findings}}

## Instructions

1. Run `git zhi issue show {{issue_id}}` to read the full issue
2. Check `git log --oneline -10` and `git diff` for work from previous iterations
3. If review findings exist above, address those first before new work
4. Follow TDD strictly:
   a. Write a failing test that exercises the next uncovered AC item
   b. Run the test — confirm it fails for the right reason
   c. Write the minimum implementation to make it pass
   d. Run all tests — confirm green
5. After tests pass, run: /simplify
6. If simplifier finds issues, fix them and re-run tests
7. Commit with a descriptive message — every iteration must leave committed state
8. Never squash or amend — the commit history is the iteration history
9. Move to the next AC item

## Completion

When ALL of the following are true:
- Every acceptance criterion is covered by at least one test
- All review findings (if any) have been addressed
- All tests pass
- /simplify produces zero findings
- Changes are committed

Then output: ISSUE_COMPLETE
