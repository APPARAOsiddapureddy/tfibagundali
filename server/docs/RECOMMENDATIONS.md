# TFI Bagundali — Recommendation System (v1)

Hybrid, rule-based recommender: editorial + personalization + freshness + trust + engagement + diversity.

## Philosophy

Recommend **content**, not obligations. No premium, no task-grind, no mission-checklist ranking.

## API

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/recommendations/home` | Sectioned home feed |
| GET | `/v1/home` | Same (alias via home module) |
| GET | `/v1/recommendations/updates` | Personalized updates list |
| GET | `/v1/recommendations/explore` | Wallpapers, cards, collections |
| GET | `/v1/recommendations/quizzes` | Quiz sections |
| GET | `/v1/recommendations/polls` | Poll sections |
| GET | `/v1/recommendations/related?content_type=&content_id=` | Related content |
| GET | `/v1/recommendations/notifications/targets` | Push targeting (auth) |
| POST | `/v1/events` | Track interaction events |
| POST | `/v1/recommendations/content/:type/:id/not-interested` | Negative signal |
| POST | `/v1/recommendations/content/:type/:id/hide` | Hide content |

## Home sections

1. Today in TFI  
2. Trending Now  
3. Mee Hero Updates (if favourite hero)  
4. Upcoming Releases  
5. Today's Movie Trivia  
6. Trending Poll  
7. Wallpapers & Status Cards  
8. Latest Updates  

## Scoring formula

```
final_score =
  freshness * 0.22
+ personal_affinity * 0.24
+ trust * 0.16
+ engagement * 0.14
+ editorial_priority * 0.12
+ actionability * 0.06
+ novelty * 0.04
+ diversity_bonus * 0.02
- repetition - consumed - low_trust - expired - negative
```

## Dev

```bash
cd server
npm run migrate          # applies 002_recommendation_system.sql
npm run seed
curl http://localhost:3001/v1/recommendations/home
```

Sync content feature index:

```bash
curl -X POST http://localhost:3001/v1/recommendations/admin/sync-features
```

## Phase roadmap

- **Phase 1 (current):** Rule-based scoring, sections, events, interest profiles  
- **Phase 2:** Dwell time, richer signals, notification personalization  
- **Phase 3:** Embeddings + ML ranker  
