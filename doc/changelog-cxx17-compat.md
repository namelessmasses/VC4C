# C++17 Compatibility Notes

Date: 2026-02-27

## Summary
This change set improves C++17 compatibility by removing ambiguous member-pointer shorthand on `Optional` and by avoiding deprecated type-trait usage in newer language modes.

## Why this was needed
- Some C++17 toolchains report ambiguous overload resolution for `Optional::operator&` when used with member-function pointers (for example `&Value::getLiteralValue`).
- `std::is_literal_type` is deprecated in C++17 and removed in C++20, which causes warnings/errors on newer compilers.

## What changed

### 1) Replaced ambiguous `Optional::operator&` member-pointer shorthand
In places where code previously used shorthand like:
- `val.getConstantValue() & &Value::getLiteralValue`

it now uses explicit optional unwrapping and member calls:
- `if(auto constantValue = val.getConstantValue()) { if(auto lit = constantValue->getLiteralValue()) ... }`

This preserves behavior while avoiding overload ambiguity in C++17.

Affected file:
- `src/intrinsics/WorkItems.cpp`

### 2) Replaced deprecated literal-type check in C++17+
`assert_literal` now gates trait selection by language version:
- pre-C++17: keeps `std::is_literal_type<T>::value`
- C++17+: uses `std::is_trivial<T>::value`

Both paths still require `assert_trivial<T>::value`.

Affected file:
- `src/concepts.h`

## Non-functional impact
- No intended runtime/semantic behavior change.
- Change is focused on build portability and diagnostics cleanliness for modern compilers.

## PR note
These edits are intentionally conservative and localized to compatibility pain points, with in-code comments added at the relevant call sites.
