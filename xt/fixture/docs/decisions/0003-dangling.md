---
title: A supersedes link with nothing coming back
state: proposed
author: fixture
date: 2026-09-20
supersedes: [0002]
superseded-by: []
---

# 0003: A supersedes link with nothing coming back

Deliberately broken fixture decision. It declares `supersedes: [0002]`, and
0002 declares no `superseded-by` pointing here, so the link-symmetry check must
report the missing return link.

The obligation is meant to be discharged mechanically rather than by discipline,
which is only true while the check that discharges it still runs. This file is
how the runner proves that one still does.

It stays `proposed` so that the accepted-on-a-proposed-footing check has nothing
to say about it — each fixture defect answers for exactly one check, so a line
missing from `xt/fixture/expected` names which check went quiet.

Do not repair it. It is the fixture.
