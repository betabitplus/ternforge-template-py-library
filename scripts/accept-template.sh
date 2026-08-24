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
devcontainer_packages_target="$work_root/devcontainer-packages"
waiver_target="$work_root/waiver"
invalid_waiver_target="$work_root/invalid-waiver"

uvx --from copier==9.17.2 copier copy \
  --quiet \
  --defaults \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$default_target"

uvx --from copier==9.17.2 copier copy \
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

uvx --from copier==9.17.2 copier copy \
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

uvx --from copier==9.17.2 copier copy \
  --quiet \
  --defaults \
  --data project_name=browser-acceptance \
  --data package_name=browser_acceptance \
  --data repository_name=browser-acceptance \
  --data 'ci_playwright_browsers=["chromium"]' \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$browser_target"

uvx --from copier==9.17.2 copier copy \
  --quiet \
  --defaults \
  --data project_name=devcontainer-packages \
  --data package_name=devcontainer_packages \
  --data repository_name=devcontainer-packages \
  --data 'devcontainer_apt_packages={"libgl1":"1.7.0-1+b2"}' \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$devcontainer_packages_target"

uvx --from copier==9.17.2 copier copy \
  --quiet \
  --defaults \
  --data project_name=waiver-acceptance \
  --data package_name=waiver_acceptance \
  --data repository_name=waiver-acceptance \
  --data 'pip_audit_waivers=[{"id":"CVE-2025-69872","rationale":"No patched upstream release exists.","remove_when":"Remove after a patched dependency release is adopted."}]' \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$waiver_target"

if uvx --from copier==9.17.2 copier copy \
  --quiet \
  --defaults \
  --data project_name=invalid-waiver \
  --data package_name=invalid_waiver \
  --data repository_name=invalid-waiver \
  --data 'pip_audit_waivers=[{"id":"CVE-2025-69872"}]' \
  --vcs-ref "$TEMPLATE_REF" \
  "$TEMPLATE_URL" \
  "$invalid_waiver_target"; then
  echo 'incomplete pip_audit_waivers entry must be rejected' >&2
  exit 1
fi

grep -F 'playwright-browsers: "chromium"' "$browser_target/.github/workflows/ci.yml"
grep -F 'playwright-browsers: "chromium"' "$browser_target/.github/workflows/docs.yml"
grep -F 'playwright-browsers: ""' "$default_target/.github/workflows/docs.yml"
grep -F 'libgl1="1.7.0-1+b2" \' "$devcontainer_packages_target/.devcontainer/Dockerfile"
! grep -F 'libgl1=' "$default_target/.devcontainer/Dockerfile"
grep -F 'runtime-audit-ignore-vulnerabilities: "CVE-2025-69872"' "$waiver_target/.github/workflows/ci.yml"
grep -F '[tool.pip-audit]' "$waiver_target/pyproject.toml"
grep -F '# CVE-2025-69872: No patched upstream release exists.' "$waiver_target/pyproject.toml"
grep -F '# Remove when: Remove after a patched dependency release is adopted.' "$waiver_target/pyproject.toml"
for target in "$default_target" "$product_target" "$tooling_target" "$browser_target"; do
  grep -F 'runtime-audit-ignore-vulnerabilities: ""' "$target/.github/workflows/ci.yml"
  ! grep -F '[tool.pip-audit]' "$target/pyproject.toml"
done

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
test -f "$product_target/docs/conf.py"
test -f "$product_target/docs/index.md"
test -f "$product_target/docs/api.md"
test ! -e "$product_target/docs/_static/gallery-default.svg"
test -f "$product_target/examples/acceptance_lib/GALLERY_HEADER.rst"
test -f "$product_target/tests/test_examples.py"
test ! -e "$product_target/docs/acceptance_lib/usage.md"
test ! -e "$product_target/tests/acceptance_lib/e2e/examples/test_examples_smoke.py"
uv run --python 3.13 python - "$product_target" <<'PY'
from __future__ import annotations

import json
import pathlib
import re
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
assert re.fullmatch(r"==\d+\.\d+\.\d+", pyproject["tool"]["uv"]["required-version"])
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
  uv run --no-sync sphinx-build \
    -W \
    --keep-going \
    -D plot_gallery=0 \
    -b html \
    docs \
    "$work_root/docs-html"
  test -f "$work_root/docs-html/index.html"
  test -f "$work_root/docs-html/api.html"
  test -f "$work_root/docs-html/auto_examples/index.html"
  test -f "$work_root/docs-html/_images/sphx_glr_config_demo_thumb.png"
  grep -F 'sphx_glr_config_demo_thumb.png' "$work_root/docs-html/auto_examples/index.html"
  ! grep -F 'sphinx_gallery_tags' "$work_root/docs-html/auto_examples/config_demo.html"

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
  uv build --no-sources
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
    uv pip sync --python "$environment/bin/python" "$artifact_requirements"
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

  test -z "$(git status --porcelain --untracked-files=normal)"
)

previous_tag="$(git tag --list 'v*' --sort=-version:refname | head -n 1)"
if [[ -n "$previous_tag" ]]; then
  update_target="$work_root/update"
  deleted_target="$work_root/deleted-readme"

  uvx --from copier==9.17.2 copier copy \
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
  uvx --from copier==9.17.2 copier update \
    --quiet \
    --defaults \
    --vcs-ref "$TEMPLATE_REF" \
    "$update_target"
  grep -F '# Operator-owned README' "$update_target/README.md"
  grep -F 'operator sentinel' "$update_target/operator.txt"
  grep -F '# User-owned source sentinel' "$update_target/src/update_lib/__init__.py"
  test ! -e "$update_target/_components"
  uvx --from copier==9.17.2 copier check-update --quiet "$update_target"

  uvx --from copier==9.17.2 copier copy \
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
  uvx --from copier==9.17.2 copier update \
    --quiet \
    --defaults \
    --vcs-ref "$TEMPLATE_REF" \
    "$deleted_target"
  test ! -e "$deleted_target/README.md"
fi

printf '%s\n' 'Python template acceptance passed'
