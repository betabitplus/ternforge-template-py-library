# Changelog

## [1.3.5](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.3.4...v1.3.5) (2026-08-08)


### Bug Fixes

* complete Python template CI contract ([#43](https://github.com/betabitplus/ternforge-template-py-library/issues/43)) ([558c4f7](https://github.com/betabitplus/ternforge-template-py-library/commit/558c4f7fdb9e0a2ae84fea1a999f6381e5a528d6))

## [1.3.4](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.3.3...v1.3.4) (2026-08-08)


### Bug Fixes

* **deps:** update vendir https://github.com/betabitplus/ternforge-template-components.git to v1.7.3 ([#39](https://github.com/betabitplus/ternforge-template-py-library/issues/39)) ([404a4aa](https://github.com/betabitplus/ternforge-template-py-library/commit/404a4aaf0854a6d28420e130f8112f60fb871c53))

## [1.3.3](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.3.2...v1.3.3) (2026-08-08)


### Bug Fixes

* **deps:** update vendir https://github.com/betabitplus/ternforge-template-components.git to v1.7.2 ([#33](https://github.com/betabitplus/ternforge-template-py-library/issues/33)) ([9e1377f](https://github.com/betabitplus/ternforge-template-py-library/commit/9e1377f52f26094415479cd1bd065d550d779a2f))

## [1.3.2](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.3.1...v1.3.2) (2026-08-08)


### Bug Fixes

* install generated artifact dependencies from lock ([#35](https://github.com/betabitplus/ternforge-template-py-library/issues/35)) ([519ce89](https://github.com/betabitplus/ternforge-template-py-library/commit/519ce89bbe95cf8dbd1aee07b3aee75a69bf6a3c))

## [1.3.1](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.3.0...v1.3.1) (2026-08-08)


### Bug Fixes

* **deps:** update vendir https://github.com/betabitplus/ternforge-template-components.git to v1.7.0 ([#30](https://github.com/betabitplus/ternforge-template-py-library/issues/30)) ([b11c0b3](https://github.com/betabitplus/ternforge-template-py-library/commit/b11c0b3f0e25baf15c5f783bff54cf8d99c36890))

## [1.3.0](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.2.8...v1.3.0) (2026-08-08)


### Features

* dispatch Python template releases ([#28](https://github.com/betabitplus/ternforge-template-py-library/issues/28)) ([068711c](https://github.com/betabitplus/ternforge-template-py-library/commit/068711cf9137aa9588c70d8a2b914592daeff70d))

## [1.2.8](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.2.7...v1.2.8) (2026-08-08)


### Bug Fixes

* keep generated changelog release-owned ([#24](https://github.com/betabitplus/ternforge-template-py-library/issues/24)) ([436647b](https://github.com/betabitplus/ternforge-template-py-library/commit/436647b82b57d480b057b26127556a93e085f972))

## [1.2.7](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.2.6...v1.2.7) (2026-08-08)


### Bug Fixes

* restore standard Python template ownership ([#22](https://github.com/betabitplus/ternforge-template-py-library/issues/22)) ([6dcd728](https://github.com/betabitplus/ternforge-template-py-library/commit/6dcd7284c0f4618603d49b1a8be0544c5e1ed3cb))

## [1.2.6](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.2.5...v1.2.6) (2026-08-07)


### Bug Fixes

* remove obsolete recopy audit flag ([#20](https://github.com/betabitplus/ternforge-template-py-library/issues/20)) ([53f824a](https://github.com/betabitplus/ternforge-template-py-library/commit/53f824afe5e6630a6679f45423d20a28476e15e9))

## [1.2.5](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.2.4...v1.2.5) (2026-08-07)


### Bug Fixes

* pin corrected tooling snapshots ([a1e6a64](https://github.com/betabitplus/ternforge-template-py-library/commit/a1e6a646f1c0748d4ded904790ca507b4a9ad35c))

## [1.2.4](https://github.com/betabitplus/ternforge-template-py-library/compare/v1.2.3...v1.2.4) (2026-08-07)


### Bug Fixes

* bind released tooling packages ([#16](https://github.com/betabitplus/ternforge-template-py-library/issues/16)) ([c8ef7d9](https://github.com/betabitplus/ternforge-template-py-library/commit/c8ef7d9232afa087c093aac79634e4cdb05f5e86))

## 1.2.3 — 2026-08-07

- Provide Hatchling inside the `check-manifest` pre-commit environment.
- Keep no-build-isolation manifest checks working for both setuptools and Hatchling projects.
- Update the immutable component snapshot to `v1.6.5`.

## 1.2.2 — 2026-08-07

- Align generated Flake8 class-order hooks with the aggregate CI contract.
- Update the immutable component snapshot to `v1.6.4`.
- Prove the subsequent Copier update path for onboarded tooling repositories.

## 1.2.1 — 2026-08-07

- Pin generated projects, host tooling, CI, and devcontainers to exact `uv 0.12.0`.
- Update the immutable component snapshot to `v1.6.3`.
- Pin template and generated release orchestration to `ternforge-infra-ci v1.6.1`.
- Preserve standalone tooling dependency boundaries and executable generated checkers.
- Keep generated utility scripts self-contained and prove create/update/build acceptance.

## 1.2.0 — 2026-08-06

- Update the released component snapshot to `v1.6.0`.
- Pin generated CI and release callers to `ternforge-infra-ci v1.6.0`.
- Add explicit standalone-tooling lifecycle answers and backward-compatible update ownership.
- Expand protected acceptance to ordinary and standalone-tooling renders.

## 1.1.0 — 2026-08-06

- Update the released component snapshot to `v1.5.0`.
- Declare the managed Python editor line length as 88 characters.
- Prove previous-release ownership and visible three-way conflict behavior.

## 1.0.0 — 2026-08-06

- Release the complete standalone Python library product.
- Publish immutable runtime, policy, and testkit bindings.
- Add locked direct CI, local hooks, automatic secrets, and devcontainer support.
