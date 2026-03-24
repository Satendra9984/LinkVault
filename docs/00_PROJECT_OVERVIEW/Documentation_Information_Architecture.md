# LinkVault Documentation Information Architecture

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active  
Owner: Engineering + Product  
Depends On: `docs/README.md`, `docs/00_PROJECT_OVERVIEW/Documentation_Audit_and_Source_of_Truth_Matrix.md`

---

## Objective

Define how LinkVault documentation is structured, owned, versioned, and maintained so every implementation-critical question has one authoritative answer.

---

## Structure Contracts

### Level-1 Sections

| Folder | Scope | Must Contain |
|---|---|---|
| `00_PROJECT_OVERVIEW` | strategic context and planning | roadmap, source-of-truth matrix |
| `01_PRODUCT` | product requirements and scope | PRD, feature matrix |
| `02_DESIGN` | UX/system design guidance | interaction contracts, UX principles |
| `03_ARCHITECTURE` | code architecture and boundaries | architecture spec, developer rules |
| `04_DATA_AND_MIGRATION` | schema/sync/migration | SQL spec, state machine, migration runbooks |
| `05_MONETIZATION` | pricing and entitlements | RevenueCat/AdMob flows |
| `06_ANALYTICS` | event model and KPI definitions | analytics specification |
| `07_SECURITY_AND_COMPLIANCE` | controls and obligations | security runbook, data governance |
| `08_TESTING_AND_QUALITY` | validation strategy and gates | testing strategy, quality criteria |
| `09_RELEASE_AND_OPERATIONS` | release and production operations | rollout, incident, rollback runbooks |
| `10_DECISIONS_AND_RISKS` | governance and program control | ADRs, risk register, readiness report |

### File Naming Rules

- Use `Title_Case_With_Underscores.md` for formal specs.
- Use stable nouns over sprint dates for enduring docs.
- Avoid duplicate terms across files unless scoped by folder.
- Do not include temporary words in canonical file names (`new`, `latest`, `final2`).

---

## Source-of-Truth Mapping Rules

1. Every topic must have exactly one canonical owner doc.
2. Secondary docs can elaborate but cannot redefine contracts from owner docs.
3. Conflicts are resolved by:
   - ADR decisions first
   - then owner doc in source-of-truth matrix
   - then section README guidance
4. Curate documentation can inspire implementation but cannot override LinkVault canonical docs.

---

## Document Quality Bar

A document is considered execution-ready when it has:

- clear scope and non-scope
- explicit dependencies and upstream/downstream effects
- implementation contracts (interfaces, schema, API shape, state transitions)
- failure modes and mitigation steps
- validation criteria (tests/checkpoints)

---

## Change Management

### Minor Update

- typo fixes
- clarifications that do not alter behavior
- examples and wording improvements

Action: update date only.

### Major Update

- behavior change
- schema modification
- architecture boundary change
- security/compliance impact

Action:
1. create or update ADR in `10_DECISIONS_AND_RISKS`
2. update dependent docs
3. update version and date
4. update readiness report if scope is affected

---

## Review Cadence

| Document Type | Cadence |
|---|---|
| Architecture/Data/Security | every major milestone or schema change |
| Product/Monetization | at sprint boundary and before release |
| QA/Operations | before beta and before production rollout |
| ADRs/Risk Register | whenever a new high-impact decision is made |

---

## Ownership and Escalation

- Product-owner disputes: resolved by Product Lead + Engineering Lead.
- Architecture/data disputes: resolved via ADR decision process.
- Security/compliance conflicts: security constraints override feature scope.

---

## Definition of Healthy Documentation System

- No critical topic requires reading multiple conflicting docs.
- Every new engineer can derive implementation sequence from docs alone.
- Major incidents can be handled using documented runbooks without ad hoc decisions.
