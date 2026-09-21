---
title: A decision citing a line number
state: proposed
author: fixture
date: 2026-09-20
supersedes: []
superseded-by: []
---

# 0004: A decision citing a line number

Deliberately broken fixture decision. It cites `graph.go:439` below, which is a
file and a line rather than a symbol, so the cite-symbols check must report it.

> The behaviour is in `graph.go:439`, where the head is resolved for an actor.

A line number decays the moment anything shifts above it, and decays silently,
because nothing reads a decision at build time. A citation into another
repository cannot be checked from here at all. That is why the rule exists and
why this file exists to prove the rule is still enforced.

Do not repair it. It is the fixture.
