---
title: A link to a decision that was never written
state: proposed
author: fixture
date: 2026-09-21
supersedes: [0099]
superseded-by: []
---

# 0006: A link to a decision that was never written

Deliberately broken fixture decision. It declares `supersedes: [0099]`, and
there is no `0099-*.md`, so the link check must report a forward reference to a
decision that does not exist.

That note is a different site from the missing-back-link one 0003 covers: the
first says a target is absent, the second says a present target does not point
back. Both live in `link_check` and each needs its own witness, or one can be
deleted while the other keeps the output looking right.

It stays `proposed` so the accepted-on-a-proposed-footing check has nothing to
say about it.

Do not repair it. It is the fixture.
