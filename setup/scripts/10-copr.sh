#!/usr/bin/env bash

REPO_FILE="$(dirname "$0")/../data/coprs"

# Get a list of currently enabled COPR repositories to minimize DNF calls
echo "Checking currently enabled COPR repositories..."
ENABLED_COPRS=$(sudo dnf copr -q list | sed -e 's|[^/]*/||' -e 's/ (disabled)//')

# Read the file line by line
while IFS= read -r repo || [ -n "$repo" ]; do
  # Trim leading/trailing whitespace and skip empty lines or comments
  repo=$(echo "$repo" | xargs)
  [[ -z "$repo" || "$repo" =~ ^# ]] && continue

  # Check if the repo is already in the enabled list
  if echo "$ENABLED_COPRS" | grep -Fqx "$repo"; then
    echo "✓ $repo is already enabled."
  else
    echo "Updating: Enabling $repo..."
    if sudo dnf copr enable -y "$repo" &>/dev/null; then
      echo "Successfully enabled $repo"
    else
      echo "❌ Failed to enable $repo"
    fi
  fi
done <"$REPO_FILE"
