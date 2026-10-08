Fixed in `c2fc157`. The search now matches the label.

Proved by `await expect(listed('?q=dub')).resolves.toEqual({ codes: ['AE'], total: 1 });`.
