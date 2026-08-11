#!/usr/bin/env bash
set -euo pipefail

: "${TEMPLATE_URL:?TEMPLATE_URL is required}"
: "${TEMPLATE_REF:?TEMPLATE_REF is required}"

temp_base="${RUNNER_TEMP:-$(mktemp -d)}"
temp_base="$(cd "$temp_base" && pwd -P)"
work_root="$temp_base/ternforge-python-template-acceptance"
rm -rf "$work_root"
mkdir -p "$work_root"
trap 'rm -rf "$work_root"' EXIT

default_target="$work_root/default"
product_target="$work_root/product"
tooling_target="$work_root/tooling"
browser_target="$work_root/browser"

uvx --from copier==9.17.0 copier copy \
  --quiet \
  --defaults \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$default_target"

uvx --from copier==9.17.0 copier copy \
  --quiet \
  --defaults \
  --data project_name=acceptance-lib \
  --data package_name=acceptance_lib \
  --data repository_name=acceptance-lib \
  --data project_title='Acceptance Lib' \
  --data project_title_lower='acceptance lib' \
  --data project_description='Ternforge Python template acceptance library.' \
  --data env_prefix=ACCEPTANCE_LIB \
  --data error_class_name=AcceptanceLibError \
  --data config_class_name=AcceptanceLibConfig \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$product_target"

uvx --from copier==9.17.0 copier copy \
  --quiet \
  --defaults \
  --data project_name=py-lib-runtime \
  --data package_name=py_lib_runtime \
  --data repository_name=acceptance-tooling \
  --data project_title='Py Lib Runtime' \
  --data project_title_lower='py lib runtime' \
  --data project_description='Shared runtime support helpers for Python libraries.' \
  --data env_prefix=PY_LIB_RUNTIME \
  --data error_class_name=PyLibRuntimeError \
  --data config_class_name=PyLibRuntimeConfig \
  --data runtime_audit_exclude_package= \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$tooling_target"

uvx --from copier==9.17.0 copier copy \
  --quiet \
  --defaults \
  --data project_name=browser-acceptance \
  --data package_name=browser_acceptance \
  --data repository_name=browser-acceptance \
  --data 'ci_playwright_browsers=["chromium"]' \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$browser_target"

grep -F 'playwright-browsers: "chromium"' "$browser_target/.github/workflows/ci.yml"
for target in "$default_target" "$product_target" "$tooling_target"; do
  test -f "$target/.copier-answers.yml"
  test -f "$target/.github/workflows/ci.yml"
  test -f "$target/.github/workflows/release.yml"
  test -f "$target/.flake8"
  test -f "$target/LICENSE"
  test -f "$target/pyproject.toml"
  test -f "$target/README.md"
  test -f "$target/scripts/env/setup.sh"
  test -f "$target/scripts/env/doctor.sh"
  test -f "$target/scripts/env/secrets.sh"
  test -f "$target/.devcontainer/Dockerfile"
  test -f "$target/.devcontainer/devcontainer.json"
  test ! -e "$target/_components"
  test ! -e "$target/template/_components"
  test -x "$target/scripts/env/setup.sh"
  test -x "$target/scripts/env/doctor.sh"
  test -x "$target/scripts/env/secrets.sh"
  grep -F "_src_path: $TEMPLATE_URL" "$target/.copier-answers.yml"
done

grep -F 'runtime-audit-exclude-package: "py-lib-runtime"' "$default_target/.github/workflows/ci.yml"
grep -F 'runtime-audit-exclude-package: ""' "$tooling_target/.github/workflows/ci.yml"
grep -F 'required-version = "==0.12.3"' "$default_target/pyproject.toml"
grep -F 'required-version = "==0.12.3"' "$tooling_target/pyproject.toml"

uv run --python 3.13 python - "$product_target" <<'PY'
from __future__ import annotations

import json
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
pyproject = tomllib.loads(root.joinpath("pyproject.toml").read_text(encoding="utf-8"))
manifest = json.loads(root.joinpath(".release-please-manifest.json").read_text(encoding="utf-8"))
assert pyproject["project"]["version"] == "0.1.0"
assert manifest["."] == "0.1.0"
assert pyproject["project"]["version"] == manifest["."]
assert pyproject["project"]["name"] == "acceptance-lib"
assert pyproject["tool"]["ternforge"]["primary_package"] == "acceptance_lib"
assert pyproject["tool"]["uv"]["required-version"] == "==0.12.3"
PY

git -C "$product_target" init --initial-branch=main
git -C "$product_target" config user.name 'Ternforge template acceptance'
git -C "$product_target" config user.email 'acceptance@ternforge.invalid'
(
  cd "$product_target"
  scripts/env/setup.sh
)
git -C "$product_target" add --all
git -C "$product_target" commit --no-verify -m 'test: prepare generated product acceptance'

(
  cd "$product_target"
  uv --version | grep -F 'uv 0.12.3'
  uv sync --locked --all-groups --python 3.13
  uv run --no-sync ruff check .
  uv run --no-sync ruff format --check .
  uv run --no-sync ty check
  uv run --no-sync pyright
  uv run --no-sync lint-imports
  uv run --no-sync py-lib-policy check
  uv run --no-sync flake8 src tests
  uv run --no-sync radon cc --show-complexity --min C src tests
  uv run --no-sync radon mi --show --min B src
  uv run --no-sync bandit --recursive src
  uv run --no-sync interrogate --fail-under 100 src
  uv run --no-sync deptry .
  uv run --no-sync pytest

  requirements="$work_root/runtime-requirements.txt"
  uv export \
    --frozen \
    --no-dev \
    --no-emit-project \
    --no-emit-package py-lib-runtime \
    --output-file "$requirements"
  uv run --frozen --no-sync pip-audit \
    --requirement "$requirements" \
    --no-deps \
    --disable-pip

  rm -rf build dist
  uv run --no-sync python -m build
  uv run --no-sync twine check dist/*
  uv run --no-sync check-wheel-contents dist/*.whl
  uv run --no-sync check-manifest

  project_name="$(uv run --no-sync python - <<'PY'
import pathlib
import tomllib
print(tomllib.loads(pathlib.Path("pyproject.toml").read_text())["project"]["name"])
PY
)"
  artifact_requirements="$work_root/artifact-runtime-requirements.txt"
  uv export \
    --frozen \
    --no-dev \
    --no-emit-project \
    --output-file "$artifact_requirements"
  for artifact in dist/*.whl dist/*.tar.gz; do
    environment="$work_root/$(basename "$artifact" | tr '.-' '__')"
    uv venv --python 3.13 "$environment"
    uv pip install --python "$environment/bin/python" --requirement "$artifact_requirements"
    uv pip install --python "$environment/bin/python" --no-deps "$artifact"
    "$environment/bin/python" - "$project_name" <<'PY'
import importlib
import importlib.metadata
import sys

project_name = sys.argv[1].lower().replace("_", "-")
candidates = sorted(
    package
    for package, distributions in importlib.metadata.packages_distributions().items()
    if any(item.lower().replace("_", "-") == project_name for item in distributions)
)
if not candidates:
    raise SystemExit(f"no import package found for {project_name}")
for package in candidates:
    importlib.import_module(package)
PY
  done

  uv run --no-sync pre-commit validate-config
  SKIP=ruff,ruff-format,ty,uv-lock-check \
    uv run --no-sync pre-commit run --all-files --hook-stage pre-commit

  git diff --exit-code
  test -z "$(git status --porcelain --untracked-files=normal)"
)

previous_tag="$(git tag --list 'v*' --sort=-version:refname | head -n 1)"
if [[ -n "$previous_tag" ]]; then
  update_target="$work_root/update"
  deleted_target="$work_root/deleted-readme"

  uvx --from copier==9.17.0 copier copy \
    --quiet \
    --defaults \
    --data project_name=update-lib \
    --data package_name=update_lib \
    --data repository_name=update-lib \
    --data project_title='Update Lib' \
    --data project_title_lower='update lib' \
    --data env_prefix=UPDATE_LIB \
    --data error_class_name=UpdateLibError \
    --data config_class_name=UpdateLibConfig \
    --vcs-ref "$previous_tag" \
    "$TEMPLATE_URL" \
    "$update_target"
  printf '# Operator-owned README\n' >"$update_target/README.md"
  printf 'operator sentinel\n' >"$update_target/operator.txt"
  printf '\n# User-owned source sentinel\n' >>"$update_target/src/update_lib/__init__.py"
  git -C "$update_target" init --initial-branch=main
  git -C "$update_target" config user.name 'Ternforge update acceptance'
  git -C "$update_target" config user.email 'acceptance@ternforge.invalid'
  git -C "$update_target" add --all
  git -C "$update_target" commit --no-verify -m 'test: prepare update fixture'
  uvx --from copier==9.17.0 copier update \
    --quiet \
    --defaults \
    --vcs-ref "$TEMPLATE_REF" \
    "$update_target"
  grep -F '# Operator-owned README' "$update_target/README.md"
  grep -F 'operator sentinel' "$update_target/operator.txt"
  grep -F '# User-owned source sentinel' "$update_target/src/update_lib/__init__.py"
  test ! -e "$update_target/_components"
  uvx --from copier==9.17.0 copier check-update --quiet "$update_target"

  uvx --from copier==9.17.0 copier copy \
    --quiet \
    --defaults \
    --data project_name=deleted-readme \
    --data package_name=deleted_readme \
    --data repository_name=deleted-readme \
    --data project_title='Deleted Readme' \
    --data project_title_lower='deleted readme' \
    --data env_prefix=DELETED_README \
    --data error_class_name=DeletedReadmeError \
    --data config_class_name=DeletedReadmeConfig \
    --vcs-ref "$previous_tag" \
    "$TEMPLATE_URL" \
    "$deleted_target"
  rm "$deleted_target/README.md"
  git -C "$deleted_target" init --initial-branch=main
  git -C "$deleted_target" config user.name 'Ternforge update acceptance'
  git -C "$deleted_target" config user.email 'acceptance@ternforge.invalid'
  git -C "$deleted_target" add --all
  git -C "$deleted_target" commit --no-verify -m 'test: prepare deleted README fixture'
  uvx --from copier==9.17.0 copier update \
    --quiet \
    --defaults \
    --vcs-ref "$TEMPLATE_REF" \
    "$deleted_target"
  test ! -e "$deleted_target/README.md"
fi

printf '%s\n' 'Python template acceptance passed'
