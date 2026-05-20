/* TFI Bagundali — Home & Update detail */

// ───────── 5. Home / Today in TFI ─────────
const Home = () => (
  <PhoneFrame>
    <div className="frame">
      <AppHeader name="Rakesh" heroEmoji="⚡" heroBg="h-power" notif={3} />

      <ChipRow active={0} items={['All', 'My Hero ⚡', 'Releases', 'Trailers', 'Songs', 'Launches', 'Collabs', 'Events', 'OTT', 'Box Office']} />

      <div className="scroll" style={{ paddingTop: 4 }}>
        {/* Hero pulse banner */}
        <div style={{ padding: '0 16px 16px' }}>
          <div className="card-elev" style={{ padding: 16, position: 'relative', overflow: 'hidden' }}>
            <div className="spot" />
            <div style={{ position: 'relative' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
                <div>
                  <div className="label-eyebrow" style={{ color: 'var(--gold)' }}>● TFI DAILY PULSE</div>
                  <div className="h1" style={{ fontSize: 22, marginTop: 4 }}>Today in TFI</div>
                  <div className="te" style={{ fontSize: 12, color: 'var(--t-lo)', marginTop: 2 }}>ఈరోజు సినిమా అప్‌డేట్స్</div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontFamily: 'var(--f-mono)', fontSize: 22, fontWeight: 700, color: '#fff' }}>12</div>
                  <div style={{ fontSize: 10, color: 'var(--t-lo)', fontWeight: 600 }}>NEW UPDATES</div>
                </div>
              </div>
              <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
                <div className="chip" style={{ background: 'rgba(229,72,77,0.18)', color: '#FF9BA0' }}>● 2 Breaking</div>
                <div className="chip" style={{ background: 'rgba(48,199,108,0.18)', color: '#6FE3A0' }}>● 4 Official</div>
                <div className="chip">8 Trending</div>
              </div>
            </div>
          </div>
        </div>

        {/* Breaking update */}
        <div style={{ padding: '0 16px' }}>
          <UpdateCard
            breaking
            posterClass="peddi"
            category="Release Update"
            status="official"
            title="Peddi locks June 4 release"
            summary="Ram Charan's Peddi is set for grand theatrical release. Buchi Babu Sana directs."
            time="32 min ago"
            tags={['Ram Charan', 'Peddi', 'Buchi Babu']}
            reactions="42.1K"
            emoji="🔥"
          />
        </div>

        {/* Section: Trending Now */}
        <Section title="Trending Now" te="ట్రెండింగ్ ఇప్పుడు" action="See all" />
        <div style={{ display: 'flex', gap: 12, overflowX: 'auto', padding: '0 16px 8px' }}>
          {[
            { cls: 'devara', title: 'Devara 2 first look reveal date out', emoji: '⚡', tag: 'NTR · Devara 2' },
            { cls: 'spirit', title: 'Spirit shoot wrapped, post-prod begins', emoji: '🦁', tag: 'Prabhas · Sandeep' },
            { cls: 'pushpa', title: 'Pushpa 3 muhurat in March', emoji: '🔥', tag: 'Allu Arjun · Sukumar' },
          ].map((t,i) => (
            <div key={i} className="card" style={{ width: 220, flexShrink: 0, overflow: 'hidden' }}>
              <div className={`poster ${t.cls}`} style={{ height: 110, padding: 10, display: 'flex', alignItems: 'flex-end' }}>
                <div className="chip" style={{ background: 'rgba(0,0,0,0.6)' }}>● Trending</div>
                <div style={{ position: 'absolute', top: 10, right: 10, fontSize: 22 }}>{t.emoji}</div>
              </div>
              <div style={{ padding: 10 }}>
                <div style={{ fontSize: 12.5, fontWeight: 600, lineHeight: 1.3, marginBottom: 4 }}>{t.title}</div>
                <div style={{ fontSize: 10.5, color: 'var(--t-lo)' }}>{t.tag} · 2h</div>
              </div>
            </div>
          ))}
        </div>

        {/* Upcoming releases */}
        <div style={{ height: 8 }} />
        <Section title="Upcoming Releases" te="రాబోయే విడుదలలు" action="Calendar" />
        <div style={{ display: 'flex', gap: 10, overflowX: 'auto', padding: '0 16px 8px' }}>
          <Poster cls="peddi"    te="పెద్ది"     title="PEDDI"   date="Jun 4, 2026"  countdown="🔴 16 DAYS" />
          <Poster cls="devara"   te="దేవర 2"     title="DEVARA 2" date="Aug 15"       countdown="89 days" />
          <Poster cls="spirit"   te="స్పిరిట్"    title="SPIRIT"   date="Oct 2"        countdown="135 days" />
          <Poster cls="pushpa"   te="పుష్ప 3"    title="PUSHPA 3" date="Sankranthi"   countdown="240 days" />
          <Poster cls="kuberaa"  te="కుబేర"     title="KUBERAA"  date="Jun 20"       countdown="32 days" />
        </div>

        {/* Today's quiz hook */}
        <div style={{ padding: '12px 16px' }}>
          <div className="card-elev" style={{ padding: 14, display: 'flex', alignItems: 'center', gap: 14, position: 'relative', overflow: 'hidden' }}>
            <div style={{ position: 'absolute', right: -30, top: -20, fontSize: 100, opacity: 0.15 }}>🎬</div>
            <div style={{ width: 56, height: 56, borderRadius: 16, background: 'linear-gradient(135deg, #8B5CF6, #3E8BFF)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26, boxShadow: '0 8px 20px rgba(139,92,246,0.4)' }}>🧠</div>
            <div style={{ flex: 1 }}>
              <div className="h2" style={{ fontSize: 15 }}>Today's Movie Trivia</div>
              <div style={{ fontSize: 11.5, color: 'var(--t-lo)' }}>10 questions · 15s each</div>
              <div style={{ display: 'flex', gap: 6, marginTop: 4 }}>
                <span className="chip" style={{ fontSize: 9 }}>Mass Dialogues</span>
                <span className="chip" style={{ fontSize: 9 }}>Songs</span>
              </div>
            </div>
            <button className="btn btn-primary" style={{ height: 38, fontSize: 13, padding: '0 14px' }}>Play</button>
          </div>
        </div>

        {/* Popular poll */}
        <Section title="Popular Poll" te="ఎక్కువ వోట్లు" action="All polls" />
        <div style={{ padding: '0 16px' }}>
          <div className="card" style={{ padding: 14 }}>
            <div className="chip" style={{ background: 'rgba(139,92,246,0.18)', color: '#C4A8FF', marginBottom: 8 }}>WORD POLL</div>
            <div className="h2" style={{ fontSize: 16, marginBottom: 4 }}>One word for Peddi trailer?</div>
            <div className="te" style={{ fontSize: 11.5, color: 'var(--t-lo)', marginBottom: 10 }}>పెద్ది ట్రైలర్ ఎలా ఉంది?</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
              {[
                { w: 'Mass', sz: 28, c: '#FFB52E' },
                { w: 'Fire 🔥', sz: 22, c: '#FF7A5C' },
                { w: 'Goosebumps', sz: 24, c: '#C4A8FF' },
                { w: 'Blockbuster', sz: 20, c: '#7DB1FF' },
                { w: 'Emotional', sz: 16, c: 'var(--t-mid)' },
                { w: 'Mind blow', sz: 18, c: '#6FE3A0' },
              ].map((p, i) => (
                <div key={i} className="chip" style={{ fontSize: p.sz/2 + 6, fontWeight: 700, color: p.c, padding: '6px 10px' }}>{p.w}</div>
              ))}
            </div>
            <div style={{ marginTop: 10, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ fontSize: 11, color: 'var(--t-lo)' }}><b style={{ color: 'var(--t-mid)' }}>18,243</b> fans voted · 2h left</div>
              <div style={{ color: 'var(--gold)', fontSize: 12, fontWeight: 700 }}>Vote →</div>
            </div>
          </div>
        </div>

        {/* Wallpapers preview */}
        <div style={{ height: 8 }} />
        <Section title="Wallpapers & Cards" te="వాల్‌పేపర్స్ & స్టేటస్ కార్డ్స్" action="Explore" />
        <div style={{ display: 'flex', gap: 10, padding: '0 16px 8px' }}>
          {['devara','peddi','spirit'].map((cls, i) => (
            <div key={i} className={`poster ${cls}`} style={{ flex: 1, height: 130, position: 'relative' }}>
              <div style={{ position: 'absolute', bottom: 8, left: 8, right: 8, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span className="chip" style={{ background: 'rgba(0,0,0,0.6)', fontSize: 9 }}>FREE</span>
                <span style={{ fontSize: 13, color: '#fff' }}>↓</span>
              </div>
            </div>
          ))}
        </div>

        {/* Movie calendar mini */}
        <div style={{ padding: '12px 16px' }}>
          <div className="card" style={{ padding: 14, display: 'flex', alignItems: 'center', gap: 14 }}>
            <div style={{ width: 56, height: 56, borderRadius: 14, background: 'linear-gradient(135deg, #E5484D, #F5A524)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
              <div style={{ fontSize: 9, fontWeight: 700, color: '#1A0F00' }}>JUNE</div>
              <div style={{ fontSize: 22, fontWeight: 800, color: '#1A0F00', lineHeight: 1 }}>04</div>
            </div>
            <div style={{ flex: 1 }}>
              <div className="h2" style={{ fontSize: 14 }}>Movie Calendar</div>
              <div style={{ fontSize: 11.5, color: 'var(--t-lo)' }}>3 releases, 5 trailers this month</div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M9 18l6-6-6-6"/></svg>
          </div>
        </div>

        <div style={{ height: 16 }} />
      </div>

      <TabBar active="home" />
    </div>
  </PhoneFrame>
);

// ───────── 6. Updates Feed (full) ─────────
const UpdatesFeed = () => (
  <PhoneFrame>
    <div className="frame">
      <div style={{ padding: '8px 16px 12px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button className="btn btn-secondary" style={{ width: 38, height: 38, padding: 0, borderRadius: 12 }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M14 6l-6 6 6 6"/></svg>
        </button>
        <div style={{ flex: 1 }}>
          <div className="h1" style={{ fontSize: 22 }}>All TFI Updates</div>
          <div className="te" style={{ fontSize: 11, color: 'var(--t-lo)' }}>మొత్తం 248 అప్‌డేట్స్</div>
        </div>
        <button className="btn btn-secondary" style={{ width: 38, height: 38, padding: 0, borderRadius: 12 }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M3 6h18M6 12h12M10 18h4"/></svg>
        </button>
      </div>

      <ChipRow active={2} items={['Latest', 'My Hero', 'Releases', 'Trailers', 'Songs', 'Box Office', 'OTT']} />

      <div className="scroll" style={{ padding: '0 16px 16px' }}>
        <UpdateCard breaking posterClass="peddi" category="Release" status="official" title="Peddi locks June 4 release"
          summary="Ram Charan's Peddi is set for grand theatrical release. Buchi Babu Sana directs."
          time="32 min" tags={['Ram Charan','Peddi']} reactions="42.1K" emoji="🔥" />

        <UpdateCard posterClass="devara" category="Trailer" status="verified" title="Devara 2 first look on Aug 1"
          summary="Koratala Siva confirms first look at NTR's birthday eve. Trailer to follow within 3 weeks."
          time="2h" tags={['NTR','Koratala Siva']} reactions="38.5K" emoji="⚡" />

        <UpdateCard posterClass="spirit" category="Shooting" status="report" title="Spirit final schedule begins in Goa"
          summary="Sandeep Reddy Vanga reportedly starts the climax block. Triptii Dimri joins shoot."
          time="4h" tags={['Prabhas','Vanga']} reactions="21.3K" emoji="🦁" />

        <UpdateCard posterClass="kuberaa" category="OTT" status="official" title="Kuberaa secures Netflix premiere"
          summary="Sekhar Kammula's Kuberaa to stream 4 weeks after theatrical run."
          time="6h" tags={['Dhanush','Sekhar Kammula']} reactions="14.8K" emoji="📺" />

        <UpdateCard posterClass="pushpa" category="Box Office" status="buzz" title="Pushpa 3 muhurat in March — buzz"
          summary="Industry whispers suggest Sukumar–Allu Arjun reunion ready by mid-2027. Awaiting confirmation."
          time="8h" tags={['Allu Arjun','Sukumar']} reactions="9.4K" emoji="💥" />
      </div>

      <TabBar active="home" />
    </div>
  </PhoneFrame>
);

// ───────── 7. Update Detail ─────────
const UpdateDetail = () => (
  <PhoneFrame>
    <div className="frame">
      <div className="scroll">
        {/* Hero poster */}
        <div className="poster peddi" style={{ height: 360, position: 'relative' }}>
          <div style={{ position: 'absolute', top: 50, left: 16, right: 16, display: 'flex', justifyContent: 'space-between' }}>
            <button className="btn btn-secondary glass" style={{ width: 40, height: 40, padding: 0, borderRadius: 999 }}>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><path d="M14 6l-6 6 6 6"/></svg>
            </button>
            <div style={{ display: 'flex', gap: 8 }}>
              <button className="btn btn-secondary glass" style={{ width: 40, height: 40, padding: 0, borderRadius: 999 }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 3v18l7-5 7 5V3z" strokeLinejoin="round"/></svg>
              </button>
              <button className="btn btn-secondary glass" style={{ width: 40, height: 40, padding: 0, borderRadius: 999 }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M8.6 13.5L15.4 17.5M15.4 6.5L8.6 10.5"/></svg>
              </button>
            </div>
          </div>
          <div style={{ position: 'absolute', bottom: 18, left: 18, right: 18, zIndex: 3 }}>
            <div style={{ display: 'flex', gap: 6, marginBottom: 10 }}>
              <div style={{ background: '#E5484D', color: '#fff', fontWeight: 800, fontSize: 10, padding: '4px 8px', borderRadius: 6, letterSpacing: 0.08 }}>● BREAKING</div>
              <div className="chip" style={{ background: 'rgba(0,0,0,0.6)' }}>RELEASE</div>
              <StatusBadge kind="official" />
            </div>
            <div className="h-display" style={{ fontSize: 30, color: '#fff', lineHeight: 1.05, textShadow: '0 2px 16px rgba(0,0,0,0.6)' }}>Peddi locks June 4 release</div>
            <div className="te" style={{ fontSize: 14, color: '#FFD7A0', marginTop: 6 }}>పెద్ది జూన్ 4 రిలీజ్ ఫిక్స్</div>
          </div>
        </div>

        <div style={{ padding: '14px 18px 0' }}>
          {/* Reactions row */}
          <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
            {[
              { e: '🔥', n: '24.1K', a: true },
              { e: '💥', n: '8.4K' },
              { e: '😍', n: '5.2K' },
              { e: '⏳', n: '1.8K' },
              { e: '👏', n: '2.6K' },
            ].map((r, i) => (
              <button key={i} className={i === 0 ? 'card' : ''} style={{
                flex: 1, padding: '8px 0', borderRadius: 12,
                background: r.a ? 'linear-gradient(180deg, rgba(245,165,36,0.22), rgba(245,165,36,0.06))' : 'rgba(255,255,255,0.04)',
                border: r.a ? '1px solid var(--gold)' : '1px solid var(--line)',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
              }}>
                <div style={{ fontSize: 18 }}>{r.e}</div>
                <div style={{ fontSize: 10, fontWeight: 700, color: r.a ? 'var(--gold)' : 'var(--t-mid)' }}>{r.n}</div>
              </button>
            ))}
          </div>

          {/* Update text */}
          <div style={{ fontSize: 14.5, lineHeight: 1.55, color: 'var(--t-mid)', marginBottom: 14 }}>
            Ram Charan's long-awaited Peddi has been officially locked for theatrical release on <b style={{ color: 'var(--t-hi)' }}>June 4, 2026</b>. The Buchi Babu Sana directorial wraps post-production this week. Music by AR Rahman.
          </div>

          {/* Action row */}
          <div style={{ display: 'flex', gap: 8, marginBottom: 18, flexWrap: 'wrap' }}>
            <button className="btn btn-primary" style={{ flex: 1, height: 44, fontSize: 13 }}>🔔 Set Release Alert</button>
            <button className="btn btn-secondary" style={{ height: 44, fontSize: 13 }}>+ Follow</button>
          </div>

          {/* Source */}
          <div className="card" style={{ padding: 12, marginBottom: 18, display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--bg-3)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>📰</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 11, color: 'var(--t-lo)', fontWeight: 600 }}>SOURCE</div>
              <div style={{ fontSize: 13, fontWeight: 600 }}>UV Creations · Official Statement</div>
            </div>
            <span style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600 }}>View ↗</span>
          </div>

          {/* Related movie chip */}
          <div className="label-eyebrow" style={{ marginBottom: 10 }}>RELATED</div>
          <div className="card" style={{ padding: 12, display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
            <div className="poster peddi" style={{ width: 58, height: 78, borderRadius: 8 }} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700 }}>Peddi</div>
              <div className="te" style={{ fontSize: 11, color: 'var(--t-lo)' }}>పెద్ది · Ram Charan</div>
              <div style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 700, marginTop: 2 }}>Releases in 16 days</div>
            </div>
            <button className="btn btn-secondary" style={{ height: 32, fontSize: 12, padding: '0 12px' }}>View</button>
          </div>

          {/* Related poll */}
          <div className="card" style={{ padding: 14, marginBottom: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
              <div className="chip" style={{ background: 'rgba(139,92,246,0.18)', color: '#C4A8FF', fontSize: 10 }}>POLL</div>
              <div style={{ fontSize: 11, color: 'var(--t-lo)' }}>14h left</div>
            </div>
            <div className="h2" style={{ fontSize: 14, marginBottom: 8 }}>Will Peddi be a blockbuster?</div>
            <div style={{ display: 'flex', gap: 8 }}>
              <div style={{ flex: 1, padding: '8px 0', textAlign: 'center', borderRadius: 10, background: 'rgba(48,199,108,0.18)', border: '1px solid rgba(48,199,108,0.3)', fontSize: 12, fontWeight: 700, color: '#6FE3A0' }}>🎯 Sure shot · 78%</div>
              <div style={{ flex: 1, padding: '8px 0', textAlign: 'center', borderRadius: 10, background: 'rgba(255,255,255,0.04)', border: '1px solid var(--line)', fontSize: 12, fontWeight: 700, color: 'var(--t-mid)' }}>🤔 Wait & watch · 22%</div>
            </div>
          </div>

          <div style={{ height: 14 }} />
        </div>
      </div>

      {/* Floating share bar */}
      <div className="glass" style={{ padding: 12, borderTop: '1px solid var(--line)', display: 'flex', gap: 10 }}>
        <button className="btn btn-secondary" style={{ flex: 1, height: 44, fontSize: 13 }}>Save</button>
        <button className="btn btn-primary" style={{ flex: 2, height: 44, fontSize: 14 }}>Share Countdown Card</button>
      </div>
    </div>
  </PhoneFrame>
);

Object.assign(window, { Home, UpdatesFeed, UpdateDetail });
