#!/usr/bin/env bash
set -euo pipefail

input_path=""
label_re=""
value_re=""
type_filter=""
has_bounds="false"
x1=0
y1=0
x2=0
y2=0

print_help() {
  cat <<'EOF'
Usage: axe_interactables.sh [--input <path>] [--label <regex>] [--value-regex <regex>] [--type <type>] [--bounds <x1> <y1> <x2> <y2>] [label_regex]

Options:
  --input <path> Read accessibility tree JSON from file instead of stdin
  --label <regex>
                 Filter AXLabel with case-insensitive regex
  --value-regex <regex>
                 Filter AXValue with case-insensitive regex
  --type <type>  Filter by AX type (e.g., Button, TextField)
  --bounds <x1> <y1> <x2> <y2>
                 Keep elements fully inside bounds (top-left to bottom-right)

Notes:
  - Reads an accessibility tree JSON document from stdin by default.
  - label_regex is optional; prefer --label to avoid ambiguity with other args.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      input_path="${2:-}"
      shift 2
      ;;
    --label)
      label_re="${2:-}"
      shift 2
      ;;
    --value-regex)
      value_re="${2:-}"
      shift 2
      ;;
    --type)
      type_filter="${2:-}"
      shift 2
      ;;
    --bounds)
      x1="${2:-}"
      y1="${3:-}"
      x2="${4:-}"
      y2="${5:-}"
      has_bounds="true"
      shift 5
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      if [[ -n "$label_re" ]]; then
        print_help
        exit 1
      fi
      label_re="$1"
      shift
      ;;
  esac
done

if [[ "$has_bounds" == "true" ]]; then
  if [[ -z "$x1" || -z "$y1" || -z "$x2" || -z "$y2" ]]; then
    print_help
    exit 1
  fi
fi

if [[ -n "$input_path" && "$input_path" != "-" ]]; then
  exec <"$input_path"
fi

if [[ -z "$input_path" && -t 0 ]]; then
  print_help
  exit 1
fi

jq -c \
  --arg label_re "$label_re" \
  --arg value_re "$value_re" \
  --arg type "$type_filter" \
  --argjson has_bounds "$has_bounds" \
  --argjson x1 "$x1" \
  --argjson y1 "$y1" \
  --argjson x2 "$x2" \
  --argjson y2 "$y2" '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select((.AXLabel // "") != "" or (.AXValue // "") != "")
| select($label_re == "" or ((.AXLabel // "") | test($label_re; "i")))
| select($value_re == "" or ((.AXValue // "") | test($value_re; "i")))
| select($type == "" or .type == $type)
| select($has_bounds == false or (.frame.x >= $x1 and .frame.y >= $y1 and (.frame.x + .frame.width) <= $x2 and (.frame.y + .frame.height) <= $y2))
| {
  type,
  role:.role_description,
  label:.AXLabel,
  value:.AXValue,
  id:.AXUniqueId,
  x:(.frame.x | floor),
  y:(.frame.y | floor),
  w:(.frame.width | floor),
  h:(.frame.height | floor),
  cx:((.frame.x + (.frame.width/2)) | floor),
  cy:((.frame.y + (.frame.height/2)) | floor)
}'
