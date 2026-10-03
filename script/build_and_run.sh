#!/bin/bash
set -euo pipefail
TASK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TASK_BUILD="${TMPDIR:-/tmp}/adapta-pe-lite-independent-run"
MODE="${1:-run}"
case "$MODE" in run|--debug|--logs|--telemetry|--verify) ;; *) echo "Uso: $0 [--debug|--logs|--telemetry|--verify]" >&2; exit 2;; esac
pkill -x Adapta-PE-Lite 2>/dev/null || true
xcodebuild -project "$TASK_ROOT/Adapta-PE-Lite.xcodeproj" -scheme Adapta-PE-Lite -configuration Debug -derivedDataPath "$TASK_BUILD" build
APP="$TASK_BUILD/Build/Products/Debug/Adapta-PE-Lite.app"
if [[ "$MODE" == --debug ]]; then
    /usr/bin/open -a Xcode "$TASK_ROOT/Adapta-PE-Lite.xcodeproj"
    echo 'Proyecto abierto en Xcode. Usa Product > Run para ver la consola.'
    exit 0
fi
/usr/bin/open -n "$APP"
case "$MODE" in
    --logs) /usr/bin/log stream --level info --style compact --predicate 'process == "Adapta-PE-Lite"';;
    --telemetry) /usr/bin/log stream --level info --style compact --predicate 'subsystem == "pe.adapta.desktop"';;
    --verify) sleep 1; pgrep -x Adapta-PE-Lite >/dev/null;;
esac
