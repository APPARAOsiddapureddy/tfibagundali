const recHome = require('../recommendations/home-feed.service');

/** Home feed — delegates to recommendation engine (sectioned feed). */
async function getHome(userId) {
  return recHome.getHomeFeed(userId);
}

module.exports = { getHome };
