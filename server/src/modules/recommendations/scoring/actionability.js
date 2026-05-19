/** Score for useful next actions (reminder, vote, quiz, download, share) */

const CATEGORY_ACTIONS = {
  release: ['set_alert', 'follow_movie', 'share'],
  trailer: ['watch_trailer', 'set_alert', 'share', 'poll'],
  teaser: ['watch_trailer', 'share'],
  song: ['share', 'download_card'],
  movie_launch: ['follow_movie', 'share'],
  event: ['set_alert', 'share'],
  birthday: ['download_card', 'share'],
  anniversary: ['download_card', 'share'],
  buzz: ['share'],
};

function computeActionability(item) {
  const actions = new Set(item.action_types || []);
  const cat = (item.category || '').toLowerCase();
  (CATEGORY_ACTIONS[cat] || ['share']).forEach((a) => actions.add(a));

  if (item.content_type === 'poll' && item.is_active !== false) actions.add('vote');
  if (item.content_type === 'quiz') actions.add('play_quiz');
  if (item.content_type === 'wallpaper' || item.content_type === 'status_card') {
    actions.add('download');
    actions.add('share');
  }
  if (item.movie_id || item.release_date) actions.add('set_alert');
  if (item.trailer_youtube_id) actions.add('watch_trailer');

  return Math.min(1, actions.size * 0.18);
}

module.exports = { computeActionability };
