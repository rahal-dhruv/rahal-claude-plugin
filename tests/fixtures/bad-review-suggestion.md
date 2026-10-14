# Review — PR #1 · feat(ORB-1): example

**Instruction:** none

## 1. What the ticket is trying to solve

## 2. What the PR does

## 3. Issues at a glance

Verdict: ready with fixes — 0 blocking, 1 should fix.

## 4. Issues in detail

### 1. Search ignores the label — Should fix · live

<details><summary>Draft GitHub comment</summary>

The search matches the country code only, so `?q=emir` returns no destinations.

```suggestion
where: { OR: [{ code: { contains: q } }, { label: { contains: q } }] },
```

</details>

## 5. Already raised by other reviewers

## 6. Considered and set aside
