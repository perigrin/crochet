---
title: The amending decision, accepted too early
state: accepted
author: fixture
date: 2026-09-20
supersedes: []
superseded-by: []
amends: [0001]
---

# 0002: The amending decision, accepted too early

Broken on purpose, and it is the half that is wrong. This entry is `accepted`
while 0001 — which it amends — is still `proposed`.

Nothing about this document is malformed: its frontmatter is complete and its
`amends`/`amended-by` pair is symmetric. The defect is only in the relation
between the two states, which is what makes it the right shape for proving the
check fires for its own reason rather than on a parse error.
