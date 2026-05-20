import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

// ─── Mock data ──────────────────────────────────────────────────
// TODO: backend — replace with GET /v1/movies/:id and GET /v1/movies/:id/reviews

class _MovieData {
  const _MovieData({
    required this.id, required this.title, required this.titleTe,
    required this.hero, required this.director, required this.posterUrl,
    required this.rating, required this.reviewCount,
  });
  final String id, title, titleTe, hero, director, posterUrl;
  final double rating;
  final int reviewCount;
}

class _ReviewData {
  const _ReviewData({
    required this.id, required this.user, required this.rating,
    required this.text, required this.hashtags, required this.time,
  });
  final String id, user, text, time;
  final int rating;
  final List<String> hashtags;
}

const _allMovies = <String, _MovieData>{
  'peddi': _MovieData(id: 'peddi', title: 'Peddi', titleTe: 'పెద్ది', hero: 'Ram Charan', director: 'Buchi Babu Sana', posterUrl: 'https://m.media-amazon.com/images/M/MV5BNWEzOTBlNmUtOGMzNy00ZGZiLWJmNTMtYjRlNzE2YWFmZWI3XkEyXkFqcGc@._V1_QL80_UX400_.jpg', rating: 4.3, reviewCount: 1842),
  'kuberaa': _MovieData(id: 'kuberaa', title: 'Kuberaa', titleTe: 'కుబేర', hero: 'Dhanush', director: 'Sekhar Kammula', posterUrl: 'https://m.media-amazon.com/images/M/MV5BYWYyZDEwZTEtMWZiMi00YzUwLTkwMzUtNzFmZDI5ZjhjYTYzXkEyXkFqcGc@._V1_QL80_UX400_.jpg', rating: 4.1, reviewCount: 956),
  'devara': _MovieData(id: 'devara', title: 'Devara 2', titleTe: 'దేవర 2', hero: 'NTR', director: 'Koratala Siva', posterUrl: 'https://m.media-amazon.com/images/M/MV5BZjdkZjI3MTAtMDRkNi00N2JlLTkyYmMtYmM5M2JlYjQwOTAwXkEyXkFqcGc@._V1_QL80_UX400_.jpg', rating: 4.5, reviewCount: 3210),
  'spirit': _MovieData(id: 'spirit', title: 'Spirit', titleTe: 'స్పిరిట్', hero: 'Prabhas', director: 'Sandeep Reddy Vanga', posterUrl: 'https://m.media-amazon.com/images/M/MV5BNTc0YzJhM2YtNjJlYy00YjE2LThjMjAtNzM1MGJiMWUyOGJkXkEyXkFqcGc@._V1_QL80_UX400_.jpg', rating: 3.9, reviewCount: 724),
  'pushpa': _MovieData(id: 'pushpa', title: 'Pushpa 3', titleTe: 'పుష్ప 3', hero: 'Allu Arjun', director: 'Sukumar', posterUrl: 'https://m.media-amazon.com/images/M/MV5BYWEyY2FkNWQtNWZlNi00YTVkLTk1YTUtNDU5NzcyMjk4NzI3XkEyXkFqcGc@._V1_QL80_UX400_.jpg', rating: 4.7, reviewCount: 5830),
  'thandel': _MovieData(id: 'thandel', title: 'Thandel', titleTe: 'తాండేల్', hero: 'Naga Chaitanya', director: 'Chandoo Mondeti', posterUrl: 'https://m.media-amazon.com/images/M/MV5BNGI2MmNhNzktNWJkMC00YmM0LTgzNzktMDY3MzZjYjNlOTU3XkEyXkFqcGc@._V1_QL80_UX400_.jpg', rating: 3.8, reviewCount: 412),
};

const _allReviews = <String, List<_ReviewData>>{
  'peddi': [
    _ReviewData(id: 'r1', user: 'Ravi Kumar', rating: 5, text: 'Ram Charan at his absolute best. The interval block gave me goosebumps. Buchi Babu delivered a masterpiece!', hashtags: ['MassMovie', 'Blockbuster', 'IntervalFire'], time: '2h ago'),
    _ReviewData(id: 'r2', user: 'Priya Reddy', rating: 4, text: 'Loved the visuals and BGM. Story could have been tighter in the second half, but overall a great watch.', hashtags: ['BGMKing', 'VisualsTop', 'MustWatch'], time: '5h ago'),
    _ReviewData(id: 'r3', user: 'Suresh Babu', rating: 5, text: 'What a performance by Charan! Every scene is packed with emotion and mass. AR Rahman BGM is fire.', hashtags: ['Blockbuster', 'Emotional'], time: '8h ago'),
    _ReviewData(id: 'r4', user: 'Lakshmi Devi', rating: 3, text: 'Good first half, but second half dragged a bit. Songs are fantastic though.', hashtags: ['DecentMovie', 'GoodSongs'], time: '1d ago'),
    _ReviewData(id: 'r5', user: 'Karthik Varma', rating: 5, text: 'Paisa vasool! Mass + class combo. Theatre lo chudalsinde movie. Mind blowing climax!', hashtags: ['PaisaVasool', 'MassMovie', 'ClimaxFire'], time: '1d ago'),
  ],
  'kuberaa': [
    _ReviewData(id: 'r6', user: 'Venkat Rao', rating: 4, text: 'Sekhar Kammula class touch with Dhanush raw energy. A unique combo that works really well.', hashtags: ['ClassMovie', 'MustWatch'], time: '3h ago'),
    _ReviewData(id: 'r7', user: 'Anjali S', rating: 4, text: 'Beautifully shot, emotionally gripping. Dhanush nailed the Telugu accent!', hashtags: ['Emotional', 'MustWatch'], time: '1d ago'),
  ],
  'devara': [
    _ReviewData(id: 'r8', user: 'Mahesh Fan', rating: 5, text: 'NTR is the definition of screen presence. Devara 2 is even better than the first part!', hashtags: ['Blockbuster', 'MassMovie'], time: '1h ago'),
    _ReviewData(id: 'r9', user: 'Sai Teja', rating: 4, text: 'Action sequences are on another level. Koratala Siva upped his game massively.', hashtags: ['ActionPacked', 'VisualsTop'], time: '4h ago'),
    _ReviewData(id: 'r10', user: 'Deepika M', rating: 5, text: 'Anirudh BGM + NTR combo is unbeatable. Every single frame is a wallpaper!', hashtags: ['BGMKing', 'MassMovie'], time: '6h ago'),
  ],
  'spirit': [
    _ReviewData(id: 'r11', user: 'Prabhas Fan', rating: 4, text: 'Prabhas in a completely new avatar. Sandeep Vanga extracted the best out of him.', hashtags: ['MustWatch', 'Emotional'], time: '5h ago'),
    _ReviewData(id: 'r12', user: 'Kishore K', rating: 3, text: 'A bit too violent for my taste, but the filmmaking is top-notch.', hashtags: ['IntenseMovie'], time: '1d ago'),
  ],
  'pushpa': [
    _ReviewData(id: 'r13', user: 'Bunny Fan', rating: 5, text: 'Pushpa 3 is the best in the franchise. Allu Arjun owns every frame. Sukumar genius!', hashtags: ['Blockbuster', 'MassMovie'], time: '30m ago'),
    _ReviewData(id: 'r14', user: 'Ramya T', rating: 5, text: 'Climax will give you chills. The character arc of Pushpa Raj is complete perfection.', hashtags: ['ClimaxFire', 'PaisaVasool'], time: '2h ago'),
    _ReviewData(id: 'r15', user: 'Naveen G', rating: 4, text: 'Songs, fights, emotions — everything is balanced perfectly. Definitely a repeat watch!', hashtags: ['RepeatWatch', 'Blockbuster'], time: '1d ago'),
  ],
  'thandel': [
    _ReviewData(id: 'r16', user: 'Chay Fan', rating: 4, text: 'Naga Chaitanya surprised everyone with this intense role. Chandoo Mondeti delivered again!', hashtags: ['Emotional', 'MustWatch'], time: '3h ago'),
    _ReviewData(id: 'r17', user: 'Swathi R', rating: 4, text: 'Based on a true story and it hits you right in the feels. Great performances all around.', hashtags: ['Emotional', 'TrueStory'], time: '8h ago'),
  ],
};

const _popularHashtags = [
  'MassMovie', 'Blockbuster', 'Emotional', 'MustWatch',
  'BGMKing', 'VisualsTop', 'PaisaVasool', 'ClimaxFire',
];

// ─── Ticket palette ─────────────────────────────────────────────
const _ticketBg1 = Color(0xFFFFF5E0);
const _ticketBg2 = Color(0xFFFFE5B8);
const _ticketDark = Color(0xFF1A0F00);
const _ticketMuted = Color(0x8C1A0F00);
const _ticketDash = Color(0x401A0F00);
const _parentBg = Color(0xFF0B0D17);
const _starGold = Color(0xFFF5A524);

// ═════════════════════════════════════════════════════════════════
// MovieReviewDetailScreen
// ═════════════════════════════════════════════════════════════════
class MovieReviewDetailScreen extends StatefulWidget {
  const MovieReviewDetailScreen({super.key, required this.movieId});
  final String movieId;

  @override
  State<MovieReviewDetailScreen> createState() => _MovieReviewDetailScreenState();
}

class _MovieReviewDetailScreenState extends State<MovieReviewDetailScreen> {
  int _userRating = 0;

  _MovieData get _movie => _allMovies[widget.movieId] ?? _allMovies['peddi']!;
  List<_ReviewData> get _reviews => _allReviews[widget.movieId] ?? [];

  void _showWriteReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WriteReviewSheet(movie: _movie),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie;
    final reviews = _reviews;

    return TfiScreen(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero poster banner ──
                _buildPosterBanner(movie),

                // ── Ticket info card (overlapping) ──
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: _buildTicketInfoCard(movie),
                ),

                // ── Reviews section ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fan Reviews', style: TfiTokens.display(18)),
                            Text('అభిమాన రివ్యూలు', style: TfiTokens.telugu(11, color: TfiTokens.textLo)),
                          ],
                        ),
                      ),
                      Text('${reviews.length} reviews',
                        style: TfiTokens.body(12, color: TfiTokens.gold, w: FontWeight.w700)),
                    ],
                  ),
                ),

                // ── Review cards ──
                ...reviews.map((r) => _buildReviewCard(r)),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // ── Floating + FAB ──
          Positioned(
            bottom: 24, right: 22,
            child: GestureDetector(
              onTap: _showWriteReviewSheet,
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB52E), Color(0xFFE5484D)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TfiTokens.gold.withValues(alpha: 0.5),
                      blurRadius: 28, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Poster banner ──
  Widget _buildPosterBanner(_MovieData movie) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            movie.posterUrl, fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, e, st) => Container(
              decoration: const BoxDecoration(gradient: TfiTokens.gradFire),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.05),
                  TfiTokens.bg1.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          // Back + share buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassButton(Icons.arrow_back_ios_new_rounded, () => context.pop()),
                _glassButton(Icons.share_rounded, () {}),
              ],
            ),
          ),
          // Movie name
          Positioned(
            left: 18, right: 18, bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title, style: TfiTokens.display(32, color: Colors.white)),
                const SizedBox(height: 4),
                Text(movie.titleTe, style: TfiTokens.telugu(14, color: TfiTokens.goldWarm)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  // ── Ticket info card ──
  Widget _buildTicketInfoCard(_MovieData movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [_ticketBg1, _ticketBg2],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 28, offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              children: [
                // Row 1: Hero + Director
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HERO', style: TfiTokens.body(10, color: _ticketMuted, w: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(movie.hero, style: TfiTokens.body(15, color: _ticketDark, w: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('DIRECTOR', style: TfiTokens.body(10, color: _ticketMuted, w: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(movie.director, style: TfiTokens.body(14, color: const Color(0xFF4A3A1A), w: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const _DashedLine(color: _ticketDash),
                const SizedBox(height: 14),

                // Row 2: Rating section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big number
                    Column(
                      children: [
                        Text(movie.rating.toString(), style: TfiTokens.mono(42, color: _ticketDark, w: FontWeight.w800)),
                        Text('OUT OF 5', style: TfiTokens.body(10, color: _ticketMuted, w: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Stars + distribution
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StarRow(rating: movie.rating, size: 18),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(text: 'Based on ', style: TfiTokens.body(12, color: _ticketMuted, w: FontWeight.w600)),
                              TextSpan(text: _fmtCount(movie.reviewCount), style: TfiTokens.body(12, color: _ticketDark, w: FontWeight.w700)),
                              TextSpan(text: ' reviews', style: TfiTokens.body(12, color: _ticketMuted, w: FontWeight.w600)),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          // Distribution bars
                          ...[
                            (5, 58), (4, 24), (3, 10), (2, 5), (1, 3),
                          ].map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                  child: Text('${d.$1}', style: TfiTokens.body(9, color: _ticketMuted, w: FontWeight.w700), textAlign: TextAlign.right),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: SizedBox(
                                      height: 5,
                                      child: Stack(
                                        children: [
                                          Container(color: const Color(0x181A0F00)),
                                          FractionallySizedBox(
                                            widthFactor: d.$2 / 100,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(colors: [_starGold, Color(0xFFE5484D)]),
                                                borderRadius: BorderRadius.all(Radius.circular(3)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 28,
                                  child: Text('${d.$2}%', style: TfiTokens.body(9, color: _ticketMuted, w: FontWeight.w600)),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const _DashedLine(color: _ticketDash),
                const SizedBox(height: 14),

                // Row 3: User rating
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userRating > 0 ? 'YOUR RATING' : 'TAP TO RATE',
                            style: TfiTokens.body(10, color: _ticketMuted, w: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          // TODO: backend — POST /v1/movies/:id/rating { rating: N }
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) => GestureDetector(
                              onTap: () => setState(() => _userRating = i + 1),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.star_rounded, size: 28,
                                  color: i < _userRating ? _starGold : const Color(0x351A0F00),
                                ),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const _BarcodeStrip(),
                        const SizedBox(width: 8),
                        Text('TFI\nRATE', style: TfiTokens.mono(8, color: _ticketMuted, w: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Perforation notches
          Positioned(left: -10, top: 0, bottom: 0, child: Center(
            child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: _parentBg, shape: BoxShape.circle)),
          )),
          Positioned(right: -10, top: 0, bottom: 0, child: Center(
            child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: _parentBg, shape: BoxShape.circle)),
          )),
        ],
      ),
    );
  }

  // ── Review card ──
  Widget _buildReviewCard(_ReviewData review) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF14172A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TfiTokens.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User row
            Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      TfiTokens.gold.withValues(alpha: 0.3),
                      TfiTokens.purple.withValues(alpha: 0.3),
                    ]),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    review.user.isNotEmpty ? review.user[0] : 'U',
                    style: TfiTokens.display(13, color: TfiTokens.textHi),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.user, style: TfiTokens.body(13, color: TfiTokens.textHi, w: FontWeight.w700)),
                      Text(review.time, style: TfiTokens.body(10.5, color: TfiTokens.textLo)),
                    ],
                  ),
                ),
                _StarRow(rating: review.rating.toDouble(), size: 11),
              ],
            ),
            const SizedBox(height: 10),
            // Text
            Text(review.text, style: TfiTokens.body(13, color: TfiTokens.textMid)),
            const SizedBox(height: 8),
            // Hashtags
            if (review.hashtags.isNotEmpty)
              Wrap(
                spacing: 6, runSpacing: 4,
                children: review.hashtags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: TfiTokens.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: TfiTokens.gold.withValues(alpha: 0.3)),
                  ),
                  child: Text('#$tag', style: TfiTokens.body(11, color: TfiTokens.goldWarm, w: FontWeight.w700)),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// Write Review Bottom Sheet
// ═════════════════════════════════════════════════════════════════
class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet({required this.movie});
  final _MovieData movie;

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 0;
  final _textController = TextEditingController();
  final _hashtagController = TextEditingController();
  final _selectedTags = <String>[];

  @override
  void dispose() {
    _textController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final clean = tag.replaceAll('#', '').trim();
    if (clean.isNotEmpty && !_selectedTags.contains(clean)) {
      setState(() => _selectedTags.add(clean));
    }
    _hashtagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final movie = widget.movie;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF0141728),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Write Your Review', style: TfiTokens.display(20, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('నీ అభిప్రాయం రాయి', style: TfiTokens.telugu(12, color: TfiTokens.goldWarm)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: TfiTokens.line),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Movie context
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TfiTokens.line),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 42, height: 56,
                      child: Image.network(movie.posterUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: TfiTokens.body(14, color: Colors.white, w: FontWeight.w700)),
                      Text('${movie.hero} · ${movie.director}', style: TfiTokens.body(11.5, color: TfiTokens.textLo)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Star rating
            Text('YOUR RATING', style: TfiTokens.body(10.5, color: TfiTokens.textLo, w: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: TfiTokens.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TfiTokens.gold.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  ...List.generate(5, (i) => GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.star_rounded, size: 30,
                        color: i < _rating ? _starGold : Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  )),
                  const Spacer(),
                  if (_rating > 0)
                    Text('$_rating/5', style: TfiTokens.body(13, color: TfiTokens.gold, w: FontWeight.w700)),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Text input
            Text('YOUR PERCEPTION', style: TfiTokens.body(10.5, color: TfiTokens.textLo, w: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TfiTokens.line),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                style: TfiTokens.body(13.5, color: TfiTokens.textHi),
                decoration: InputDecoration(
                  hintText: 'Share your perception… నీ అభిప్రాయం రాయి',
                  hintStyle: TfiTokens.body(13, color: TfiTokens.textFaint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Hashtag section
            Text('ADD HASHTAGS', style: TfiTokens.body(10.5, color: TfiTokens.textLo, w: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TfiTokens.line),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Text('#', style: TfiTokens.body(16, color: TfiTokens.gold, w: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _hashtagController,
                      style: TfiTokens.body(13, color: TfiTokens.textHi),
                      decoration: InputDecoration(
                        hintText: 'Type to add hashtag…',
                        hintStyle: TfiTokens.body(13, color: TfiTokens.textFaint),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (v) => _addTag(v),
                    ),
                  ),
                ],
              ),
            ),

            // Selected tags
            if (_selectedTags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: _selectedTags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: TfiTokens.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: TfiTokens.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('#$tag', style: TfiTokens.body(11, color: TfiTokens.goldWarm, w: FontWeight.w700)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _selectedTags.remove(tag)),
                        child: Icon(Icons.close_rounded, size: 13, color: TfiTokens.goldWarm.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],

            // Popular suggestions
            const SizedBox(height: 10),
            Text('POPULAR', style: TfiTokens.body(10, color: TfiTokens.textFaint, w: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _popularHashtags
                  .where((t) => !_selectedTags.contains(t))
                  .map((tag) => GestureDetector(
                onTap: () => _addTag(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: TfiTokens.line),
                  ),
                  child: Text('#$tag', style: TfiTokens.body(11, color: TfiTokens.textMid, w: FontWeight.w600)),
                ),
              )).toList(),
            ),

            const SizedBox(height: 20),

            // Submit CTA
            // TODO: backend — POST /v1/movies/:id/reviews { rating, text, hashtags }
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A0F00), Color(0xFF2B1900)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A0F00).withValues(alpha: 0.45),
                      blurRadius: 22, offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 18, color: TfiTokens.goldWarm),
                    const SizedBox(width: 8),
                    Text('Post Review', style: TfiTokens.body(15, color: TfiTokens.goldWarm, w: FontWeight.w800)),
                  ],
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
          Icons.star_rounded, size: size,
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
