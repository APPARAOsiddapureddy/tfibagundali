/** Recommendation weights & product rules — TFI Bagundali v1 */

const SCORE_WEIGHTS = {
  freshness: 0.22,
  personal_affinity: 0.24,
  trust: 0.16,
  engagement: 0.14,
  editorial_priority: 0.12,
  actionability: 0.06,
  novelty: 0.04,
  diversity_bonus: 0.02,
};

const TRUST_SCORES = {
  official: 1.0,
  verified: 0.85,
  media_report: 0.6,
  buzz: 0.35,
  correction: 0.9,
};

const EDITORIAL_BOOST = {
  breaking: 1.0,
  trending: 0.65,
  important: 0.45,
  normal: 0,
};

const EVENT_WEIGHTS = {
  app_opened: 0,
  update_card_viewed: 1,
  update_opened: 3,
  update_dwell_20s: 5,
  update_reacted: 4,
  update_saved: 8,
  update_shared: 10,
  movie_opened: 3,
  movie_followed: 15,
  movie_reminder_set: 12,
  hero_opened: 3,
  hero_followed: 15,
  poll_viewed: 2,
  poll_voted: 5,
  quiz_started: 3,
  quiz_completed: 6,
  wallpaper_viewed: 2,
  wallpaper_downloaded: 8,
  wallpaper_shared: 10,
  status_card_viewed: 2,
  status_card_downloaded: 8,
  status_card_shared: 10,
  search_performed: 4,
  notification_opened: 3,
  notification_dismissed: -2,
  content_hidden: -25,
  not_interested_clicked: -20,
};

const AFFINITY_WEIGHTS = {
  favourite_hero: 0.35,
  followed_hero: 0.45,
  followed_movie: 0.5,
  saved_related: 0.3,
  reminder_set: 0.4,
  viewed_related_3x: 0.2,
  engaged_related: 0.25,
  quiz_category: 0.12,
  poll_category: 0.12,
  wallpaper_hero: 0.18,
};

const DIVERSITY = {
  max_consecutive_same_hero: 2,
  max_same_category_in_first_10: 3,
  max_buzz_ratio_top_feed: 0.2,
  max_same_movie_in_top_10: 3,
  session_boost_cap: 0.2,
};

const INTEREST_DECAY_DAILY = 0.98;
const HYPE_DECAY_AFTER_EVENT = 0.92;

const QUIZ_SCORE_WEIGHTS = {
  relevance: 0.35,
  freshness: 0.2,
  popularity: 0.15,
  difficulty_fit: 0.1,
  novelty: 0.1,
  completion_quality: 0.1,
};

const POLL_SCORE_WEIGHTS = {
  personal: 0.3,
  active_freshness: 0.2,
  trending: 0.2,
  related_update: 0.15,
  time_left: 0.1,
  novelty: 0.05,
};

const ASSET_SCORE_WEIGHTS = {
  personal: 0.35,
  freshness: 0.15,
  popularity: 0.2,
  event_relevance: 0.2,
  novelty: 0.1,
};

const NOTIFICATION_WEIGHTS = {
  personal: 0.4,
  urgency: 0.2,
  trust: 0.2,
  actionability: 0.1,
  openness: 0.1,
};

const HOME_SECTIONS = [
  { type: 'today_in_tfi', title: 'Today in TFI', subtitle: 'Eeroju cinema updates ikkada', limit: 5 },
  { type: 'breaking_updates', title: 'Breaking / Important', limit: 5 },
  { type: 'my_hero_updates', title: 'Mee Hero Updates', limit: 5 },
  { type: 'trending_updates', title: 'Trending Now', limit: 6 },
  { type: 'upcoming_releases', title: 'Upcoming Releases', limit: 8 },
  { type: 'quiz_preview', title: "Today's Movie Trivia", limit: 3 },
  { type: 'poll_preview', title: 'Trending Poll', limit: 2 },
  { type: 'explore_preview', title: 'Wallpapers & Status Cards', limit: 8 },
  { type: 'movie_calendar', title: 'Movie Calendar', limit: 8 },
];

module.exports = {
  SCORE_WEIGHTS,
  TRUST_SCORES,
  EDITORIAL_BOOST,
  EVENT_WEIGHTS,
  AFFINITY_WEIGHTS,
  DIVERSITY,
  INTEREST_DECAY_DAILY,
  HYPE_DECAY_AFTER_EVENT,
  QUIZ_SCORE_WEIGHTS,
  POLL_SCORE_WEIGHTS,
  ASSET_SCORE_WEIGHTS,
  NOTIFICATION_WEIGHTS,
  HOME_SECTIONS,
};
