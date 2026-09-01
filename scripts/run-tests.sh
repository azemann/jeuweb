#!/usr/bin/env bash

set -u
set -o pipefail

jeuweb_profile="${1:-structure}"
case "$jeuweb_profile" in
  structure|content|all) ;;
  *)
    echo "Usage: $0 [structure|content|all]" >&2
    exit 2
    ;;
esac

if [[ -n "${JEUWEB_GODOT_BIN:-}" ]]; then
  jeuweb_godot="$JEUWEB_GODOT_BIN"
elif command -v godot >/dev/null 2>&1; then
  jeuweb_godot="$(command -v godot)"
elif command -v godot4 >/dev/null 2>&1; then
  jeuweb_godot="$(command -v godot4)"
elif [[ -x /home/evan/.local/bin/godot ]]; then
  jeuweb_godot="/home/evan/.local/bin/godot"
else
  echo "Godot est introuvable. Définir JEUWEB_GODOT_BIN." >&2
  exit 2
fi

jeuweb_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
jeuweb_tmp="$(mktemp -d /tmp/jeuweb-tests.XXXXXX)"
trap 'rm -rf "$jeuweb_tmp"' EXIT

is_content_test() {
  case "$1" in
    encounter_cadence_contract_test.gd|*_content_snapshot_test.gd) return 0 ;;
    *) return 1 ;;
  esac
}

should_run_test() {
  case "$jeuweb_profile" in
    all) return 0 ;;
    structure) ! is_content_test "$1" ;;
    content) is_content_test "$1" ;;
  esac
}

jeuweb_passed=0
jeuweb_failed=0

while IFS= read -r jeuweb_test; do
  jeuweb_file="$(basename "$jeuweb_test")"
  if ! should_run_test "$jeuweb_file"; then
    continue
  fi

  jeuweb_name="${jeuweb_file%.gd}"
  jeuweb_case_dir="$jeuweb_tmp/$jeuweb_name"
  mkdir -p "$jeuweb_case_dir/data" "$jeuweb_case_dir/config" "$jeuweb_case_dir/cache"
  jeuweb_log="$jeuweb_case_dir/output.log"

  set +e
  env \
    XDG_DATA_HOME="$jeuweb_case_dir/data" \
    XDG_CONFIG_HOME="$jeuweb_case_dir/config" \
    XDG_CACHE_HOME="$jeuweb_case_dir/cache" \
    "$jeuweb_godot" --headless --path "$jeuweb_root" --script "res://$jeuweb_test" \
    >"$jeuweb_log" 2>&1
  jeuweb_code=$?
  set -e

  if [[ $jeuweb_code -eq 0 ]] && ! rg -q '(^|[[:space:]])(ERROR|SCRIPT ERROR|WARNING):' "$jeuweb_log"; then
    jeuweb_marker="$(rg '(_TEST|TEST): PASS' "$jeuweb_log" | tail -1 || true)"
    printf 'PASS %-48s %s\n' "$jeuweb_name" "$jeuweb_marker"
    jeuweb_passed=$((jeuweb_passed + 1))
  else
    printf 'FAIL %-48s exit=%d\n' "$jeuweb_name" "$jeuweb_code"
    sed -n '1,220p' "$jeuweb_log"
    jeuweb_failed=$((jeuweb_failed + 1))
  fi
done < <(cd "$jeuweb_root" && rg --files tests -g '*.gd' | sort)

printf 'RESULT profile=%s passed=%d failed=%d\n' "$jeuweb_profile" "$jeuweb_passed" "$jeuweb_failed"
[[ $jeuweb_failed -eq 0 ]]
