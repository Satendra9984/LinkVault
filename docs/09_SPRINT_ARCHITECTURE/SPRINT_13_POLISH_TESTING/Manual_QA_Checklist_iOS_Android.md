# Sprint 13 Manual QA Checklist (iOS + Android)

Use this short run on one modern iOS device and one modern Android device.

| ID | Area | Steps | Expected |
|---|---|---|---|
| S13-MAN-01 | Loading polish | Open Home, Collections, Search with cold app state and after pull-to-refresh | Skeleton shimmer-style placeholders appear instead of spinner-only states on key surfaces |
| S13-MAN-02 | Empty/error states | Trigger no-results in Search and root-links filters; simulate network failure where possible | Empty/error states use consistent copy + clear CTA (Retry/Clear) and stay readable in light/dark |
| S13-MAN-03 | Swipe animation | In links list mode, swipe row start->end and end->start | Swipe motion is smooth; action affordances remain clear; no clipped row artifacts |
| S13-MAN-04 | Navigation transitions | Navigate Home -> Collection -> Item detail/edit and back repeatedly | Push/pop transition feels smooth and consistent with platform behavior |
| S13-MAN-05 | Accessibility labels | Enable TalkBack/VoiceOver; focus search tabs, search fields, URL rows, profile sign-out, empty-state CTA | Controls announce meaningful labels/roles; URL rows announce title/domain/status/update context |
| S13-MAN-06 | Focus order | Traverse Search and Profile screens by keyboard/accessibility focus | Focus order is logical (top-down), no traps, actionable controls are reachable |
| S13-MAN-07 | Contrast sanity | Check key text/icons on app bars, chips, subtitles, empty cards in light and dark themes | Primary surfaces remain legible with no low-contrast critical labels |
| S13-MAN-08 | Tier behavior guard | Run guest/free/premium/day-pass flows for create/search/open actions | No behavior regression in gating/entitlement logic after polish changes |

## Exit criteria for Sprint 13 QA

- All checklist rows pass on both platforms, or failures are logged with screenshot + reproduction steps.
- Any failed row becomes explicit Sprint 14 carry-over item with owner.
