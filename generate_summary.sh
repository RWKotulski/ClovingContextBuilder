#generate_summary.sh
#!/usr/bin/env bash

set -e

BASE_DIR=$(pwd)
OUTPUT_FILE="app_summary.json"
ALL_ITEMS=""

extract_description() {
  local file_path="$1"
  head_lines=$(head -n 10 "$file_path")
  doc=$(echo "$head_lines" | grep -E '^#|^\s*(class|module)' | sed 's/^[#[:space:]]*//g' | tr '\n' ' ')
  [ -z "$doc" ] && doc="No top-level documentation found."
  echo "$doc"
}

process_directory() {
  local dir_path="$1"
  local file_type="$2"
  
  while read -r file; do
    [ -f "$file" ] || continue
    desc=$(extract_description "$file")
    absolute_path=$(cd "$(dirname "$file")" && pwd)/$(basename "$file")
    relative_path="${absolute_path#$BASE_DIR/}"

    [ -n "$ALL_ITEMS" ] && ALL_ITEMS="${ALL_ITEMS},"
    ALL_ITEMS="${ALL_ITEMS}
    {
      \"path\": \"${relative_path}\",
      \"type\": \"${file_type}\",
      \"description\": \"${desc}\"
    }"
  done < <(find "$dir_path" -type f -name "*.rb" | sort)
}

process_views() {
  while read -r file; do
    absolute_path=$(cd "$(dirname "$file")" && pwd)/$(basename "$file")
    relative_path="${absolute_path#$BASE_DIR/}"

    [ -n "$ALL_ITEMS" ] && ALL_ITEMS="${ALL_ITEMS},"
    ALL_ITEMS="${ALL_ITEMS}
    {
      \"path\": \"${relative_path}\",
      \"type\": \"view\",
      \"description\": \"View template for rendering UI.\"
    }"
  done < <(find "app/views" -type f \( -name "*.erb" -o -name "*.haml" -o -name "*.html" \) | sort)
}

generate_summary() {
  ALL_ITEMS=""

  [ -d "app/models" ] && process_directory "app/models" "model"
  [ -d "app/controllers" ] && process_directory "app/controllers" "controller"
  [ -d "app/services" ] && process_directory "app/services" "service"
  [ -d "app/views" ] && process_views

  echo "{"
  echo "  \"files\": ["
  if [ -n "$ALL_ITEMS" ]; then
    # No need for sed here, just print ALL_ITEMS as is
    echo "$ALL_ITEMS"
  fi
  echo "  ]"
  echo "}"
}

# Generate and then format the JSON
generate_summary > "$OUTPUT_FILE"
jq . "$OUTPUT_FILE" > tmp.json && mv tmp.json "$OUTPUT_FILE"
echo "Summary generated and saved to $OUTPUT_FILE."
