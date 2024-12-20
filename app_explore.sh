# app_explore.sh

#!/usr/bin/env bash

# This script serves as an introduction and orchestrator for the entire process.
# It prompts the user for their OpenAI API key, preferred model, and then runs the
# other scripts to generate a comprehensive summary of the Rails app.

set -e

# Prompt for API key if not set
if [ -z "$OPENAI_API_KEY" ]; then
  read -p "Enter your OpenAI API key: " API_KEY_INPUT
  if [ -z "$API_KEY_INPUT" ]; then
    echo "Error: No API key provided."
    exit 1
  fi
  export OPENAI_API_KEY="$API_KEY_INPUT"
fi

# Prompt for OpenAI model (default gpt-4)
read -p "Enter the model you want to use (default: o1): " MODEL_INPUT
if [ -z "$MODEL_INPUT" ]; then
  MODEL_INPUT="o1"
fi
export OPENAI_MODEL="$MODEL_INPUT"

echo "Using model: $OPENAI_MODEL"

# Confirm that required scripts are present
if [ ! -f "generate_summary.sh" ] || [ ! -f "summarize_file.sh" ] || [ ! -f "orchestrate_summaries_in_json.sh" ]; then
  echo "Error: One or more required scripts (generate_summary.sh, summarize_file.sh, orchestrate_summaries_in_json.sh) are missing."
  exit 1
fi

# Run the orchestrator script that ties everything together
echo "Running the full discovery and summary process..."
bash orchestrate_summaries_in_json.sh

echo "Process completed. Check app_summary.json for updated summaries."
