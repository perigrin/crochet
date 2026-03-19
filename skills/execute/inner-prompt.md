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

## Instructions

1. Run `git zhi issue show {{issue_id}}` to read the full issue
2. Check `git log --oneline -10` and `git diff` for work from previous iterations
3. Follow TDD strictly:
   a. Write a failing test that exercises the next uncovered AC item
   b. Run the test — confirm it fails for the right reason
   c. Write the minimum implementation to make it pass
   d. Run all tests — confirm green
4. After tests pass, run: /simplify
5. If simplifier finds issues, fix them and re-run tests
6. Commit when tests pass AND simplifier is clean
7. Move to the next AC item

## Completion

When ALL of the following are true:
- Every acceptance criterion is covered by at least one test
- All tests pass
- /simplify produces zero findings
- Changes are committed

Then output: ISSUE_COMPLETE
