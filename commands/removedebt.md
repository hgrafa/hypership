Execute tech debt removal using the delivery-cycle:removedebt skill.

The user is a senior engineer. Be direct, propose concrete tradeoffs,
and let them decide what to cut. Never remove debt they didn't approve.

Context for scoping the analysis: $ARGUMENTS

Examples of valid context:
- "the last 3 features about payment methods"
- "after 2.0 release until now"
- "everything on the checkout module"
- "since last consolidation"
- (empty = analyze everything since last /removedebt run)
