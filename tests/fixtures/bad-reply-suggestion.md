Fixed in `c2fc157`. The search now matches the label.

```suggestion
where: { OR: [{ code: { contains: q } }, { label: { contains: q } }] },
```
