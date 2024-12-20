#summarize_file.sh
#!/usr/bin/env bash

# This script sends the contents of a given file to the OpenAI API and asks for a short summary
# of the file's salient details and functions.

set -e

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY environment variable is not set."
  exit 1
fi

if [ -z "$OPENAI_MODEL" ]; then
  echo "Error: OPENAI_MODEL environment variable is not set."
  exit 1
fi

if [ $# -lt 1 ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File '$FILE_PATH' not found."
  exit 1
fi

FILE_CONTENT=$(cat "$FILE_PATH")

# Create the prompt asking the model to summarize the file
PROMPT="You are an assistant who reads code files. Given the following file content, create a short summary highlighting the salient details, main functions, and purpose of the code."

# Call the OpenAI API
RESPONSE=$(curl -sS https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "$(jq -n \
    --arg model_var "$OPENAI_MODEL" \
    --arg prompt "$PROMPT" \
    --arg file_content "$FILE_CONTENT" \
    '{
       "model": $model_var,
       "messages": [
         {"role": "system", "content": "You are a helpful assistant."},
         {"role": "user", "content": $prompt},
         {"role": "user", "content": $file_content}
       ],
       "max_tokens": 300,
       "temperature": 0.7
     }'
  )")

# Extract the generated summary from the response
SUMMARY=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

echo "$SUMMARY"
