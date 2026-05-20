/* TFI Bagundali — Movie Reviews Section
   Ticket-stub aesthetic (warm golden cards) matching OTP/Auth screens.
   Frontend only — TODO comments mark where backend APIs will plug in. */

// ───────── Mock Data ─────────

// TODO: backend — replace with GET /v1/movies?status=released&sort=latest
const REVIEW_MOVIES = [
  {
    id: 'peddi',
    title: 'Peddi',
    titleTe: 'పెద్ది',
    hero: 'Ram Charan',
    director: 'Buchi Babu Sana',
    posterClass: 'peddi',
    rating: 4.3,
    reviewCount: 1842,
    releaseDate: 'Jun 4, 2026',
  },
  {
    id: 'kuberaa',
    title: 'Kuberaa',
    titleTe: 'కుబేర',
    hero: 'Dhanush',
    director: 'Sekhar Kammula',
    posterClass: 'kuberaa',
    rating: 4.1,
    reviewCount: 956,
    releaseDate: 'Jun 20, 2026',
  },
  {
    id: 'devara',
    title: 'Devara 2',
    titleTe: 'దేవర 2',
    hero: 'NTR',
    director: 'Koratala Siva',
    posterClass: 'devara',
    rating: 4.5,
    reviewCount: 3210,
    releaseDate: 'Aug 15, 2026',
  },
  {
    id: 'spirit',
    title: 'Spirit',
    titleTe: 'స్పిరిట్',
    hero: 'Prabhas',
    director: 'Sandeep Reddy Vanga',
    posterClass: 'spirit',
    rating: 3.9,
    reviewCount: 724,
    releaseDate: 'Oct 2, 2026',
  },
  {
    id: 'pushpa',
    title: 'Pushpa 3',
    titleTe: 'పుష్ప 3',
    hero: 'Allu Arjun',
    director: 'Sukumar',
    posterClass: 'pushpa',
    rating: 4.7,
    reviewCount: 5830,
    releaseDate: 'Sankranthi 2027',
  },
  {
    id: 'thandel',
    title: 'Thandel',
    titleTe: 'తాండేల్',
    hero: 'Naga Chaitanya',
    director: 'Chandoo Mondeti',
    posterClass: 'thandel',
    rating: 3.8,
    reviewCount: 412,
    releaseDate: 'May 2, 2026',
  },
];

// TODO: backend — replace with GET /v1/movies/:id/reviews
const MOCK_REVIEWS = {
  peddi: [
    { id: 'r1', user: 'Ravi Kumar', rating: 5, text: 'Ram Charan at his absolute best. The interval block gave me goosebumps. Buchi Babu delivered a masterpiece!', hashtags: ['MassMovie', 'Blockbuster', 'IntervalFire'], time: '2h ago' },
    { id: 'r2', user: 'Priya Reddy', rating: 4, text: 'Loved the visuals and BGM. Story could have been tighter in the second half, but overall a great watch.', hashtags: ['BGMKing', 'VisualsTop', 'MustWatch'], time: '5h ago' },
    { id: 'r3', user: 'Suresh Babu', rating: 5, text: 'What a performance by Charan! Every scene is packed with emotion and mass. AR Rahman BGM is fire.', hashtags: ['Blockbuster', 'Emotional', 'ARRahmanMagic'], time: '8h ago' },
    { id: 'r4', user: 'Lakshmi Devi', rating: 3, text: 'Good first half, but second half dragged a bit. Songs are fantastic though.', hashtags: ['DecentMovie', 'GoodSongs'], time: '1d ago' },
    { id: 'r5', user: 'Karthik Varma', rating: 5, text: 'Paisa vasool! Mass + class combo. Theatre lo chudalsinde movie. Mind blowing climax!', hashtags: ['PaisaVasool', 'MassMovie', 'ClimaxFire'], time: '1d ago' },
  ],
  kuberaa: [
    { id: 'r6', user: 'Venkat Rao', rating: 4, text: 'Sekhar Kammula class touch with Dhanush raw energy. A unique combo that works really well.', hashtags: ['ClassMovie', 'DhanushMass'], time: '3h ago' },
    { id: 'r7', user: 'Anjali S', rating: 4, text: 'Beautifully shot, emotionally gripping. Dhanush nailed the Telugu accent!', hashtags: ['Emotional', 'MustWatch'], time: '1d ago' },
  ],
  devara: [
    { id: 'r8', user: 'Mahesh Fan', rating: 5, text: 'NTR is the definition of screen presence. Devara 2 is even better than the first part!', hashtags: ['NTRMass', 'Blockbuster', 'SequelDone Right'], time: '1h ago' },
    { id: 'r9', user: 'Sai Teja', rating: 4, text: 'Action sequences are on another level. Koratala Siva upped his game massively.', hashtags: ['ActionPacked', 'VisualsTop'], time: '4h ago' },
    { id: 'r10', user: 'Deepika M', rating: 5, text: 'Anirudh BGM + NTR combo is unbeatable. Every single frame is a wallpaper!', hashtags: ['BGMFire', 'CinematographyGoals', 'MassMovie'], time: '6h ago' },
  ],
  spirit: [
    { id: 'r11', user: 'Prabhas Army', rating: 4, text: 'Prabhas in a completely new avatar. Sandeep Vanga extracted the best out of him.', hashtags: ['NewPrabhas', 'DarkMovie', 'MustWatch'], time: '5h ago' },
    { id: 'r12', user: 'Kishore K', rating: 3, text: 'A bit too violent for my taste, but the filmmaking is top-notch.', hashtags: ['IntenseMovie', 'NotForAll'], time: '1d ago' },
  ],
  pushpa: [
    { id: 'r13', user: 'Bunny Fan', rating: 5, text: 'Pushpa 3 is the best in the franchise. Allu Arjun owns every frame. Sukumar genius!', hashtags: ['Blockbuster', 'AlluArjunMass', 'SukumarMagic'], time: '30m ago' },
    { id: 'r14', user: 'Ramya T', rating: 5, text: 'Climax will give you chills. The character arc of Pushpa Raj is complete perfection.', hashtags: ['ClimaxFire', 'MassMovie', 'PaisaVasool'], time: '2h ago' },
    { id: 'r15', user: 'Naveen G', rating: 4, text: 'Songs, fights, emotions — everything is balanced perfectly. Definitely a repeat watch!', hashtags: ['RepeatWatch', 'Blockbuster'], time: '1d ago' },
  ],
  thandel: [
    { id: 'r16', user: 'Chay Fan', rating: 4, text: 'Naga Chaitanya surprised everyone with this intense role. Chandoo Mondeti delivered again!', hashtags: ['Surprise', 'IntenseMovie'], time: '3h ago' },
    { id: 'r17', user: 'Swathi R', rating: 4, text: 'Based on a true story and it hits you right in the feels. Great performances all around.', hashtags: ['Emotional', 'TrueStory', 'MustWatch'], time: '8h ago' },
  ],
};

// Popular hashtag suggestions for the write review sheet
const POPULAR_HASHTAGS = [
  'MassMovie', 'Blockbuster', 'Emotional', 'MustWatch', 'IntervalFire',
  'ClimaxFire', 'BGMKing', 'VisualsTop', 'PaisaVasool', 'RepeatWatch',
  'ActionPacked', 'FamilyMovie', 'ClassMovie', 'DarkMovie', 'FeelGood',
  'DirectorSpecial', 'DecentMovie', 'GoodSongs', 'CinematographyGoals',
];

// ───────── Helper: Star Rating (static display) ─────────
const Stars = ({ rating, size = 14, gap = 2 }) => (
  <div style={{ display: 'inline-flex', gap }}>
    {[1,2,3,4,5].map(i => (
      <svg key={i} width={size} height={size} viewBox="0 0 24 24"
        fill={i <= Math.round(rating) ? '#F5A524' : 'none'}
        stroke={i <= Math.round(rating) ? '#F5A524' : 'rgba(26,15,0,0.3)'}
        strokeWidth="2" strokeLinejoin="round">
        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 21 12 17.27 5.82 21 7 14.14l-5-4.87 6.91-1.01z"/>
      </svg>
    ))}
  </div>
);

// ───────── Helper: Interactive Star Rating ─────────
const InteractiveStars = ({ value = 0, onChange, size = 32 }) => (
  <div style={{ display: 'flex', gap: 6, cursor: 'pointer' }}>
    {[1,2,3,4,5].map(i => (
      <svg key={i} width={size} height={size} viewBox="0 0 24 24"
        onClick={() => onChange && onChange(i)}
        fill={i <= value ? '#F5A524' : 'none'}
        stroke={i <= value ? '#F5A524' : 'rgba(26,15,0,0.35)'}
        strokeWidth="1.8" strokeLinejoin="round"
        style={{ transition: 'transform 0.15s', transform: i <= value ? 'scale(1.1)' : 'scale(1)' }}>
        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 21 12 17.27 5.82 21 7 14.14l-5-4.87 6.91-1.01z"/>
      </svg>
    ))}
  </div>
);

// ───────── Helper: Barcode Strip ─────────
const Barcode = ({ dark = true }) => (
  <div style={{ display: 'flex', gap: 1.5, alignItems: 'flex-end' }}>
    {[2,3,1,4,2,3,5,2,1,3,4,2,3,1,2,5,3,2,4,1,3,2,4,2].map((w, i) => (
      <div key={i} style={{ width: w, height: 22, background: dark ? '#1A0F00' : 'rgba(255,255,255,0.25)' }} />
    ))}
  </div>
);

// ───────── Helper: Hashtag Chip ─────────
const HashtagChip = ({ tag, removable, onRemove, dark }) => (
  <div style={{
    display: 'inline-flex', alignItems: 'center', gap: 4,
    padding: '4px 10px', borderRadius: 999,
    background: dark ? 'rgba(245,165,36,0.18)' : 'rgba(26,15,0,0.08)',
    border: dark ? '1px solid rgba(245,165,36,0.3)' : '1px solid rgba(26,15,0,0.15)',
    fontSize: 11, fontWeight: 700,
    color: dark ? '#FFD7A0' : '#8B6A2A',
  }}>
    <span>#{tag}</span>
    {removable && (
      <span onClick={onRemove} style={{
        cursor: 'pointer', marginLeft: 2, fontSize: 13,
        color: dark ? 'rgba(255,215,160,0.6)' : 'rgba(26,15,0,0.4)',
        lineHeight: 1,
      }}>×</span>
    )}
  </div>
);


// ═══════════════════════════════════════════════════════════════
// Screen 1: MovieReviews — List of latest movies with search
// ═══════════════════════════════════════════════════════════════

const MovieReviews = () => (
  <PhoneFrame>
    <div className="frame">
      {/* Header */}
      <div style={{ padding: '8px 16px 12px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button className="btn btn-secondary" style={{ width: 38, height: 38, padding: 0, borderRadius: 12 }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M14 6l-6 6 6 6"/></svg>
        </button>
        <div style={{ flex: 1 }}>
          <div className="h1" style={{ fontSize: 22 }}>Movie Reviews</div>
          <div className="te" style={{ fontSize: 11, color: 'var(--t-lo)' }}>సినిమా రివ్యూలు</div>
        </div>
        {/* Search icon */}
        <button className="btn btn-secondary" style={{ width: 38, height: 38, padding: 0, borderRadius: 12 }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
            <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>
          </svg>
        </button>
      </div>

      {/* Search bar (expanded state) */}
      <div style={{ padding: '0 16px 12px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10, padding: '0 14px', height: 44,
          borderRadius: 14, background: 'rgba(255,255,255,0.05)', border: '1px solid var(--line)',
        }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--t-lo)" strokeWidth="2" strokeLinecap="round">
            <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>
          </svg>
          <span style={{ fontSize: 13, color: 'var(--t-lo)' }}>Search movies…</span>
          {/* TODO: backend — wire up to GET /v1/movies?q=searchTerm */}
        </div>
      </div>

      <div className="scroll" style={{ padding: '0 16px 16px' }}>
        {/* Movie cards — ticket-stub style */}
        {REVIEW_MOVIES.map((movie, idx) => (
          <div key={movie.id} style={{ marginBottom: 14 }}>
            {/* Ticket-stub card */}
            <div style={{
              position: 'relative',
              background: 'linear-gradient(180deg, #FFF5E0 0%, #FFE5B8 100%)',
              color: '#1A0F00',
              borderRadius: 24,
              padding: '18px 20px 14px',
              boxShadow: '0 12px 36px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.5)',
            }}>
              {/* Perforation notches on left/right */}
              {[true, false].map((left, k) => (
                <div key={k} style={{
                  position: 'absolute', [left ? 'left' : 'right']: -10, top: '50%',
                  width: 20, height: 20, borderRadius: 999, background: 'var(--bg-0, #06070D)',
                }} />
              ))}

              {/* Top strip — label + rating */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingBottom: 12, borderBottom: '1.5px dashed rgba(26,15,0,0.3)' }}>
                <div>
                  <div style={{ fontSize: 9, fontWeight: 700, letterSpacing: 0.18, color: 'rgba(26,15,0,0.6)', textTransform: 'uppercase' }}>● TFI Bagundali</div>
                  <div style={{ fontFamily: 'var(--f-display)', fontSize: 11, fontWeight: 800, color: '#1A0F00', marginTop: 1, letterSpacing: 0.1, textTransform: 'uppercase' }}>Movie Review Ticket</div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontFamily: 'var(--f-mono)', fontSize: 26, fontWeight: 800, color: '#1A0F00', lineHeight: 1 }}>{movie.rating}</div>
                  <div style={{ fontSize: 9, fontWeight: 700, color: 'rgba(26,15,0,0.55)', letterSpacing: 0.08 }}>/5 RATING</div>
                </div>
              </div>

              {/* Movie info row */}
              <div style={{ display: 'flex', gap: 14, paddingTop: 14, paddingBottom: 14 }}>
                {/* Poster thumbnail */}
                <div className={`poster ${movie.posterClass}`} style={{
                  width: 72, height: 100, borderRadius: 12, flexShrink: 0,
                  boxShadow: '0 4px 12px rgba(26,15,0,0.25)',
                }} />

                {/* Movie details */}
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                  <div style={{ fontFamily: 'var(--f-display)', fontSize: 22, fontWeight: 800, color: '#1A0F00', lineHeight: 1.05 }}>{movie.title}</div>
                  <div style={{ fontSize: 12, color: '#8B6A2A', fontWeight: 600, marginTop: 2 }}>{movie.titleTe}</div>

                  <div style={{ marginTop: 8 }}>
                    <div style={{ fontSize: 10, fontWeight: 700, color: 'rgba(26,15,0,0.55)', letterSpacing: 0.1, marginBottom: 2 }}>HERO</div>
                    <div style={{ fontSize: 13, fontWeight: 700, color: '#1A0F00' }}>{movie.hero}</div>
                  </div>

                  <div style={{ marginTop: 4 }}>
                    <div style={{ fontSize: 10, fontWeight: 700, color: 'rgba(26,15,0,0.55)', letterSpacing: 0.1, marginBottom: 2 }}>DIRECTOR</div>
                    <div style={{ fontSize: 12.5, fontWeight: 600, color: '#4A3A1A' }}>{movie.director}</div>
                  </div>
                </div>
              </div>

              {/* Bottom strip — stars + review count + barcode */}
              <div style={{ paddingTop: 12, borderTop: '1.5px dashed rgba(26,15,0,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div>
                  <Stars rating={movie.rating} size={13} />
                  <div style={{ fontSize: 11, color: 'rgba(26,15,0,0.6)', fontWeight: 600, marginTop: 3 }}>
                    <b style={{ color: '#1A0F00' }}>{movie.reviewCount.toLocaleString()}</b> reviews
                  </div>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <Barcode dark />
                  <div style={{ fontFamily: 'var(--f-mono)', fontSize: 9, color: 'rgba(26,15,0,0.5)', fontWeight: 700 }}>TFI<br/>REVIEWS</div>
                </div>
              </div>
            </div>
          </div>
        ))}

        {/* ─── "Oops" empty state (shown when search has no results) ─── */}
        {/* TODO: conditionally show this when search query matches no movies */}
        {false && (
          <div style={{
            textAlign: 'center', padding: '60px 30px',
          }}>
            <div style={{
              width: 80, height: 80, borderRadius: 24, margin: '0 auto 20px',
              background: 'linear-gradient(180deg, rgba(245,165,36,0.15), rgba(229,72,77,0.10))',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 38,
            }}>
              <svg width="38" height="38" viewBox="0 0 24 24" fill="none" stroke="var(--t-lo)" strokeWidth="1.5" strokeLinecap="round">
                <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>
                <path d="M8 14s1.5-2 3-2 3 2 3 2" strokeLinejoin="round"/>
              </svg>
            </div>
            <div className="h2" style={{ fontSize: 18, color: 'var(--t-hi)', marginBottom: 6 }}>Oops!</div>
            <div style={{ fontSize: 14, color: 'var(--t-lo)', lineHeight: 1.5 }}>
              We couldn't find any movie on this name.
            </div>
            <div className="te" style={{ fontSize: 12, color: 'var(--t-faint)', marginTop: 4 }}>
              Try searching with a different name.
            </div>
          </div>
        )}

        <div style={{ height: 16 }} />
      </div>

      <TabBar active="home" />
    </div>
  </PhoneFrame>
);


// ═══════════════════════════════════════════════════════════════
// Screen 2: MovieReviewDetail — Full review page for a movie
// ═══════════════════════════════════════════════════════════════

const MovieReviewDetail = () => {
  // Using Peddi as the featured movie for the mockup
  const movie = REVIEW_MOVIES[0];
  const reviews = MOCK_REVIEWS[movie.id] || [];

  return (
    <PhoneFrame>
      <div className="frame">
        <div className="scroll">
          {/* Hero poster banner */}
          <div className={`poster ${movie.posterClass}`} style={{ height: 260, position: 'relative' }}>
            {/* Gradient overlay */}
            <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(0,0,0,0.3) 0%, rgba(0,0,0,0.05) 40%, rgba(6,7,13,0.95) 100%)' }} />

            {/* Back button */}
            <div style={{ position: 'absolute', top: 50, left: 16, right: 16, display: 'flex', justifyContent: 'space-between', zIndex: 3 }}>
              <button className="btn btn-secondary glass" style={{ width: 40, height: 40, padding: 0, borderRadius: 999 }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M14 6l-6 6 6 6"/></svg>
              </button>
              <button className="btn btn-secondary glass" style={{ width: 40, height: 40, padding: 0, borderRadius: 999 }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
                  <circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/>
                  <path d="M8.6 13.5L15.4 17.5M15.4 6.5L8.6 10.5"/>
                </svg>
              </button>
            </div>

            {/* Movie name overlay at bottom of poster */}
            <div style={{ position: 'absolute', bottom: 18, left: 18, right: 18, zIndex: 3 }}>
              <div style={{ fontFamily: 'var(--f-display)', fontSize: 32, fontWeight: 800, color: '#fff', lineHeight: 1.05, textShadow: '0 2px 16px rgba(0,0,0,0.6)' }}>{movie.title}</div>
              <div className="te" style={{ fontSize: 14, color: '#FFD7A0', marginTop: 4 }}>{movie.titleTe}</div>
            </div>
          </div>

          {/* Movie info ticket card */}
          <div style={{ padding: '0 16px', marginTop: -20, position: 'relative', zIndex: 4 }}>
            <div style={{
              position: 'relative',
              background: 'linear-gradient(180deg, #FFF5E0 0%, #FFE5B8 100%)',
              color: '#1A0F00',
              borderRadius: 24,
              padding: '18px 20px 16px',
              boxShadow: '0 16px 40px rgba(0,0,0,0.4), inset 0 1px 0 rgba(255,255,255,0.5)',
            }}>
              {/* Perforation notches */}
              {[true, false].map((left, k) => (
                <div key={k} style={{
                  position: 'absolute', [left ? 'left' : 'right']: -10, top: '46%',
                  width: 20, height: 20, borderRadius: 999, background: 'var(--bg-0, #06070D)',
                }} />
              ))}

              {/* Movie details row */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingBottom: 14, borderBottom: '1.5px dashed rgba(26,15,0,0.3)' }}>
                <div>
                  <div style={{ fontSize: 10, fontWeight: 700, color: 'rgba(26,15,0,0.55)', letterSpacing: 0.12 }}>HERO</div>
                  <div style={{ fontSize: 15, fontWeight: 700, color: '#1A0F00', marginTop: 1 }}>{movie.hero}</div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontSize: 10, fontWeight: 700, color: 'rgba(26,15,0,0.55)', letterSpacing: 0.12 }}>DIRECTOR</div>
                  <div style={{ fontSize: 14, fontWeight: 600, color: '#4A3A1A', marginTop: 1 }}>{movie.director}</div>
                </div>
              </div>

              {/* Overall rating section */}
              <div style={{ display: 'flex', alignItems: 'center', gap: 16, paddingTop: 14, paddingBottom: 14, borderBottom: '1.5px dashed rgba(26,15,0,0.3)' }}>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontFamily: 'var(--f-mono)', fontSize: 42, fontWeight: 800, color: '#1A0F00', lineHeight: 1 }}>{movie.rating}</div>
                  <div style={{ fontSize: 10, fontWeight: 700, color: 'rgba(26,15,0,0.5)', marginTop: 2 }}>OUT OF 5</div>
                </div>
                <div style={{ flex: 1 }}>
                  <Stars rating={movie.rating} size={18} gap={3} />
                  <div style={{ fontSize: 12, color: 'rgba(26,15,0,0.65)', fontWeight: 600, marginTop: 4 }}>
                    Based on <b style={{ color: '#1A0F00' }}>{movie.reviewCount.toLocaleString()}</b> reviews
                  </div>
                  {/* Rating distribution mini-bars */}
                  <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 3 }}>
                    {[
                      { star: 5, pct: 58 },
                      { star: 4, pct: 24 },
                      { star: 3, pct: 10 },
                      { star: 2, pct: 5 },
                      { star: 1, pct: 3 },
                    ].map(d => (
                      <div key={d.star} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                        <div style={{ fontSize: 9, fontWeight: 700, color: 'rgba(26,15,0,0.5)', width: 10, textAlign: 'right' }}>{d.star}</div>
                        <div style={{ flex: 1, height: 5, borderRadius: 3, background: 'rgba(26,15,0,0.1)' }}>
                          <div style={{ height: '100%', borderRadius: 3, width: `${d.pct}%`, background: 'linear-gradient(90deg, #F5A524, #E5484D)' }} />
                        </div>
                        <div style={{ fontSize: 9, fontWeight: 600, color: 'rgba(26,15,0,0.45)', width: 24 }}>{d.pct}%</div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* User's own rating section */}
              <div style={{ paddingTop: 14, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ fontSize: 10, fontWeight: 700, color: 'rgba(26,15,0,0.55)', letterSpacing: 0.12, marginBottom: 4 }}>TAP TO RATE</div>
                  {/* TODO: backend — POST /v1/movies/:id/rating { rating: N } */}
                  <InteractiveStars value={0} size={28} />
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <Barcode dark />
                  <div style={{ fontFamily: 'var(--f-mono)', fontSize: 9, color: 'rgba(26,15,0,0.5)', fontWeight: 700 }}>TFI<br/>RATE</div>
                </div>
              </div>
            </div>
          </div>

          {/* Reviews section header */}
          <div style={{ padding: '20px 16px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <div className="h2" style={{ fontSize: 18 }}>Fan Reviews</div>
              <div className="te" style={{ fontSize: 11, color: 'var(--t-lo)' }}>అభిమాన రివ్యూలు</div>
            </div>
            <div style={{ fontSize: 12, color: 'var(--gold)', fontWeight: 700 }}>{reviews.length} reviews</div>
          </div>

          {/* Review cards */}
          <div style={{ padding: '0 16px' }}>
            {reviews.map(review => (
              <div key={review.id} className="card" style={{
                padding: 14, marginBottom: 10,
                border: '1px solid var(--line)',
              }}>
                {/* User row */}
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
                  {/* Avatar */}
                  <div style={{
                    width: 34, height: 34, borderRadius: 999,
                    background: 'linear-gradient(135deg, rgba(245,165,36,0.3), rgba(139,92,246,0.3))',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: 13, fontWeight: 800, color: 'var(--t-hi)',
                  }}>{review.user.charAt(0)}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--t-hi)' }}>{review.user}</div>
                    <div style={{ fontSize: 10.5, color: 'var(--t-lo)' }}>{review.time}</div>
                  </div>
                  <Stars rating={review.rating} size={11} />
                </div>

                {/* Review text */}
                <div style={{ fontSize: 13, lineHeight: 1.5, color: 'var(--t-mid)', marginBottom: 8 }}>
                  {review.text}
                </div>

                {/* Hashtag chips */}
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: 5 }}>
                  {review.hashtags.map(tag => (
                    <HashtagChip key={tag} tag={tag} dark />
                  ))}
                </div>
              </div>
            ))}
          </div>

          <div style={{ height: 80 }} />
        </div>

        {/* Floating "+" FAB to write a review */}
        <div style={{
          position: 'absolute', bottom: 24, right: 22, zIndex: 10,
          width: 56, height: 56, borderRadius: 999,
          background: 'linear-gradient(135deg, #FFB52E, #E5484D)',
          boxShadow: '0 8px 28px rgba(245,165,36,0.5), 0 2px 8px rgba(0,0,0,0.3)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer',
        }}>
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.5" strokeLinecap="round">
            <path d="M12 5v14M5 12h14"/>
          </svg>
        </div>
      </div>
    </PhoneFrame>
  );
};


// ═══════════════════════════════════════════════════════════════
// Screen 3: WriteReviewSheet — Bottom sheet for writing a review
// ═══════════════════════════════════════════════════════════════

const WriteReviewSheet = () => {
  const movie = REVIEW_MOVIES[0]; // Using Peddi for mockup

  return (
    <PhoneFrame>
      <div className="frame" style={{ position: 'relative' }}>
        {/* Dimmed background — represents the detail screen behind */}
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(6,7,13,0.7)', zIndex: 5 }} />

        {/* Bottom sheet */}
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 10,
          borderRadius: '28px 28px 0 0',
          background: 'linear-gradient(180deg, rgba(20,22,40,0.95), rgba(10,12,24,0.98))',
          backdropFilter: 'blur(20px) saturate(180%)',
          WebkitBackdropFilter: 'blur(20px) saturate(180%)',
          border: '1px solid rgba(255,255,255,0.1)',
          borderBottom: 'none',
          boxShadow: '0 -20px 60px rgba(0,0,0,0.5)',
          padding: '0 22px 28px',
        }}>
          {/* Handle bar */}
          <div style={{ display: 'flex', justifyContent: 'center', padding: '12px 0 16px' }}>
            <div style={{ width: 40, height: 4, borderRadius: 2, background: 'rgba(255,255,255,0.2)' }} />
          </div>

          {/* Sheet header */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 }}>
            <div>
              <div className="h2" style={{ fontSize: 20, color: '#fff' }}>Write Your Review</div>
              <div className="te" style={{ fontSize: 12, color: '#FFD7A0', marginTop: 2 }}>నీ అభిప్రాయం రాయి</div>
            </div>
            {/* Close button */}
            <button className="btn btn-secondary" style={{ width: 34, height: 34, padding: 0, borderRadius: 999 }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                <path d="M18 6L6 18M6 6l12 12"/>
              </svg>
            </button>
          </div>

          {/* Movie context mini-card */}
          <div style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: 12, borderRadius: 16,
            background: 'rgba(255,255,255,0.05)', border: '1px solid var(--line)',
            marginBottom: 18,
          }}>
            <div className={`poster ${movie.posterClass}`} style={{ width: 42, height: 56, borderRadius: 8, flexShrink: 0 }} />
            <div>
              <div style={{ fontSize: 14, fontWeight: 700, color: '#fff' }}>{movie.title}</div>
              <div style={{ fontSize: 11.5, color: 'var(--t-lo)' }}>{movie.hero} · {movie.director}</div>
            </div>
          </div>

          {/* Star rating */}
          <div style={{ marginBottom: 18 }}>
            <div style={{ fontSize: 10.5, fontWeight: 700, color: 'var(--t-lo)', letterSpacing: 0.12, marginBottom: 8, textTransform: 'uppercase' }}>Your Rating</div>
            {/* TODO: backend — will be sent with POST /v1/movies/:id/reviews */}
            <div style={{
              display: 'flex', alignItems: 'center', gap: 14, padding: '12px 16px', borderRadius: 16,
              background: 'rgba(245,165,36,0.08)', border: '1px solid rgba(245,165,36,0.2)',
            }}>
              <InteractiveStars value={4} size={30} />
              <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--gold)', marginLeft: 'auto' }}>4/5</div>
            </div>
          </div>

          {/* Text input area */}
          <div style={{ marginBottom: 14 }}>
            <div style={{ fontSize: 10.5, fontWeight: 700, color: 'var(--t-lo)', letterSpacing: 0.12, marginBottom: 8, textTransform: 'uppercase' }}>Your Perception</div>
            <div style={{
              minHeight: 100, padding: 14, borderRadius: 16,
              background: 'rgba(255,255,255,0.05)', border: '1px solid var(--line)',
              fontSize: 13.5, lineHeight: 1.55, color: 'var(--t-hi)',
            }}>
              {/* Simulated typed text for mockup */}
              Ram Charan at his best! The interval block was absolutely mind-blowing. Buchi Babu delivered exactly what fans wanted.
              <span style={{ width: 2, height: 16, background: 'var(--gold)', display: 'inline-block', animation: 'blink 1s infinite', verticalAlign: 'text-bottom', marginLeft: 2 }} />
            </div>
          </div>

          {/* Hashtag section */}
          <div style={{ marginBottom: 18 }}>
            <div style={{ fontSize: 10.5, fontWeight: 700, color: 'var(--t-lo)', letterSpacing: 0.12, marginBottom: 8, textTransform: 'uppercase' }}>Add Hashtags</div>

            {/* Hashtag input area */}
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px', borderRadius: 14,
              background: 'rgba(255,255,255,0.05)', border: '1px solid var(--line)',
              marginBottom: 10,
            }}>
              <span style={{ fontSize: 16, color: 'var(--gold)', fontWeight: 800 }}>#</span>
              <span style={{ fontSize: 13, color: 'var(--t-lo)' }}>Type to add hashtag…</span>
              {/* TODO: on typing after #, show POPULAR_HASHTAGS dropdown filtered by input */}
            </div>

            {/* Selected hashtags (removable chips) */}
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 10 }}>
              <HashtagChip tag="MassMovie" removable dark />
              <HashtagChip tag="Blockbuster" removable dark />
              <HashtagChip tag="IntervalFire" removable dark />
            </div>

            {/* Popular hashtag suggestions */}
            <div style={{ fontSize: 10, fontWeight: 700, color: 'var(--t-faint)', letterSpacing: 0.1, marginBottom: 6, textTransform: 'uppercase' }}>Popular</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 5 }}>
              {['Emotional', 'MustWatch', 'BGMKing', 'VisualsTop', 'PaisaVasool', 'ClimaxFire'].map(tag => (
                <div key={tag} style={{
                  padding: '5px 10px', borderRadius: 999,
                  background: 'rgba(255,255,255,0.04)', border: '1px solid var(--line)',
                  fontSize: 11, fontWeight: 600, color: 'var(--t-mid)',
                  cursor: 'pointer',
                }}>
                  #{tag}
                </div>
              ))}
            </div>
          </div>

          {/* Submit CTA — ticket-stub dark style */}
          {/* TODO: backend — POST /v1/movies/:id/reviews { rating, text, hashtags } */}
          <button className="btn btn-primary" style={{
            width: '100%', height: 54, fontSize: 15,
            background: 'linear-gradient(180deg, #1A0F00, #2B1900)',
            color: '#FFD7A0',
            boxShadow: '0 10px 22px rgba(26,15,0,0.45), inset 0 1px 0 rgba(255,255,255,0.18)',
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
            Post Review
          </button>
        </div>
      </div>
    </PhoneFrame>
  );
};


// ───────── Export to window ─────────
Object.assign(window, { MovieReviews, MovieReviewDetail, WriteReviewSheet });
