---
stability: 1
covers: []
---

<!-- ABOUTME: Deliberately broken fixture doc — declares covers and names nothing. -->
<!-- ABOUTME: xt/run.sh must fail on this; it is how the runner proves it can fail. -->

# Broken On Purpose

This document declares a covers list and names nothing in it, so no sensor
watches it. `xt/run.sh` must report this file by name.

Do not repair it. It is the fixture.
