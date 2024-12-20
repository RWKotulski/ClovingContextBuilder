# orchestrate_summaries_in_json.sh

#!/usr/bin/env bash

set -e

# Run the initial summary to get app_summary.json
bash summarize_app.sh

if [ ! -f "app_summary.json" ]; then
  echo "Error: app_summary.json not found. Ensure summarize_app.sh ran successfully."
  exit 1
fi

# Load the existing summary into a variable
JSON=$(cat app_summary.json)

# Extract file paths using jq
FILE_PATHS=$(echo "$JSON" | jq -r '.files[].path')

# We'll iterate over each file path, get a summary, and update the JSON
UPDATED_JSON="$JSON"

for FILE in $FILE_PATHS; do
  # Check if the file actually exists locally
  if [ ! -f "$FILE" ]; then
    echo "Warning: File '$FILE' listed in app_summary.json but not found locally."
    continue
  fi

  echo "Generating detailed summary for $FILE..."
  SUMMARY=$(bash summarize_file.sh "$FILE")

  # Escape the summary for safe insertion into JSON
  # (jq handles strings safely, so we just need to pass it as a variable)
  UPDATED_JSON=$(echo "$UPDATED_JSON" | jq --arg path "$FILE" --arg summary "$SUMMARY" '
    .files = (.files | map(
      if .path == $path then
        . + { "detailed_summary": $summary }
      else
        .
      end
    ))
  ')
done

# Save the updated JSON back to app_summary.json
echo "$UPDATED_JSON" > app_summary.json

echo "app_summary.json has been updated with detailed summaries."
