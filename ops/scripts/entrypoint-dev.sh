#!/bin/sh
# exit immediately if a command exits with a non-zero status.
set -e

echo "Running go mod tidy..."
go mod tidy -x

# --- Smart execution logic ---
# Check if the command is an interactive shell.
if [ "$1" = "sh" ] || [ "$1" = "bash" ]; then
  # If it's a shell, execute it directly without tini.
  # This allows 'docker-compose run app sh' to work correctly.
  exec "$@"
else
  # For any other command (like 'go run' from your compose file),
  # execute it through tini for proper signal handling.
  exec /sbin/tini -- "$@"
fi