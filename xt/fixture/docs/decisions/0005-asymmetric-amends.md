---
title: An amends link with nothing coming back
state: proposed
author: fixture
date: 2026-09-21
supersedes: []
superseded-by: []
amends: [0004]
---

# 0005: An amends link with nothing coming back

Deliberately broken fixture decision. It declares `amends: [0004]`, and 0004
declares no `amended-by` pointing here, so the link-symmetry check must report
the missing return link **on its `amends`/`amended-by` invocation**.

`link_check` is called twice — once for `supersedes`/`superseded-by` and once
for `amends`/`amended-by` — and until this file existed only the first
invocation had a witness. 0003 covered that one; the second could have been
deleted, or its arguments typoed, with nothing noticing.

It stays `proposed` so the accepted-on-a-proposed-footing check has nothing to
say about it. 0004 stays `proposed` for the Implements check, and gains no
`amended-by`, which is the defect here.

Do not repair it. It is the fixture.
