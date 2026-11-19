# Architecture

> Filled by init-project (moved verbatim from an existing CLAUDE.md / AGENTS.md / README when present). Source of truth for this project (`.ai/ai.md` §6).

## Architecture & Project Structure

### Core Organization Pattern

<How the code is organised: monolith / modular monolith / services / app + libraries; one folder or project per module and layer. Show the tree of one module.>

```
<Module>/
├── <layer folder>/     # <what it holds>
└── <tests folder>/     # <test framework>
```

### Layers and dependency direction

<The layers (e.g. domain, application, infrastructure, host / UI, state, services) and which may reference which. Rule 01 maps them onto its generic layers.>

### Entry point

<The host / app entry, composition root, routing.>

### Module registration flow

<How a new module or feature is wired in (DI registration, routes, solution entries). The add-module skill follows this section.>

### Cross-module communication

<Direct calls through a public API, messages / events, shared libraries. What is forbidden.>

### API / contract versioning

<How public contracts are versioned and kept compatible.>

### Testing Framework

<Framework, where tests live (colocated or a tests root), naming style, how a test is tagged with `<SPEC-ID>-AC-NN`, test doubles library.>

## Key Decision Points

<Choices that are fixed for this repo and need no re-decision in a spec (§2.4 cites this section instead).>
