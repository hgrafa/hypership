Show current delivery cycle status.

Run these checks and present a concise summary:

1. **Deliveries since last /removedebt:**
   - Read `docs/debt-log.md` for last removedebt date.
   - Count: `git log --oneline --after="[date]" --grep="^feat:"` 
   - If docs/debt-log.md doesn't exist, count all feat commits on current branch.

2. **Recent deliveries:**
   - Read last 5 entries from `docs/delivery-log.md` (if exists).
   - Or: `git log --oneline -10 --grep="^feat:\|^fix:"`

3. **Pending plans:**
   - List files in `docs/plans/` modified in last 7 days.

4. **Recommendation:**
   - If deliveries > 5 since last removedebt:
     "⚠️ [N] features without debt review. Consider `/removedebt since last consolidation`"
   - If deliveries <= 5:
     "✅ Debt cycle healthy. Continue delivering."

Format as a clean summary, not a wall of text.
