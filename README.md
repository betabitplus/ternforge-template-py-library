# Ternforge Python Library Template

Released Copier template for complete standalone Python libraries.

The generated product includes the Python package boundary, tests, documentation,
examples, workbench, agent guidance, locked quality and security tooling,
release workflows, automatic direnv/SOPS secret loading, and a digest-pinned
devcontainer.

## Source contract

- Copier: `9.17.0`
- Vendir: `0.46.0`
- uv: `0.12.0` for template acceptance
- Components: declared by `vendir.yml` and resolved exactly by `vendir.lock.yml`

The committed `template/_components` directory is a Vendir-managed snapshot.
Generated repositories never contain `_components`.
