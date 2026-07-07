// Mira — Capture flow, wired into the prototype. Voice / Photo / Screenshot / Link → review → kept.
// The rich flow markup is rendered as scoped HTML (.rd-capture) and driven by the imperative
// logic below; go('home') exits back into the app via the prototype's navigator.

const CAPTURE_HTML = `
<!-- ══ LISTENING (Voice) ══ -->
      <div class="view" data-view="listen" data-screen-label="Voice capture">
        <div class="voice">
          <div class="v-top">
            <button class="circ-btn" onclick="stopVoice(); go('home')" aria-label="Cancel"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#6B6C73" stroke-width="2.2" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></button>
            <span class="v-timer"><span class="rec"></span><span id="vTimer">0:00</span></span>
            <div style="width:42px;"></div>
          </div>

          <div class="v-halo">
            <span class="ring"></span><span class="ring"></span><span class="ring"></span>
            <span class="v-orb"></span>
          </div>

          <div class="v-transcript">
            <div class="v-cap">Listening…</div>
            <div class="v-words" id="vWords"><span class="caret"></span></div>
          </div>

          <div class="v-chips" id="vChips"></div>

          <div class="v-wave" id="vWave"></div>

          <div class="v-controls">
            <button class="v-sec" onclick="stopVoice(); go('home')" aria-label="Cancel"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6B6C73" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></button>
            <button class="v-done" onclick="finishVoice()" aria-label="Finish"><svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12 5 5 9-11"/></svg></button>
            <div class="v-sec" style="visibility:hidden;"></div>
          </div>
          <div class="v-hint">Tap ✓ when you're finished</div>
        </div>
      </div>

      <!-- ══ PHOTO CAPTURE ══ -->
      <div class="view" data-view="photo" data-screen-label="Photo capture">
        <div class="cam" id="cam">
          <div class="cam-view">
            <div class="scene">
              <div class="poster">
                <div class="poster-tag">LIVE MUSIC</div>
                <div class="poster-h">Blue<br/>Note</div>
                <div class="poster-note"><svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M9 18V5l10-2v13" stroke-linecap="round"/><circle cx="6" cy="18" r="3"/><circle cx="16" cy="16" r="3"/></svg></div>
                <div class="poster-meta"><div class="d">Fri · Jul 18 · 8 PM</div><div class="v">THE CORNER ROOM · 4TH ST</div></div>
              </div>
            </div>
            <div class="brackets"><span class="tl"></span><span class="tr"></span><span class="bl"></span><span class="br"></span></div>
            <div class="cam-hint">Frame a poster, page, or place</div>
            <!-- scanning overlay -->
            <div class="scan-line"></div>
            <div class="det d1" style="left:19%;top:24%;width:52%;height:12%;"><span class="dl">Event</span></div>
            <div class="det d2" style="left:19%;top:60%;width:56%;height:7%;"><span class="dl">Date · time</span></div>
            <div class="det d3" style="left:19%;top:68%;width:60%;height:6%;"><span class="dl">Venue</span></div>
            <div class="scan-chip"><span class="spin"></span>Reading this photo…</div>
          </div>
          <div class="cam-top">
            <button class="cam-ic" onclick="go('home')" aria-label="Close"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></button>
            <button class="cam-ic" aria-label="Flash"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2 4 14h7l-1 8 9-12h-7z"/></svg></button>
          </div>
          <div class="cam-bottom">
            <button class="cam-lib" aria-label="Library"></button>
            <button class="shutter" onclick="capturePhoto()" aria-label="Capture"><i></i></button>
            <button class="cam-flip" aria-label="Flip camera"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 4h4a2 2 0 0 1 2 2v4"/><path d="m21 4-4 4"/><path d="M9 20H5a2 2 0 0 1-2-2v-4"/><path d="m3 20 4-4"/><circle cx="12" cy="12" r="3"/></svg></button>
          </div>
        </div>
      </div>

      <!-- ══ PROCESSING ══ -->
      <div class="view" data-view="proc" data-screen-label="Processing">
        <div class="center-col">
          <div class="proc-orb-wrap"><div class="orb orb--lg"><span class="orb-ring"></span></div><div class="proc-spark"></div></div>
          <div class="listen-label" style="margin-top:26px;">Understanding</div>
          <div class="proc-steps" id="procSteps">
            <div class="pstep" data-step="0"><span class="tick"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round"><path d="m5 12 5 5 9-11"/></svg></span>Transcribing what you said</div>
            <div class="pstep" data-step="1"><span class="tick"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round"><path d="m5 12 5 5 9-11"/></svg></span>Recognising type &amp; details</div>
            <div class="pstep" data-step="2"><span class="tick"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round"><path d="m5 12 5 5 9-11"/></svg></span>Finding connections in memory</div>
          </div>
        </div>
      </div>

      <!-- ══ REVIEW / CONFIRM ══ -->
      <div class="view" data-view="review" data-screen-label="Review &amp; Confirm">
        <div class="rv-top">
          <button class="back-btn" onclick="go('home')"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M15 18l-6-6 6-6"/></svg>Cancel</button>
          <div style="font-family:Dosis;font-weight:600;font-size:17px;color:var(--ink);">Review</div>
          <div style="width:60px;"></div>
        </div>
        <div class="rv-scroll">
          <div class="rv-eyebrow"><span class="dot"></span>Mira understood this</div>
          <div class="rv-card">
            <div class="rv-typerow">
              <span class="type-chip"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>Task</span>
              <button class="type-edit"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>Change type</button>
            </div>
            <p class="rv-quote">Call <b>John</b> before <b>Friday</b> to confirm the contract terms and send the signed copy.</p>
          </div>

          <div class="rv-fieldset">
            <div class="fl">Details Mira extracted</div>
            <div class="chips">
              <span class="echip">👤 John <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip">📅 Friday <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip"># contract <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip add">+ Add</span>
            </div>
          </div>

          <div class="rv-fieldset">
            <div class="fl">Connect to existing memory</div>
            <div class="conn">
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Meeting with John</div><div class="conn-sub">Calendar · Tomorrow, 3:00 PM</div></div>
                <div class="tog" onclick="this.classList.toggle('off')"></div>
              </div>
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Contract draft v2</div><div class="conn-sub">Note · Captured 2h ago</div></div>
                <div class="tog" onclick="this.classList.toggle('off')"></div>
              </div>
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6" stroke-linecap="round"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">John Carter</div><div class="conn-sub">Person · 6 linked memories</div></div>
                <div class="tog off" onclick="this.classList.toggle('off')"></div>
              </div>
            </div>
          </div>

          <div class="reminder">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#14328C" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M12 2h0M9 2h6"/></svg>
            <span class="rtx">Remind me <b>Thursday morning</b>, a day before it's due</span>
            <div class="tog" onclick="this.classList.toggle('off')"></div>
          </div>
        </div>
        <div class="rv-bar">
          <button class="btn btn--ghost" onclick="go('home')">Discard</button>
          <button class="btn btn--primary" onclick="go('added')">Add to memory</button>
        </div>
      </div>

      <!-- ══ PHOTO REVIEW ══ -->
      <div class="view" data-view="photoReview" data-screen-label="Photo review">
        <div class="rv-top">
          <button class="back-btn" onclick="openPhoto()"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M15 18l-6-6 6-6"/></svg>Retake</button>
          <div style="font-family:Dosis;font-weight:600;font-size:17px;color:var(--ink);">Review</div>
          <div style="width:60px;"></div>
        </div>
        <div class="rv-scroll">
          <div class="rv-eyebrow"><span class="dot"></span>Mira read your photo</div>
          <div class="rv-photo">
            <div class="mini" style="background:radial-gradient(circle at 30% 20%, rgba(240,180,90,.35), transparent 50%);"></div>
            <span class="badge"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="5" width="18" height="14" rx="2.5"/><circle cx="12" cy="12" r="3.2"/></svg>Photo</span>
            <div class="pv-h">Blue Note</div>
            <div class="pv-d">Fri · Jul 18 · 8 PM · The Corner Room</div>
          </div>

          <div class="rv-card" style="margin-top:14px;">
            <div class="rv-typerow">
              <span class="type-chip"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>Event</span>
              <button class="type-edit"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>Change type</button>
            </div>
            <p class="rv-quote"><b>Blue Note — Live Jazz</b> on <b>Fri, Jul 18 at 8 PM</b>, at <b>The Corner Room</b> on 4th St.</p>
          </div>

          <div class="rv-fieldset">
            <div class="fl">Details Mira read from the image</div>
            <div class="chips">
              <span class="echip">🎵 Blue Note <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip">📅 Jul 18, 8 PM <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip">📍 The Corner Room <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip add">+ Add</span>
            </div>
          </div>

          <div class="rv-fieldset">
            <div class="fl">Suggested actions</div>
            <div class="conn">
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Add to calendar</div><div class="conn-sub">Fri, Jul 18 · 8:00 PM</div></div>
                <div class="tog" onclick="this.classList.toggle('off')"></div>
              </div>
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Remind me to buy tickets</div><div class="conn-sub">This weekend</div></div>
                <div class="tog" onclick="this.classList.toggle('off')"></div>
              </div>
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6" stroke-linecap="round"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Maya — likes live jazz</div><div class="conn-sub">Person · maybe invite her</div></div>
                <div class="tog off" onclick="this.classList.toggle('off')"></div>
              </div>
            </div>
          </div>
        </div>
        <div class="rv-bar">
          <button class="btn btn--ghost" onclick="go('home')">Discard</button>
          <button class="btn btn--primary" onclick="go('added')">Add to memory</button>
        </div>
      </div>

      <!-- ══ LINK CAPTURE ══ -->
      <div class="view" data-view="link" data-screen-label="Link capture">
        <div class="lk">
          <div class="lk-top">
            <button class="circ-btn" onclick="go('home')" aria-label="Cancel"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#6B6C73" stroke-width="2.2" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></button>
            <div style="width:42px;"></div>
          </div>
          <div class="lk-h">
            <h2>Add a link</h2>
            <p>Paste a URL — Mira reads the page and keeps what matters.</p>
          </div>
          <div class="lk-input" id="lkInput">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/></svg>
            <div class="lk-url" id="lkUrl"><span class="ph">https://…</span></div>
            <button class="lk-go" id="lkGo" disabled onclick="fetchLink()" aria-label="Add"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m13 6 6 6-6 6"/></svg></button>
          </div>
          <div class="lk-paste" id="lkPasteWrap">
            <button class="lk-paste-chip" onclick="pasteLink()"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><rect x="8" y="2" width="8" height="4" rx="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/></svg>Paste from clipboard</button>
          </div>

          <!-- preview unfurls -->
          <div class="lk-prev" id="lkPrev">
            <div class="lk-thumb"><div class="glow"></div><div class="disc"><svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><path d="M9 18V5l10-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="16" cy="16" r="3"/></svg></div></div>
            <div class="lk-favrow"><span class="lk-fav"></span><span class="lk-dom">thelisten.mag</span></div>
            <div class="lk-ttl">A Field Guide to Live Jazz This Summer</div>
            <div class="lk-snip">The rooms, the residencies and the late sets worth planning a night around — including a few intimate spots off the usual map.</div>
          </div>
          <div class="lk-reading" id="lkReading"><span class="spin"></span>Reading the page…</div>
        </div>
      </div>

      <!-- ══ LINK REVIEW ══ -->
      <div class="view" data-view="linkReview" data-screen-label="Link review">
        <div class="rv-top">
          <button class="back-btn" onclick="openLink()"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M15 18l-6-6 6-6"/></svg>Back</button>
          <div style="font-family:Dosis;font-weight:600;font-size:17px;color:var(--ink);">Review</div>
          <div style="width:60px;"></div>
        </div>
        <div class="rv-scroll">
          <div class="rv-eyebrow"><span class="dot"></span>Mira read the page</div>
          <div class="rv-photo" style="height:132px;background:linear-gradient(150deg,#243056,#121a33);">
            <div class="mini" style="background:radial-gradient(circle at 72% 26%, rgba(223,184,119,.4), transparent 55%), radial-gradient(circle at 18% 82%, rgba(126,139,201,.4), transparent 55%);"></div>
            <span class="badge"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/></svg>Link · thelisten.mag</span>
            <div class="pv-h" style="font-size:22px;right:16px;top:auto;bottom:34px;">A Field Guide to<br/>Live Jazz</div>
          </div>

          <div class="rv-card" style="margin-top:14px;">
            <div class="rv-typerow">
              <span class="type-chip"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>Article</span>
              <button class="type-edit"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>Change type</button>
            </div>
            <p class="rv-quote"><b>A Field Guide to Live Jazz This Summer</b> — the best rooms and late sets, including a few intimate spots off the map.</p>
          </div>

          <div class="rv-fieldset">
            <div class="fl">Mira's summary</div>
            <div class="conn" style="gap:8px;">
              <div class="conn-row" style="align-items:flex-start;"><span class="conn-ic" style="width:26px;height:26px;border-radius:8px;">1</span><div class="conn-tx"><div class="conn-nm" style="font-weight:400;line-height:1.45;">The Corner Room is named as the best intimate room for late sets.</div></div></div>
              <div class="conn-row" style="align-items:flex-start;"><span class="conn-ic" style="width:26px;height:26px;border-radius:8px;">2</span><div class="conn-tx"><div class="conn-nm" style="font-weight:400;line-height:1.45;">Summer residencies run Thursday–Saturday through August.</div></div></div>
            </div>
          </div>

          <div class="rv-fieldset">
            <div class="fl">Tags &amp; connections Mira found</div>
            <div class="chips" style="margin-bottom:12px;">
              <span class="echip"># jazz <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip"># live-music <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip add">+ Add</span>
            </div>
            <div class="conn">
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Blue Note — Live Jazz</div><div class="conn-sub">Event · mentions The Corner Room</div></div>
                <div class="tog" onclick="this.classList.toggle('off')"></div>
              </div>
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6" stroke-linecap="round"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Maya — likes live jazz</div><div class="conn-sub">Person · maybe share it</div></div>
                <div class="tog off" onclick="this.classList.toggle('off')"></div>
              </div>
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Read later</div><div class="conn-sub">Remind me this weekend</div></div>
                <div class="tog" onclick="this.classList.toggle('off')"></div>
              </div>
            </div>
          </div>
        </div>
        <div class="rv-bar">
          <button class="btn btn--ghost" onclick="go('home')">Discard</button>
          <button class="btn btn--primary" onclick="go('added')">Add to memory</button>
        </div>
      </div>

      <!-- ══ SCREENSHOT CAPTURE ══ -->
      <div class="view" data-view="shot" data-screen-label="Screenshot capture">
        <div class="shot">
          <div class="shot-top">
            <button class="circ-btn" onclick="go('home')" aria-label="Cancel"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#6B6C73" stroke-width="2.2" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></button>
            <div style="width:42px;"></div>
          </div>
          <div class="shot-h">
            <h2>Pick a screenshot</h2>
            <p>Mira reads the text and keeps the details that matter.</p>
          </div>
          <div class="shot-recent">Recent · Screenshots</div>
          <div class="shot-grid">
            <div class="thumb pick" onclick="scanShot()"><span class="tag">✈ Boarding</span><div class="sc-pass"><div class="air">SKYAIR</div><div class="rt">SFO<small>›</small>JFK</div><div class="dt">Aug 2 · 7:40 AM</div><div class="bars"></div></div></div>
            <div class="thumb" onclick="scanShot()"><div class="sc-chat" style="height:100%"><i class="w70"></i><i class="me"></i><i class="w50"></i><i class="me w70"></i><i class="w60"></i><i></i></div></div>
            <div class="thumb" onclick="scanShot()"><div class="sc-map" style="height:100%"></div></div>
            <div class="thumb" onclick="scanShot()"><div class="sc-recg" style="height:100%"><i class="g"></i><i></i><i class="w60"></i><i></i><i class="w60"></i></div></div>
            <div class="thumb" onclick="scanShot()"><div class="sc-web" style="height:100%"></div></div>
            <div class="thumb" onclick="scanShot()"><div class="sc-note" style="height:100%"><i></i><i class="w60"></i><i></i><i></i><i class="w60"></i></div></div>
          </div>

          <!-- scanning overlay -->
          <div class="shot-scan" id="shotScan">
            <div class="shot-frame">
              <div class="sc-pass"><div class="air">SKYAIR · SA 482</div><div class="rt">SFO<small>›</small>JFK</div><div class="dt" style="margin-top:14px;">Sat, Aug 2 · 7:40 AM — 4:15 PM · Seat 14C · QX7P2R</div><div class="bars"></div></div>
              <div class="shot-line"></div>
              <div class="shot-det a" style="left:9%;top:8%;width:70%;height:11%;"><span class="dl">Flight</span></div>
              <div class="shot-det b" style="left:9%;top:22%;width:64%;height:15%;"><span class="dl">Route</span></div>
              <div class="shot-det c" style="left:9%;top:66%;width:82%;height:9%;"><span class="dl">Date · seat</span></div>
              <div class="shot-chip"><span class="spin"></span>Reading this screenshot…</div>
            </div>
          </div>
        </div>
      </div>

      <!-- ══ SCREENSHOT REVIEW ══ -->
      <div class="view" data-view="shotReview" data-screen-label="Screenshot review">
        <div class="rv-top">
          <button class="back-btn" onclick="openShot()"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M15 18l-6-6 6-6"/></svg>Back</button>
          <div style="font-family:Dosis;font-weight:600;font-size:17px;color:var(--ink);">Review</div>
          <div style="width:60px;"></div>
        </div>
        <div class="rv-scroll">
          <div class="rv-eyebrow"><span class="dot"></span>Mira read your screenshot</div>
          <div class="rv-photo" style="height:120px;background:linear-gradient(155deg,#1b2b6b,#0f1c4d);">
            <span class="badge"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="3" width="16" height="14" rx="2"/><path d="M8 21h8"/></svg>Screenshot</span>
            <div class="pv-h" style="font-size:24px;top:auto;bottom:18px;">SFO › JFK</div>
            <div class="pv-d" style="bottom:auto;top:22px;left:auto;right:16px;color:#b9c0da;">SA 482</div>
          </div>

          <div class="rv-card" style="margin-top:14px;">
            <div class="rv-typerow">
              <span class="type-chip"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.8 19.2 16 11l3.5-3.5a2.1 2.1 0 0 0-3-3L13 8 4.8 6.2a.5.5 0 0 0-.5.8L8 11l-3 3H3l2 3 3 2v-2l3-3 4.2 3.7a.5.5 0 0 0 .8-.5Z"/></svg>Trip</span>
              <button class="type-edit"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>Change type</button>
            </div>
            <p class="rv-quote">Flight <b>SA 482</b>, <b>SFO → JFK</b> on <b>Sat, Aug 2</b> at 7:40 AM. Seat 14C · conf. QX7P2R.</p>
          </div>

          <div class="rv-fieldset">
            <div class="fl">Details Mira read from the image</div>
            <div class="chips">
              <span class="echip">✈️ SA 482 <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip">📅 Aug 2, 7:40 AM <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip">💺 14C <span class="ex"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg></span></span>
              <span class="echip add">+ Add</span>
            </div>
          </div>

          <div class="rv-fieldset">
            <div class="fl">Suggested actions</div>
            <div class="conn">
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Add to calendar</div><div class="conn-sub">Sat, Aug 2 · 7:40 AM</div></div>
                <div class="tog" onclick="this.classList.toggle('off')"></div>
              </div>
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Remind me to check in</div><div class="conn-sub">Fri, Aug 1 · 24h before</div></div>
                <div class="tog" onclick="this.classList.toggle('off')"></div>
              </div>
              <div class="conn-row">
                <span class="conn-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 9h16M4 15h16M10 3 8 21M16 3l-2 18"/></svg></span>
                <div class="conn-tx"><div class="conn-nm">Trip to New York</div><div class="conn-sub">Topic · 3 related memories</div></div>
                <div class="tog off" onclick="this.classList.toggle('off')"></div>
              </div>
            </div>
          </div>
        </div>
        <div class="rv-bar">
          <button class="btn btn--ghost" onclick="go('home')">Discard</button>
          <button class="btn btn--primary" onclick="go('added')">Add to memory</button>
        </div>
      </div>

      <!-- ══ ADDED ══ -->
      <div class="view" data-view="added" data-screen-label="Added">
        <div class="center-col">
          <div class="added-mark"><svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12 5 5 9-11"/></svg></div>
          <h1 class="added-title">Kept in memory</h1>
          <p class="added-sub">Linked to <b>2 memories</b> and 1 reminder. Mira will bring it back at the right time.</p>
          <div class="added-graph">
            <span class="gn"></span><span class="gline"></span><span class="gn hub"></span><span class="gline"></span><span class="gn"></span>
          </div>
          <button class="btn btn--primary" style="flex:0 0 auto;width:220px;margin-top:40px;" onclick="finishAdd()">Done</button>
        </div>
      </div>
`;

function CaptureScreen({ go: appGo }) {
  const ref = React.useRef(null);
  React.useEffect(() => {
    const root = ref.current;
    if (!root) return;
    const timers = [];
    const T = (fn, ms) => { const id = setTimeout(fn, ms); timers.push(id); return id; };
    let timerInt = null, tSec = 0;
    const gid = (id) => root.querySelector('#' + id);
    const views = [...root.querySelectorAll('.view')];

    function go(name) {
      if (name === 'home') { cleanup(); appGo('home'); return; }
      views.forEach(v => v.classList.toggle('is-active', v.dataset.view === name));
    }
    function openSheet() { const s = gid('scrim'); if (s) s.classList.add('is-active'); }
    function closeSheet(ev) { const s = gid('scrim'); if (s) s.classList.remove('is-active'); if (ev) { appGo('home'); } }

    const tokens = [
      { t: "Call" }, { t: "John", mark: true, chip: { ic: "👤", label: "John" } }, { t: "before" },
      { t: "Friday", mark: true, chip: { ic: "📅", label: "Friday" } }, { t: "to" }, { t: "confirm" }, { t: "the" },
      { t: "contract", mark: true, chip: { ic: "#", label: "contract" } }, { t: "terms" }, { t: "and" },
      { t: "send" }, { t: "the" }, { t: "signed" }, { t: "copy." }
    ];
    let voiceTimers = [];
    function stopVoice() { voiceTimers.forEach(clearTimeout); voiceTimers = []; clearInterval(timerInt); timerInt = null; }

    function startListening() {
      closeSheet(); stopVoice(); go('listen');
      const words = gid('vWords'), chips = gid('vChips');
      words.innerHTML = ''; chips.innerHTML = '';
      const caret = document.createElement('span'); caret.className = 'caret';
      tSec = 0; gid('vTimer').textContent = '0:00';
      timerInt = setInterval(() => { tSec++; const m = Math.floor(tSec / 60), sc = String(tSec % 60).padStart(2, '0'); gid('vTimer').textContent = m + ':' + sc; }, 1000);
      tokens.forEach((tok, i) => {
        const el = tok.mark ? document.createElement('mark') : document.createElement('span');
        el.className = 'w'; el.textContent = tok.t + ' '; words.appendChild(el);
        let chipEl = null;
        if (tok.chip) { chipEl = document.createElement('span'); chipEl.className = 'v-chip'; chipEl.innerHTML = '<span>' + tok.chip.ic + '</span>' + tok.chip.label; chips.appendChild(chipEl); }
        voiceTimers.push(setTimeout(() => { el.classList.add('on'); words.appendChild(caret); if (chipEl) chipEl.classList.add('on'); }, 500 + i * 340));
      });
      voiceTimers.push(setTimeout(() => { caret.remove(); }, 500 + tokens.length * 340 + 400));
      voiceTimers.push(setTimeout(finishVoice, 500 + tokens.length * 340 + 1600));
    }
    function finishVoice() { stopVoice(); startProcessing(); }
    function startProcessing() {
      closeSheet(); stopVoice(); go('proc');
      const steps = [...root.querySelectorAll('#procSteps .pstep')];
      steps.forEach(st => st.classList.remove('done'));
      steps.forEach((st, k) => T(() => st.classList.add('done'), 500 + k * 650));
      T(() => go('review'), 500 + steps.length * 650 + 500);
    }
    function finishAdd() { go('home'); }

    function openLink() {
      closeSheet(); stopVoice(); go('link');
      const url = gid('lkUrl'); url.innerHTML = '<span class="ph">https://…</span>';
      gid('lkGo').disabled = true; gid('lkInput').classList.remove('focus');
      gid('lkPasteWrap').style.display = ''; gid('lkPrev').classList.remove('show'); gid('lkReading').classList.remove('show');
    }
    const LINK_URL = 'https://thelisten.mag/live-jazz-summer';
    function pasteLink() {
      const url = gid('lkUrl'); gid('lkInput').classList.add('focus'); gid('lkPasteWrap').style.display = 'none';
      let i = 0;
      const tick = setInterval(() => { i++; url.innerHTML = LINK_URL.slice(0, i) + '<span class="car"></span>'; gid('lkGo').disabled = i < LINK_URL.length; if (i >= LINK_URL.length) { clearInterval(tick); url.innerHTML = LINK_URL; T(fetchLink, 450); } }, 22);
    }
    function fetchLink() { gid('lkPrev').classList.add('show'); T(() => gid('lkReading').classList.add('show'), 500); T(() => go('linkReview'), 2600); }
    function openShot() { closeSheet(); stopVoice(); gid('shotScan').classList.remove('on'); go('shot'); }
    function scanShot() { const sc = gid('shotScan'); sc.classList.add('on'); T(() => { sc.classList.remove('on'); go('shotReview'); }, 3200); }
    function openPhoto() { closeSheet(); stopVoice(); gid('cam').classList.remove('scan'); go('photo'); }
    function capturePhoto() { const cam = gid('cam'); cam.classList.add('scan'); T(() => { cam.classList.remove('scan'); go('photoReview'); }, 3400); }

    // build waveform bars
    const vWave = gid('vWave');
    if (vWave) for (let i = 0; i < 27; i++) { const sp = document.createElement('span'); sp.style.animationDelay = (i * 0.055) + 's'; vWave.appendChild(sp); }

    // expose to inline handlers in the injected HTML
    const api = { go, openSheet, closeSheet, startListening, stopVoice, finishVoice, startProcessing, finishAdd, openLink, pasteLink, fetchLink, openShot, scanShot, openPhoto, capturePhoto };
    Object.assign(window, api);

    function cleanup() { timers.forEach(clearTimeout); stopVoice(); Object.keys(api).forEach(k => { if (window[k] === api[k]) delete window[k]; }); }

    // jump straight into the mode picked from the entry sheet
    const starters = { voice: startListening, photo: openPhoto, screenshot: openShot, link: openLink, type: startProcessing };
    (starters[window.__miraCap] || startListening)();
    window.__miraCap = null;
    return cleanup;
  }, []);

  return <div className="mira-screen-body rd-captureflow" ref={ref} dangerouslySetInnerHTML={{ __html: CAPTURE_HTML }} />;
}

Object.assign(window, { CaptureScreen });
