---
name: verify-contract
description: Check that the implementation's types, operations, routes and error codes match the spec's §3 contracts and §4.2 error modes exactly (and, in a consumer layer, the consumed provider spec's §3 at a named version), and that each is tested.
---

# Skill: verify-contract

**Use when:** before marking ACs `Verified`, during review, after refactors, and (consumer layers) whenever a consumed provider spec changes version.

## Steps

1. **Extract the contracts:**
   - From this spec: §3.1 types (fields, types, optionality, constraints), §3.2 operations (input, output, errors, auth, idempotency), §3.3 persistence (or, in a UI layer, routes and permissions), §3.4 compatibility (or UI states and form rules), and §4.2 error codes.
   - **Consumer layers:** from each provider spec in `<ProviderLayer> Specs`, §3.1 types and §3.2 operations (route, method, input, output, errors, auth) for the operations this spec uses. Note the provider spec **version** you checked against.
2. **Locate the implementation** under the paths in spec §2.1. Grep for each type, operation name, endpoint string and route. **A spec'd item with no implementation counts as a finding; never assume it exists.**
3. **Check each item:**
   - [ ] Name matches exactly
   - [ ] Every field is present, with no extra public fields
   - [ ] Types and optionality match; there are no implicit nulls
   - [ ] Constraints (length, range, regex, enum) are enforced at the boundary
   - [ ] Every listed error code is raised in its trigger condition, and no unlisted codes are raised
   - [ ] The auth requirement is enforced
   - [ ] Idempotency holds when claimed
   - [ ] Persistence keys, uniqueness, and indexes match §3.3
   - [ ] **Consumer layers:** field names match the provider's serialized names; optionality matches its nullability; enums use its values; every call's method, path, version and body match the provider operation and go through the feature's service / client; every provider error code in the spec has the spec'd behavior; IDs and opaque values are passed through untouched
4. **Check the tests:** every operation, error code, endpoint mapping and UI state has at least one test tagged with an AC (`<SPEC-ID>-AC-NN`).
5. **Use machine checks where the stack has them:** if the contracts exist as schemas (OpenAPI, JSON Schema, protobuf, generated clients), validate the implementation against them with the stack's tooling, and record the command in `.ai/project/commands.md`.
6. **Report:** `PASS` (with the provider spec versions checked, in a consumer layer), or a table of findings:

   | Spec item | Expected (spec) | Actual (code location) | Fix |
   |---|---|---|---|
