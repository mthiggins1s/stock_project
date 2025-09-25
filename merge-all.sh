#!/bin/bash
# Merge all branches into main, one by one, safely.

set -e  # stop on error

# Make sure we are on main
git checkout main
git pull origin main

# List of branches to merge (edit this list!)
branches=(
  # --- Core setup ---
  creating-the-users-table
  model-migration-and-generation
  creating-the-users-controller
  setting-up-BCrypt-to-Hash-User-Passwords
  using-bcrypt-to-hash-user-passwords
  harden-users#index

  # --- Authentication & security ---
  authenticating-user-requests
  login-action-and-jwt
  enforce-jwt-verification
  ensure_profile-callback

  # --- Features / API routes ---
  convert-stocks-to-json-and-provide-a-route-for-stocks
  serializing-data-with-blueprinter
  unique-userid-for-portfolio-sharing
  snycing-users-to-a-public-id
  adding-a-new-route-(portfolio)
  adding-route-for-"portfolio"
  adding-public-id-viewing-on-the-dashboard
  profile-changes-and-modifications
  setting-up-a-new-api
  setting-up-api-for-deployment
  rack-cors-unlock-to-move-to-frontend

  # --- Fixes & cleanup ---
  fixing-schema-file
  fixing-stock-controller-to-not-hard-code-stock-fetching
  fixing-the-api-bad-gateway
  fixing-the-401-error
  fixing-public_id
  fixing-placeholder-values
  fix-routes
  routes-cleanup
  removing-users-controller
  deployment-setup

  # --- Recovery / experiments ---
  creating-new-merge
  restarting-from-broken-merge
)


for b in "${branches[@]}"; do
  echo "🔄 Attempting to merge $b..."
  if git merge "$b"; then
    echo "✅ Successfully merged $b"
  else
    echo "⚠️ Merge conflict with $b. Please resolve, then run:"
    echo "   git add . && git commit"
    echo "   ./merge-all.sh   # re-run the script after fixing"
    exit 1
  fi
done

echo "🚀 All branches merged into main!"
git push origin main

