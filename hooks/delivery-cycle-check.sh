#!/bin/bash
# delivery-cycle-check.sh
# Runs on Stop event. Checks if debt removal is due.
# Exit 0 = no action. Prints suggestion to stdout for Claude to see.

DEBT_LOG="$CLAUDE_PROJECT_DIR/docs/debt-log.md"
LAST_COMMIT_MSG=$(cd "$CLAUDE_PROJECT_DIR" && git log --oneline -1 2>/dev/null)

# Only trigger after feat commits
echo "$LAST_COMMIT_MSG" | grep -q "^[a-f0-9]* feat:" || exit 0

# Find last removedebt date
if [ -f "$DEBT_LOG" ]; then
    LAST_DATE=$(grep '## \[' "$DEBT_LOG" | sed 's/.*## \[\([0-9-]*\).*/\1/' | tail -1)
    if [ -n "$LAST_DATE" ]; then
        FEAT_COUNT=$(cd "$CLAUDE_PROJECT_DIR" && git log --oneline --after="$LAST_DATE" --grep="^feat:" | wc -l)
    else
        FEAT_COUNT=$(cd "$CLAUDE_PROJECT_DIR" && git log --oneline --grep="^feat:" | wc -l)
    fi
else
    FEAT_COUNT=$(cd "$CLAUDE_PROJECT_DIR" && git log --oneline --grep="^feat:" | wc -l)
fi

if [ "$FEAT_COUNT" -gt 5 ]; then
    echo "📊 $FEAT_COUNT features since last /removedebt. Consider running /removedebt to review accumulated debt."
fi

exit 0
