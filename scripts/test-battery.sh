#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/pmset" <<'EOF'
#!/usr/bin/env bash
cat <<'OUT'
Now drawing from 'Battery Power'
 -InternalBattery-0 (id=22610019) 9%; discharging; 0:31 remaining present: true
 Battery Warning: Early
OUT
EOF
chmod +x "$tmp/pmset"

[ "$(PATH="$tmp:$PATH" "$(dirname "$0")/battery.sh")" = '9%ꜜ 0:31' ]
