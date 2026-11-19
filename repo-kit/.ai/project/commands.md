# Commands

> Filled by init-project (moved verbatim from an existing CLAUDE.md / AGENTS.md / README when present). Source of truth for this project (`.ai/ai.md` §6).
> Every command runs from this repo root. Record only commands verified in the manifest, scripts, Makefile or CI config.

## Build & Run

```bash
<build the whole repo>
<run the app locally>
```

## Testing

```bash
<run the full test suite>
<run the tests of one file / project>
<run the tests of one spec AC, by its tag <SPEC-ID>-AC-NN>
```

## Lint, format, type-check

```bash
<lint / format check on given files>
<type-check, if separate from the build>
```

## Database / migrations (if any)

```bash
<add a new migration>      # agents may add; applying is human-only or needs approval (.ai/hooks/policy.md)
```

## Specs

```bash
bash .ai/scripts/validate-specs.sh   # lint the KB for this layer
```
