# Stack notice

Put this at the top of a stacked PR's body, filling in the blocker's PR number and branch:

> **Stacked on #<blocker PR> (`<blocker branch>`).** Merge #<blocker PR> on its own first; GitHub then moves this PR's base to `<default>`. Then merge `origin/<default>` into this branch and run <the profile's **regenerate** row>. Do not use GitHub's "merge stack" button: it rebases this PR and drops the merge commit that carries the regenerated API documents.
