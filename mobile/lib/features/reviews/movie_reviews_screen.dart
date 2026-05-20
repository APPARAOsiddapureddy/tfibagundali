import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

// ─── Mock movie data ────────────────────────────────────────────
// TODO: backend — replace with GET /v1/movies?status=released&sort=latest
class MovieReviewData {
  const MovieReviewData({
    required this.id,
    required this.title,
    required this.titleTe,
    required this.hero,
    required this.director,
    required this.posterUrl,
    required this.rating,
    required this.reviewCount,
  });
  final String id, title, titleTe, hero, director, posterUrl;
  final double rating;
  final int reviewCount;
}

const mockReviewMovies = <MovieReviewData>[
  MovieReviewData(
    id: 'peddi', title: 'Peddi', titleTe: 'పెద్ది',
    hero: 'Ram Charan', director: 'Buchi Babu Sana',
    posterUrl: 'https://m.media-amazon.com/images/M/MV5BNWEzOTBlNmUtOGMzNy00ZGZiLWJmNTMtYjRlNzE2YWFmZWI3XkEyXkFqcGc@._V1_QL80_UX400_.jpg',
    rating: 4.3, reviewCount: 1842,
  ),
  MovieReviewData(
    id: 'kuberaa', title: 'Kuberaa', titleTe: 'కుబేర',
    hero: 'Dhanush', director: 'Sekhar Kammula',
    posterUrl: 'https://m.media-amazon.com/images/M/MV5BYWYyZDEwZTEtMWZiMi00YzUwLTkwMzUtNzFmZDI5ZjhjYTYzXkEyXkFqcGc@._V1_QL80_UX400_.jpg',
    rating: 4.1, reviewCount: 956,
  ),
  MovieReviewData(
    id: 'devara', title: 'Devara 2', titleTe: 'దేవర 2',
    hero: 'NTR', director: 'Koratala Siva',
    posterUrl: 'https://m.media-amazon.com/images/M/MV5BZjdkZjI3MTAtMDRkNi00N2JlLTkyYmMtYmM5M2JlYjQwOTAwXkEyXkFqcGc@._V1_QL80_UX400_.jpg',
    rating: 4.5, reviewCount: 3210,
  ),
  MovieReviewData(
    id: 'spirit', title: 'Spirit', titleTe: 'స్పిరిట్',
    hero: 'Prabhas', director: 'Sandeep Reddy Vanga',
    posterUrl: 'https://m.media-amazon.com/images/M/MV5BNTc0YzJhM2YtNjJlYy00YjE2LThjMjAtNzM1MGJiMWUyOGJkXkEyXkFqcGc@._V1_QL80_UX400_.jpg',
    rating: 3.9, reviewCount: 724,
  ),
  MovieReviewData(
    id: 'pushpa', title: 'Pushpa 3', titleTe: 'పుష్ప 3',
    hero: 'Allu Arjun', director: 'Sukumar',
    posterUrl: 'https://m.media-amazon.com/images/M/MV5BYWEyY2FkNWQtNWZlNi00YTVkLTk1YTUtNDU5NzcyMjk4NzI3XkEyXkFqcGc@._V1_QL80_UX400_.jpg',
    rating: 4.7, reviewCount: 5830,
  ),
  MovieReviewData(
    id: 'thandel', title: 'Thandel', titleTe: 'తాండేల్',
    hero: 'Naga Chaitanya', director: 'Chandoo Mondeti',
    posterUrl: 'https://m.media-amazon.com/images/M/MV5BNGI2MmNhNzktNWJkMC00YmM0LTgzNzktMDY3MzZjYjNlOTU3XkEyXkFqcGc@._V1_QL80_UX400_.jpg',
    rating: 3.8, reviewCount: 412,
  ),
];

// ─── Ticket palette ─────────────────────────────────────────────
const _ticketBg1 = Color(0xFFFFF5E0);
const _ticketBg2 = Color(0xFFFFE5B8);
const _ticketDark = Color(0xFF1A0F00);
const _ticketMuted = Color(0x8C1A0F00);
const _ticketDash = Color(0x401A0F00);
const _parentBg = Color(0xFF0B0D17);
const _starGold = Color(0xFFF5A524);
const _ticketSubtle = Color(0xFF8B6A2A);

// ═════════════════════════════════════════════════════════════════
// MovieReviewsScreen — Scrollable list of movie review ticket cards
// ═════════════════════════════════════════════════════════════════
class MovieReviewsScreen extends StatefulWidget {
  const MovieReviewsScreen({super.key});

  @override
  State<MovieReviewsScreen> createState() => _MovieReviewsScreenState();
}

class _MovieReviewsScreenState extends State<MovieReviewsScreen> {
  final _searchController = TextEditingController();
  bool _searchOpen = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MovieReviewData> get _filtered {
    if (_query.isEmpty) return mockReviewMovies;
    final q = _query.toLowerCase();
    return mockReviewMovies.where((m) =>
      m.title.toLowerCase().contains(q) ||
      m.hero.toLowerCase().contains(q) ||
      m.director.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final movies = _filtered;

    return TfiScreen(
      child: Column(
        children: [
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                BackButtonCircle(onTap: () => context.pop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Movie Reviews', style: TfiTokens.display(22)),
                      Text('సినిమా రివ్యూలు', style: TfiTokens.telugu(11, color: TfiTokens.textLo)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _searchOpen = !_searchOpen;
                    if (!_searchOpen) {
                      _searchController.clear();
                      _query = '';
                    }
                  }),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TfiTokens.line),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                      size: 18, color: TfiTokens.textMid,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Search bar ──
          if (_searchOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TfiTokens.line),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 18, color: TfiTokens.textLo),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: TfiTokens.body(14, color: TfiTokens.textHi),
                        decoration: InputDecoration(
                          hintText: 'Search movies…',
                          hintStyle: TfiTokens.body(13, color: TfiTokens.textFaint),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Movie cards ──
          Expanded(
            child: movies.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                    itemCount: movies.length,
                    itemBuilder: (context, i) => _MovieTicketCard(
                      movie: movies[i],
                      onTap: () => context.push('/reviews/${movies[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    TfiTokens.gold.withValues(alpha: 0.15),
                    TfiTokens.fireDeep.withValues(alpha: 0.10),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.search_off_rounded, size: 38, color: TfiTokens.textLo),
            ),
            const SizedBox(height: 20),
            Text('Oops!', style: TfiTokens.display(20, color: TfiTokens.textHi)),
            const SizedBox(height: 8),
            Text(
              "We couldn't find any movie on this name.",
              style: TfiTokens.body(14, color: TfiTokens.textLo),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Try searching with a different name.',
              style: TfiTokens.telugu(12, color: TfiTokens.textFaint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Movie Ticket Card ──────────────────────────────────────────
class _MovieTicketCard extends StatelessWidget {
  const _MovieTicketCard({required this.movie, this.onTap});
  final MovieReviewData movie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Main ticket card ──
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_ticketBg1, _ticketBg2],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top strip: label + rating ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '● TFI BAGUNDALI',
                              style: TfiTokens.body(9, color: _ticketMuted, w: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'MOVIE REVIEW TICKET',
                              style: TfiTokens.mono(10, color: _ticketDark, w: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            movie.rating.toString(),
                            style: TfiTokens.mono(26, color: _ticketDark, w: FontWeight.w800),
                          ),
                          Text(
                            '/5 RATING',
                            style: TfiTokens.body(9, color: _ticketMuted, w: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const _DashedLine(color: _ticketDash),
                  const SizedBox(height: 14),

                  // ── Movie info row ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 72, height: 100,
                          child: Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, e, st) => Container(
                              color: const Color(0x141A0F00),
                              alignment: Alignment.center,
                              child: Icon(Icons.movie_outlined, size: 28, color: _ticketMuted),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: TfiTokens.display(22, color: _ticketDark),
                            ),
                            Text(
                              movie.titleTe,
                              style: TfiTokens.telugu(12, color: _ticketSubtle),
                            ),
                            const SizedBox(height: 8),
                            Text('HERO', style: TfiTokens.body(10, color: _ticketMuted, w: FontWeight.w700)),
                            const SizedBox(height: 1),
                            Text(movie.hero, style: TfiTokens.body(13, color: _ticketDark, w: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('DIRECTOR', style: TfiTokens.body(10, color: _ticketMuted, w: FontWeight.w700)),
                            const SizedBox(height: 1),
                            Text(movie.director, style: TfiTokens.body(12.5, color: const Color(0xFF4A3A1A), w: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const _DashedLine(color: _ticketDash),
                  const SizedBox(height: 10),

                  // ── Bottom strip: stars + count + barcode ──
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StarRow(rating: movie.rating, size: 14),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _fmtCount(movie.reviewCount),
                                    style: TfiTokens.body(11, color: _ticketDark, w: FontWeight.w700),
                                  ),
                                  TextSpan(
                                    text: ' reviews',
                                    style: TfiTokens.body(11, color: _ticketMuted, w: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const _BarcodeStrip(),
                          const SizedBox(width: 8),
                          Text('TFI\nREVIEWS', style: TfiTokens.mono(8, color: _ticketMuted, w: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Perforation notch: LEFT ──
            Positioned(
              left: -10, top: 0, bottom: 0,
              child: Center(
                child: Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(color: _parentBg, shape: BoxShape.circle),
                ),
              ),
            ),

            // ── Perforation notch: RIGHT ──
            Positioned(
              right: -10, top: 0, bottom: 0,
              child: Center(
                child: Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(color: _parentBg, shape: BoxShape.circle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ─────────────────────────────────────────────

String _fmtCount(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, this.size = 14});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Icon(
          Icons.star_rounded,
          size: size,
          color: i < filled ? _starGold : const Color(0x401A0F00),
        ),
      )),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 3.5;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) => SizedBox(
            width: dashWidth, height: 1.5,
            child: DecoratedBox(decoration: BoxDecoration(color: color)),
          )),
        );
      },
    );
  }
}

class _BarcodeStrip extends StatelessWidget {
  const _BarcodeStrip();

  @override
  Widget build(BuildContext context) {
    const widths = [2,3,1,4,2,3,5,2,1,3,4,2,3,1,2,5,3,2,4,1,3,2,4,2];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widths.map((w) => Container(
        width: w.toDouble(), height: 22,
        margin: const EdgeInsets.only(right: 1),
        color: _ticketDark,
      )).toList(),
    );
  }
}
