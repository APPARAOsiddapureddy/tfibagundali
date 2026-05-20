import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/daily_quiz_strip.dart';
import '../../widgets/ticket_update_card.dart';
import '../../widgets/tfi_widgets.dart';

// ─── Mock update data ───────────────────────────────────────────
// IMAGES: Each card uses a LANDSCAPE movie still (16:9 friendly).
// CDN-resized via Amazon _V1_QL75_UX800_ params — no local download needed.
//
// TODO [ADMIN]: When adding new updates, provide a landscape movie still
// (screenshot/frame from trailer) for the card image. Use the helper
// script at scripts/image_url_helper.dart to generate optimized URLs.
// The admin panel should let you preview the image at 16:9 before publishing.
const _mockUpdates = <TicketUpdateData>[
  // Peddi — Ram Charan landscape still from IMDB gallery
  TicketUpdateData(
    title: 'Peddi locks June 4 release',
    summary:
        "Ram Charan's Peddi is set for grand theatrical release. Buchi Babu Sana directs. Music by AR Rahman.",
    timeAgo: '32m ago',
    category: 'RELEASE',
    imageUrl:
        'https://m.media-amazon.com/images/M/MV5BNGI2MmNhNzktNWJkMC00YmM0LTgzNzktMDY3MzZjYjNlOTU3XkEyXkFqcGc@._V1_QL75_UX800_.jpg',
    tags: ['Ram Charan', 'Peddi', 'Buchi Babu'],
    likes: 42100,
  ),
  // Devara 2 — NTR poster from IMDB (tt31629818)
  TicketUpdateData(
    title: 'Devara 2 first look on Aug 1',
    summary:
        'Koratala Siva confirms first look at NTR\'s birthday eve. Trailer to follow within 3 weeks.',
    timeAgo: '2h ago',
    category: 'TRAILER',
    imageUrl:
        'https://m.media-amazon.com/images/M/MV5BZjdkZjI3MTAtMDRkNi00N2JlLTkyYmMtYmM5M2JlYjQwOTAwXkEyXkFqcGc@._V1_QL75_UX800_.jpg',
    tags: ['NTR', 'Koratala Siva', 'Devara 2'],
    likes: 38500,
  ),
  // Spirit — Prabhas landscape still from IMDB gallery
  TicketUpdateData(
    title: 'Spirit final schedule begins in Goa',
    summary:
        'Sandeep Reddy Vanga reportedly starts the climax block. Triptii Dimri joins shoot.',
    timeAgo: '4h ago',
    category: 'SHOOTING',
    imageUrl:
        'https://m.media-amazon.com/images/M/MV5BOGY5NThjZmItNjJlMC00NTc5LTgxMGYtYTgxMDM2N2EzNWYzXkEyXkFqcGc@._V1_QL75_UX800_.jpg',
    tags: ['Prabhas', 'Sandeep Vanga'],
    likes: 21300,
  ),
  // Kuberaa — Dhanush landscape still from IMDB gallery
  TicketUpdateData(
    title: 'Kuberaa secures Netflix premiere',
    summary:
        "Sekhar Kammula's Kuberaa to stream 4 weeks after theatrical run. Dhanush starrer set to break records.",
    timeAgo: '6h ago',
    category: 'OTT',
    imageUrl:
        'https://m.media-amazon.com/images/M/MV5BMDRjZjY2YTMtMjJmMi00NzkyLWJjM2EtYTBhYTViMDczMDg5XkEyXkFqcGc@._V1_QL75_UX800_.jpg',
    tags: ['Dhanush', 'Sekhar Kammula', 'Netflix'],
    likes: 14800,
  ),
  // Pushpa 3 — Allu Arjun poster from IMDB (tt34915500)
  TicketUpdateData(
    title: 'Pushpa 3 muhurat buzz',
    summary:
        'Industry whispers suggest Sukumar–Allu Arjun reunion ready by mid-2027. Awaiting official confirmation.',
    timeAgo: '8h ago',
    category: 'GENERAL',
    imageUrl:
        'https://m.media-amazon.com/images/M/MV5BYWEyY2FkNWQtNWZlNi00YTVkLTk1YTUtNDU5NzcyMjk4NzI3XkEyXkFqcGc@._V1_QL75_UX800_.jpg',
    tags: ['Allu Arjun', 'Sukumar'],
    likes: 9400,
  ),
];

// ─── Mock trending data ─────────────────────────────────────────
// IMAGES: Trending tiles use PORTRAIT POSTERS (2:3 ratio, 400px wide).
// Each movie uses its own poster — not cross-movie.
//
// TODO [ADMIN]: Use portrait movie posters for trending tiles.
// Run posterUrl() from scripts/image_url_helper.dart to generate URLs.
const _mockTrending = [
  (
    'Devara 2',
    'NTR · Koratala Siva',
    '2h',
    // Devara 2 poster (portrait) — IMDB tt31629818
    'https://m.media-amazon.com/images/M/MV5BZjdkZjI3MTAtMDRkNi00N2JlLTkyYmMtYmM5M2JlYjQwOTAwXkEyXkFqcGc@._V1_QL80_UX400_.jpg',
  ),
  (
    'Spirit',
    'Prabhas · Sandeep',
    '4h',
    // Spirit poster (portrait)
    'https://m.media-amazon.com/images/M/MV5BNTc0YzJhM2YtNjJlYy00YjE2LThjMjAtNzM1MGJiMWUyOGJkXkEyXkFqcGc@._V1_QL80_UX400_.jpg',
  ),
  (
    'Kuberaa',
    'Dhanush · Sekhar Kammula',
    '6h',
    // Kuberaa poster (portrait)
    'https://m.media-amazon.com/images/M/MV5BYWYyZDEwZTEtMWZiMi00YzUwLTkwMzUtNzFmZDI5ZjhjYTYzXkEyXkFqcGc@._V1_QL80_UX400_.jpg',
  ),
  (
    'Peddi',
    'Ram Charan · Buchi Babu',
    '8h',
    // Peddi poster (portrait)
    'https://m.media-amazon.com/images/M/MV5BNWEzOTBlNmUtOGMzNy00ZGZiLWJmNTMtYjRlNzE2YWFmZWI3XkEyXkFqcGc@._V1_QL80_UX400_.jpg',
  ),
];

// ─── Mock upcoming releases ─────────────────────────────────────
// IMAGES: Release posters use PORTRAIT POSTERS (2:3 ratio, 400px wide).
// Each movie uses its own poster.
//
// TODO [ADMIN]: Use portrait movie posters for upcoming release tiles.
// Run posterUrl() from scripts/image_url_helper.dart to generate URLs.
const _mockReleases = [
  // Peddi poster
  ('PEDDI', 'పెద్ది', 'Jun 4, 2026', '16 DAYS', 'peddi-id', 'https://m.media-amazon.com/images/M/MV5BNWEzOTBlNmUtOGMzNy00ZGZiLWJmNTMtYjRlNzE2YWFmZWI3XkEyXkFqcGc@._V1_QL80_UX400_.jpg'),
  // Devara 2 poster — IMDB tt31629818
  ('DEVARA 2', 'దేవర 2', 'Aug 15', '89 days', 'devara2-id', 'https://m.media-amazon.com/images/M/MV5BZjdkZjI3MTAtMDRkNi00N2JlLTkyYmMtYmM5M2JlYjQwOTAwXkEyXkFqcGc@._V1_QL80_UX400_.jpg'),
  // Spirit poster
  ('SPIRIT', 'స్పిరిట్', 'Oct 2', '135 days', 'spirit-id', 'https://m.media-amazon.com/images/M/MV5BNTc0YzJhM2YtNjJlYy00YjE2LThjMjAtNzM1MGJiMWUyOGJkXkEyXkFqcGc@._V1_QL80_UX400_.jpg'),
  // Pushpa 3 poster — IMDB tt34915500 (Allu Arjun)
  ('PUSHPA 3', 'పుష్ప 3', 'Sankranthi', '240 days', 'pushpa3-id', 'https://m.media-amazon.com/images/M/MV5BYWEyY2FkNWQtNWZlNi00YTVkLTk1YTUtNDU5NzcyMjk4NzI3XkEyXkFqcGc@._V1_QL80_UX400_.jpg'),
  // Kuberaa poster
  ('KUBERAA', 'కుబేర', 'Jun 20', '32 days', 'kuberaa-id', 'https://m.media-amazon.com/images/M/MV5BYWYyZDEwZTEtMWZiMi00YzUwLTkwMzUtNzFmZDI5ZjhjYTYzXkEyXkFqcGc@._V1_QL80_UX400_.jpg'),
];

// ─── Filters (4th tab = Upcoming Releases) ──────────────────────
const _filterLabels = ['All', 'My Hero', 'Movie Reviews', 'Upcoming Releases'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.userName});
  final String? userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeFilter = 0;

  /// Mock-filtered list based on active filter.
  List<TicketUpdateData> get _filteredUpdates {
    if (_activeFilter == 0) return _mockUpdates; // All
    if (_activeFilter == 1) {
      // My Hero — mock: show cards 0 & 2 (Ram Charan, Prabhas)
      return [_mockUpdates[0], _mockUpdates[2]];
    }
    if (_activeFilter == 2) {
      // Movie Reviews — mock: show cards 1 & 3
      return [_mockUpdates[1], _mockUpdates[3]];
    }
    // Upcoming Releases (index 3) — handled separately, returns empty
    return [];
  }

  /// Whether the "Upcoming Releases" tab is active.
  bool get _isReleasesTab => _activeFilter == 3;

  @override
  Widget build(BuildContext context) {
    final updates = _filteredUpdates;

    return TfiScreen(
      child: CustomScrollView(
        slivers: [
          // ── Top bar (greeting) ──
          SliverToBoxAdapter(
            child: TfiTopBar(user: widget.userName ?? 'Fan'),
          ),

          // ── Daily quiz strip ──
          SliverToBoxAdapter(
            child: DailyQuizStrip(
              onTap: () => _navigateToQuiz(context),
            ),
          ),

          // ── Filter chips (scrollable) ──
          SliverToBoxAdapter(
            child: _buildFilterChips(),
          ),

          // ── Feed content ──
          if (_isReleasesTab)
            // Show upcoming releases grid
            SliverToBoxAdapter(child: _buildReleasesGrid())
          else
            SliverList(
              delegate: SliverChildListDelegate(
                _buildFeedItems(updates),
              ),
            ),

          // Bottom padding for tab bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  /// Navigate to the Quiz tab (index 1 in the shell).
  void _navigateToQuiz(BuildContext context) {
    context.go('/quiz');
  }

  /// Build scrollable filter chip row.
  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        itemCount: _filterLabels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == _activeFilter;
          return GestureDetector(
            onTap: () {
              if (i == 2) {
                // Movie Reviews chip → navigate to reviews screen
                context.push('/reviews');
              } else {
                setState(() => _activeFilter = i);
              }
            },
            child: TfiChip(
              label: _filterLabels[i],
              active: active,
              color: TfiTokens.fire,
            ),
          );
        },
      ),
    );
  }

  /// Build the interleaved feed: cards + trending section.
  List<Widget> _buildFeedItems(List<TicketUpdateData> updates) {
    final items = <Widget>[];

    // Card 1
    if (updates.isNotEmpty) {
      items.add(TicketUpdateCard(data: updates[0]));
    }

    // Card 2
    if (updates.length > 1) {
      items.add(TicketUpdateCard(data: updates[1]));
    }

    // ── Trending Now section ──
    if (_activeFilter == 0) {
      items.add(_buildTrendingSection());
    }

    // Remaining cards
    for (int i = 2; i < updates.length; i++) {
      items.add(TicketUpdateCard(data: updates[i]));
    }

    return items;
  }

  /// Redesigned trending section — taller cards with poster images, title overlay.
  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        SectionTitle(
          title: 'Trending Now',
          telugu: 'ట్రెండింగ్ ఇప్పుడు',
          action: 'See all',
          onAction: () => context.push('/updates'),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mockTrending.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final t = _mockTrending[i];
              return _TrendingCard(
                title: t.$1,
                subtitle: t.$2,
                timeAgo: t.$3,
                imageUrl: t.$4,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Build the Upcoming Releases grid (shown when 4th filter tab is active).
  Widget _buildReleasesGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'రాబోయే విడుదలలు',
            style: TfiTokens.telugu(12, color: TfiTokens.textLo),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
            ),
            itemCount: _mockReleases.length,
            itemBuilder: (context, i) {
              final r = _mockReleases[i];
              return GestureDetector(
                onTap: () => context.push('/movies/${r.$5}'),
                child: _ReleasePoster(
                  title: r.$1,
                  telugu: r.$2,
                  date: r.$3,
                  countdown: r.$4,
                  imageUrl: r.$6,
                  isUrgent: i == 0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Redesigned trending card with image background.
class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // Generate fallback gradient from title
    final hash = title.codeUnits.fold(0, (a, b) => a + b);
    final gradients = [
      [const Color(0xFFFF7A1A), const Color(0xFFE63950), const Color(0xFF1B1530)],
      [const Color(0xFF8B5CF6), const Color(0xFF2563EB), const Color(0xFF0B0E1A)],
      [const Color(0xFFF59E0B), const Color(0xFFDC2626), const Color(0xFF1B1530)],
    ];
    final fallbackColors = gradients[hash % 3];

    return Container(
      width: 155,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: imageUrl.isEmpty
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: fallbackColors,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image or gradient
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, e, st) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: fallbackColors,
                  ),
                ),
              ),
            ),

          // Dark gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Trending badge
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TfiTokens.fire.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Trending',
                    style: TfiTokens.body(10, color: Colors.white, w: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),

          // Bottom content
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TfiTokens.display(16, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TfiTokens.body(11, color: Colors.white70, w: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$timeAgo ago',
                  style: TfiTokens.mono(9, color: TfiTokens.goldWarm, w: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Release poster card with real movie image and countdown badge.
class _ReleasePoster extends StatelessWidget {
  const _ReleasePoster({
    required this.title,
    required this.telugu,
    required this.date,
    required this.countdown,
    required this.imageUrl,
    this.isUrgent = false,
  });

  final String title;
  final String telugu;
  final String date;
  final String countdown;
  final String imageUrl;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    // Fallback gradient
    final hash = title.codeUnits.fold(0, (a, b) => a + b);
    final gradients = [
      [const Color(0xFFFF7A1A), const Color(0xFFE63950), const Color(0xFF1B1530)],
      [const Color(0xFF8B5CF6), const Color(0xFF2563EB), const Color(0xFF0B0E1A)],
      [const Color(0xFFF59E0B), const Color(0xFFDC2626), const Color(0xFF1B1530)],
    ];
    final fallbackColors = gradients[hash % 3];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: imageUrl.isEmpty
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: fallbackColors,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, e, st) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: fallbackColors,
                  ),
                ),
              ),
            ),

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Countdown badge (top)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? TfiTokens.fireDeep.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUrgent ? Icons.access_time_filled_rounded : Icons.calendar_today_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        countdown,
                        style: TfiTokens.mono(9, color: Colors.white, w: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Title + date (bottom)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TfiTokens.display(15, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  telugu,
                  style: TfiTokens.telugu(10, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: TfiTokens.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: TfiTokens.gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    date,
                    style: TfiTokens.mono(10, color: TfiTokens.goldWarm, w: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
