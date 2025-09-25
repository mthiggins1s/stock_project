#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH="${TARGET_BRANCH:-main}"        # change if your default branch is different
BACKUP_BRANCH="${BACKUP_BRANCH:-backup-branch}"
PREFER="${PREFER:-theirs}"                    # 'theirs' keeps incoming branch changes, 'ours' keeps main
LOG_FILE="automerge_$(date +%Y%m%d_%H%M%S).log"
TAG="pre-automerge-$(date +%Y%m%d_%H%M%S)"

# exclude HEAD, main, and backup-branch from the merge list
EXCLUDES_REGEX="^(HEAD|${TARGET_BRANCH}|${BACKUP_BRANCH})$"

trap 'echo; echo "❌ Error occurred. To roll back locally:"; echo "   git reset --hard ${TAG}"; echo "To roll back remote (if pushed):"; echo "   git push --force-with-lease origin ${TARGET_BRANCH}"; echo' ERR

echo "=== Auto-merging into ${TARGET_BRANCH} (prefer ${PREFER}) ===" | tee "$LOG_FILE"

# 0) sanity: clean working tree
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree not clean. Commit or stash changes and retry." | tee -a "$LOG_FILE"
  exit 1
fi

git fetch --all --prune | tee -a "$LOG_FILE"

# 1) checkout target & update
git checkout "${TARGET_BRANCH}" | tee -a "$LOG_FILE"
git pull --ff-only origin "${TARGET_BRANCH}" | tee -a "$LOG_FILE"

# 2) safety tag
git tag -a "$TAG" -m "Safety tag before auto-merge" | tee -a "$LOG_FILE"
echo "Safety tag created: $TAG" | tee -a "$LOG_FILE"

# 3) enable rerere to reuse resolutions
git config rerere.enabled true

# 4) function to produce branch list (newline separated, safe for weird names)
branch_list() {
  if [[ -f .merge-order ]]; then
    echo "Using .merge-order" | tee -a "$LOG_FILE"
    # one branch per line; ignores blank lines and comments
    grep -vE '^\s*#' .merge-order | sed '/^\s*$/d'
  else
    git for-each-ref --format='%(refname:short)' refs/heads | grep -vE "$EXCLUDES_REGEX"
  fi
}

# helper: choose side flag for hard conflict takeover
SIDE_FLAG="--theirs"
[[ "$PREFER" == "ours" ]] && SIDE_FLAG="--ours"

# 5) merge loop
while IFS= read -r b; do
  [[ -z "$b" ]] && continue
  echo "---- Merging '$b' into ${TARGET_BRANCH} ----" | tee -a "$LOG_FILE"

  # Try a merge preferring chosen side for *content* conflicts
  if git merge --no-ff -X "$PREFER" -m "Auto-merge '$b' into ${TARGET_BRANCH} (prefer ${PREFER})" -- "$b" 2>>"$LOG_FILE"; then
    echo "✅ Clean merge: $b" | tee -a "$LOG_FILE"
    continue
  fi

  echo "⚠️ Conflicts detected. Auto-resolving by taking ${PREFER} versions..." | tee -a "$LOG_FILE"

  # Bruteforce resolve: take chosen side for all conflicted paths
  git checkout "$SIDE_FLAG" -- . || true

  # If any paths remain unmerged (e.g., deletes/renames), stage removals
  if git ls-files -u | awk '{print $4}' | sort -u | read -r _; then
    UNMERGED=$(git ls-files -u | awk '{print $4}' | sort -u)
    for p in $UNMERGED; do git rm -f -- "$p" 2>/dev/null || true; done
  fi

  git add -A
  git commit -m "Auto-resolve conflicts from '$b' by preferring ${PREFER}" | tee -a "$LOG_FILE" || true
  echo "✅ Resolved & committed: $b" | tee -a "$LOG_FILE"

done < <(branch_list)

echo "⬆️  Pushing ${TARGET_BRANCH}…" | tee -a "$LOG_FILE"
git push origin "${TARGET_BRANCH}" | tee -a "$LOG_FILE"

echo "✅ Done. Pre-merge safety tag: $TAG" | tee -a "$LOG_FILE"
echo "🗒️  Log: $LOG_FILE" | tee -a "$LOG_FILE"

