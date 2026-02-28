# C++17 Compatibility Notes

Date: 2026-02-27

## Summary
This change set improves C++17 compatibility by removing ambiguous member-pointer shorthand on `Optional` and by avoiding deprecated type-trait usage in newer language modes.

## Why this was needed
- Some C++17 toolchains report ambiguous overload resolution for `Optional::operator&` when used with member-function pointers (for example `&Value::getLiteralValue`).
- `std::is_literal_type` is deprecated in C++17 and removed in C++20, which causes warnings/errors on newer compilers.

## What changed

### 1) Fixed root-cause overload ambiguity in helper operator set
Ambiguity was addressed centrally by tightening the `operator&` overload set used by helper wrappers:
- removed the broad member-function-pointer catch-all in `Pointer<T>`
- retained explicit member-function overloads (`bool`, `R*`, `Optional<R>`, etc.)

This keeps the shorthand style (`obj & &Type::method`) available while avoiding ambiguous overload resolution in C++17.

Affected file:
- `src/helper.h`

### 2) Added a reusable abstraction for constant-literal extraction
A new helper API was added on `Value`:
- `Optional<Literal> Value::getConstantLiteralValue(bool transitive = true) const noexcept`

It encapsulates the common pattern `getConstantValue(...)->getLiteralValue()` and provides a single C++17-safe path used by call-sites that previously depended on `Optional::operator&` member-pointer chaining.

Affected files:
- `src/Values.h`
- `src/Values.cpp`

### 3) Refactored broad call-site set to shared constant-literal helper
A broader pass migrated repeated `getConstantValue() & &Value::getLiteralValue` patterns to
`getConstantLiteralValue()` across multiple subsystems for consistency and reduced duplication.

Affected files include:
- `src/intrinsics/WorkItems.cpp`
- `src/analysis/ControlFlowLoop.cpp`
- `src/analysis/FlagsAnalysis.cpp`
- `src/analysis/WorkItemAnalysis.cpp`
- `src/intermediate/VectorHelper.cpp`
- `src/normalization/LongOperations.cpp`
- `src/normalization/Rewrite.cpp`
- `src/optimization/Combiner.cpp`
- `src/optimization/Memory.cpp`
- `src/periphery/RegisterLoweredMemory.cpp`
- `src/periphery/VPM.cpp`

### 4) Replaced deprecated literal-type check in C++17+
`assert_literal` now gates trait selection by language version:
- pre-C++17: keeps `std::is_literal_type<T>::value`
- C++17+: uses `std::is_trivial<T>::value`

Both paths still require `assert_trivial<T>::value`.

Affected file:
- `src/concepts.h`

### 5) Added typed empty optional helper
To avoid accidental type-mismatch with `NO_VALUE` (which is `Optional<Value>`), a typed helper was added:
- `NO_OPTIONAL<T>` in `src/Optional.h`

`Value::getConstantLiteralValue()` now returns `NO_OPTIONAL<Literal>` for the empty case.

Affected files:
- `src/Optional.h`
- `src/Values.cpp`

## Non-functional impact
- No intended runtime/semantic behavior change.
- Change is focused on build portability and diagnostics cleanliness for modern compilers.

## PR note
These edits are intentionally conservative and localized to compatibility pain points, with in-code comments added at the relevant call sites.
