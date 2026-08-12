# Ternforge Python Library Template

Released Copier template for complete standalone Python libraries.

The generated product includes the Python package boundary, tests, documentation,
examples, workbench, agent guidance, locked quality and security tooling,
release workflows, automatic direnv/SOPS secret loading, and a digest-pinned
devcontainer.

## Source contract

- Copier: exact minimum declared by `copier.yml`
- Vendir: exact version declared by the CI setup input
- uv: product pin declared by the component `[tool.uv].required-version`; acceptance runtime pinned in CI
- Components: declared by `vendir.yml` and resolved exactly by `vendir.lock.yml`

The committed `template/_components` directory is a Vendir-managed snapshot.
Generated repositories never contain `_components`.

Every pull request renders a real library and executes the complete locked
quality, security, test, audit, build, metadata, and isolated-install gate.
