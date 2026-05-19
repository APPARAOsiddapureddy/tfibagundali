/** Freshness scoring by content type and event timing */

function hoursSince(date) {
  if (!date) return 9999;
  return (Date.now() - new Date(date).getTime()) / 3600000;
}

function daysSince(date) {
  return hoursSince(date) / 24;
}

function clamp01(n) {
  return Math.max(0, Math.min(1, n));
}

function scoreGeneralUpdate(publishedAt, isBreaking) {
  const h = hoursSince(publishedAt);
  if (isBreaking && h <= 6) return 1.0;
  if (h <= 6) return 0.95;
  if (h <= 24) return 0.85;
  if (h <= 72) return 0.65;
  if (daysSince(publishedAt) <= 7) return 0.4;
  return 0.15;
}

function scoreReleaseDate(releaseDate) {
  if (!releaseDate) return 0.3;
  const days = Math.ceil((new Date(releaseDate) - new Date()) / 86400000);
  if (days <= 0) return 0.9;
  if (days <= 7) return 1.0;
  if (days <= 14) return 0.85;
  if (days <= 30) return 0.65;
  if (days <= 60) return 0.45;
  return 0.25;
}

function scoreEventWindow(eventDatetime, publishedAt) {
  if (!eventDatetime) return scoreGeneralUpdate(publishedAt, false);
  const daysToEvent = (new Date(eventDatetime) - new Date()) / 86400000;
  const daysAfter = -daysToEvent;
  if (daysToEvent > 7 && daysToEvent <= 14) return 0.7;
  if (daysToEvent > 1 && daysToEvent <= 7) return 0.9;
  if (daysToEvent >= 0 && daysToEvent <= 1) return 1.0;
  if (daysAfter >= 0 && daysAfter <= 2) return 0.75;
  if (daysAfter > 2 && daysAfter <= 7) return 0.45;
  return scoreGeneralUpdate(publishedAt, false);
}

function scoreBirthdayAnniversary(eventDatetime) {
  if (!eventDatetime) return 0.5;
  const daysTo = (new Date(eventDatetime) - new Date()) / 86400000;
  if (daysTo >= 0 && daysTo <= 1) return 1.0;
  if (daysTo > 1 && daysTo <= 7) return 0.75;
  if (daysTo > 7 && daysTo <= 14) return 0.5;
  return 0.2;
}

function computeFreshness(item) {
  const cat = (item.category || '').toLowerCase();
  const publishedAt = item.published_at || item.created_at;
  const isBreaking = item.is_breaking || item.priority === 'breaking';

  if (item.content_type === 'movie') {
    return scoreReleaseDate(item.release_date);
  }

  if (['release', 'box_office', 'ott'].includes(cat) && item.event_datetime) {
    return Math.max(scoreReleaseDate(item.release_date), scoreEventWindow(item.event_datetime, publishedAt));
  }

  if (['trailer', 'teaser', 'song', 'event', 'movie_launch'].includes(cat)) {
    return scoreEventWindow(item.event_datetime, publishedAt);
  }

  if (['birthday', 'anniversary'].includes(cat)) {
    return scoreBirthdayAnniversary(item.event_datetime || item.birth_date);
  }

  if (item.expires_at && new Date(item.expires_at) < new Date()) {
    return 0.05;
  }

  return scoreGeneralUpdate(publishedAt, isBreaking);
}

module.exports = { computeFreshness, clamp01, hoursSince, daysSince };
