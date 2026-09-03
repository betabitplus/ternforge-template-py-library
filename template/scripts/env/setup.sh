[[% include "template/_components/components/project/py/base/template/scripts/env/setup.sh" %]]
printf '%s\n' "Synchronizing Ternforge DocOps authoring resources..."
uv run ternforge-docops sync
