#!/usr/bin/env bash
# Set the Apple Developer team on all three iOS projects.
#
#   ./core/set_ios_team.sh ABCDE12345          # your 10-character team id
#   ./core/set_ios_team.sh --show              # what is set now
#
# Find the id in Xcode -> Settings -> Accounts (next to the team name), or at
# developer.apple.com -> Membership.
#
# The projects ship with no DEVELOPMENT_TEAM at all, so Xcode cannot pick a
# signing identity and every device build stops at "No profiles for
# 'com.setu.thayi' were found". Simulator and --no-codesign builds do not care,
# which is why this only bites the moment you try a real phone.
#
# Only the Runner target is touched, not RunnerTests: the tests never go to a
# device, and giving them a team makes Xcode try to provision a second bundle
# id for no reason.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPS=(thayi asha care)

if [[ "${1:-}" == "--show" ]]; then
  for app in "${APPS[@]}"; do
    printf "%-6s " "$app"
    grep -o "DEVELOPMENT_TEAM = [^;]*" "$ROOT/$app/ios/Runner.xcodeproj/project.pbxproj" \
      | sort -u | tr '\n' ' ' || true
    echo
  done
  exit 0
fi

TEAM="${1:-}"
[[ "$TEAM" =~ ^[A-Z0-9]{10}$ ]] || {
  echo "usage: $0 <10-character-team-id>   (or --show)" >&2
  echo "  e.g. $0 8QX8VDD99Q" >&2
  exit 1; }

python3 - "$ROOT" "$TEAM" "${APPS[@]}" <<'PY'
import re
import sys

root, team, *apps = sys.argv[1:]

for app in apps:
    path = f"{root}/{app}/ios/Runner.xcodeproj/project.pbxproj"
    text = open(path).read()
    bundle = f"com.setu.{app}"

    # Anchor on the app target's own bundle id. It appears once per build
    # configuration (Debug/Release/Profile) and never in RunnerTests, whose
    # id carries a .RunnerTests suffix - so this reaches exactly the three
    # blocks that matter without having to parse the pbxproj.
    line = re.compile(
        rf"^(?P<indent>[\t ]*)PRODUCT_BUNDLE_IDENTIFIER = {re.escape(bundle)};$",
        re.MULTILINE,
    )

    text, existing = re.subn(r"^[\t ]*DEVELOPMENT_TEAM = [^;]*;\n", "", text,
                             flags=re.MULTILINE)

    def add(match: re.Match) -> str:
        indent = match.group("indent")
        return (f"{indent}DEVELOPMENT_TEAM = {team};\n{match.group(0)}")

    text, count = line.subn(add, text)
    if count != 3:
        raise SystemExit(f"{app}: expected 3 Runner configs, matched {count}")

    open(path, "w").write(text)
    was = f" (replaced {existing})" if existing else ""
    print(f"  {app:6} {count} configs -> {team}{was}")
PY

cat <<NEXT

Now build to the phone:
  cd thayi && flutter run --release --dart-define-from-file=../.env

First run per app, Xcode registers the bundle id and provisions a profile,
which needs the phone plugged in or on the same network and unlocked.
NEXT
