#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  xcodebuild-app-info.sh -scheme <Scheme> (-project <.xcodeproj> | -workspace <.xcworkspace>) [options]

Options:
  -configuration <Debug|Release>   Default: Debug
  -destination "<dest>"            Optional xcodebuild destination string
  -h, --help                       Show help

Outputs:
  LOG_PATH, TARGET_BUILD_DIR, FULL_PRODUCT_NAME, APP_PATH, BUNDLE_ID, EXECUTABLE_NAME
EOF
}

project=""
workspace=""
scheme=""
configuration="Debug"
destination=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -project)
      project="${2:-}"
      shift 2
      ;;
    -workspace)
      workspace="${2:-}"
      shift 2
      ;;
    -scheme)
      scheme="${2:-}"
      shift 2
      ;;
    -configuration)
      configuration="${2:-}"
      shift 2
      ;;
    -destination)
      destination="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$scheme" ]]; then
  echo "Missing -scheme" >&2
  usage
  exit 1
fi

if [[ -n "$project" && -n "$workspace" ]]; then
  echo "Provide only one of -project or -workspace" >&2
  usage
  exit 1
fi

if [[ -z "$project" && -z "$workspace" ]]; then
  echo "Missing -project or -workspace" >&2
  usage
  exit 1
fi

log_path="${LOG_PATH:-$(mktemp /tmp/xcodebuild-settings.XXXXXX.log)}"

cmd=(xcodebuild -showBuildSettings -scheme "$scheme" -configuration "$configuration")
if [[ -n "$project" ]]; then
  cmd+=(-project "$project")
else
  cmd+=(-workspace "$workspace")
fi
if [[ -n "$destination" ]]; then
  cmd+=(-destination "$destination")
fi

if ! "${cmd[@]}" >"$log_path" 2>&1; then
  echo "LOG_PATH=$log_path"
  echo "ERROR=1"
  exit 1
fi

extract() {
  local key="$1"
  (rg -n "$key" "$log_path" || true) | head -n1 | sed 's/^.*= //'
}

target_build_dir="$(extract 'TARGET_BUILD_DIR')"
full_product_name="$(extract 'FULL_PRODUCT_NAME')"
bundle_id="$(extract 'PRODUCT_BUNDLE_IDENTIFIER')"
executable_name="$(extract 'EXECUTABLE_NAME')"

app_path=""
if [[ -n "$target_build_dir" && -n "$full_product_name" ]]; then
  app_path="${target_build_dir}/${full_product_name}"
fi

echo "LOG_PATH=$log_path"
echo "TARGET_BUILD_DIR=$target_build_dir"
echo "FULL_PRODUCT_NAME=$full_product_name"
echo "APP_PATH=$app_path"
echo "BUNDLE_ID=$bundle_id"
echo "EXECUTABLE_NAME=$executable_name"
