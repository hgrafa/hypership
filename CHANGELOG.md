# Changelog

## [1.0.0] - 2026-03-23

### Added

- `/delivery` command — orchestrates feature delivery with Phase 0 classification (feature/bugfix/chore/mixed/overloaded), testing gates, and Superpowers/Ralph Loop pipeline selection
- `/removedebt` command — analyzes and removes technical debt with safety gates (snapshot, escape hatch, hard stop with delta)
- `/status` command — shows delivery cycle health
- Bug-as-Test gate — reproduces bugs as failing tests before fixing; 3 fallback strategies for non-reproducible bugs
- Acceptance Coverage gate — validates tests map 1:1 to acceptance criteria from brainstorm
- Safety gates for removedebt — snapshot baseline, immutable escape hatch, hard stop after each debt category
- `debt-scanner` subagent — analyzes git diffs for 6 debt categories
- `delivery-cycle-check` hook — suggests `/removedebt` after 5+ features
- Session-start hook with strict/suggestive mode context injection
- `hypership.config.json` with `strictDeliveryFramework` toggle
- Cross-platform hook support (Windows + Unix)
