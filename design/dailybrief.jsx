// Mira — Daily Brief, wired into the prototype. Four states: full / empty / overdue / first-time.
// Rich markup rendered as scoped HTML (.rd-brief); imperative state + snooze logic runs in the effect.

const BRIEF_HTML = `
<div class="state-toggle">
    <button id="stFull" class="on" onclick="setDay('full')">Full day</button>
    <button id="stEmpty" onclick="setDay('empty')">Empty day</button>
    <button id="stOverdue" onclick="setDay('overdue')">Overdue</button>
    <button id="stFirst" onclick="setDay('first')">First-time</button>
  </div>
<div class="scroll">
        <div class="db-head">
          <div class="db-eyebrow">Monday · July 6</div>
          <div class="db-titlerow">
            <div class="db-title">Daily Brief<small>Good morning, Sara</small></div>
            <button class="db-gear" aria-label="Settings"><svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#6B6C73" stroke-width="1.7"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg></button>
          </div>
        </div>

        <div id="briefFull">
        <!-- Mira summary -->
        <div class="db-summary">
          <div class="db-orb"></div>
          <p>Two things need you today, and I brought back a memory that's about to matter — the <b>Blue Note tickets</b> before they sell out.</p>
        </div>

        <!-- TODAY timeline -->
        <div class="db-sec"><span class="l"><span class="ic"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v4l3 2"/></svg></span>Today</span><span class="count">2 events</span></div>
        <div class="rail">
          <div class="tl">
            <div class="tl-time">10<span>:00 AM</span></div>
            <div class="tl-node"><span class="n"></span></div>
            <div class="card">
              <div class="card-t">Product review with the team</div>
              <div class="card-row"><span class="tp"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>Event</span><span class="card-sub">30 min · Studio</span></div>
            </div>
          </div>
          <div class="tl">
            <div class="tl-time">3<span>:00 PM</span></div>
            <div class="tl-node"><span class="n now"></span></div>
            <div class="card">
              <div class="card-t">Meeting with John</div>
              <div class="card-row"><span class="tp"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>Event</span><span class="card-sub">The contract call</span></div>
              <div class="prep"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#14328C" stroke-width="1.8" stroke-linecap="round"><path d="M12 2a7 7 0 0 0-4 12.7c.6.5 1 1.2 1 2h6c0-.8.4-1.5 1-2A7 7 0 0 0 12 2Z"/><path d="M9 21h6"/></svg><span>Mira: bring the <b style="font-weight:600">signed contract</b> — it connects to this meeting.</span></div>
            </div>
          </div>
        </div>

        <!-- NEEDS YOU -->
        <div class="db-sec"><span class="l"><span class="ic"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m8.5 12 2.5 2.5 4.5-5"/></svg></span>Needs you soon</span><span class="count">1 task</span></div>
        <div class="task" id="task1">
          <button class="chk" onclick="document.getElementById('task1').classList.toggle('done')" aria-label="Complete"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12 5 5 9-11"/></svg></button>
          <div class="task-body">
            <div class="task-t">Call John to confirm the contract terms</div>
            <div class="card-row" style="margin-top:7px;"><span class="due"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/></svg>Due Friday · 2 days</span></div>
          </div>
        </div>

        <!-- RESURFACED -->
        <div class="db-sec"><span class="l"><span class="ic"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5"/></svg></span>Mira resurfaced</span><span class="count">2</span></div>
        <div class="res">
          <div class="res-ic img"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"><path d="M9 18V5l10-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="16" cy="16" r="3"/></svg></div>
          <div class="res-body">
            <div class="res-why">Because the date is close</div>
            <div class="res-t">Blue Note — Fri, Jul 18</div>
            <div class="res-sub">From a photo you took. Intimate rooms sell out — worth booking this week?</div>
            <div class="res-actions">
              <button class="rb solid">Buy tickets</button>
              <button class="rb ghost">Remind Thursday</button>
            </div>
          </div>
        </div>
        <div class="res">
          <div class="res-ic"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v18H6.5A2.5 2.5 0 0 0 4 22.5z"/><path d="M4 4.5v15"/></svg></div>
          <div class="res-body">
            <div class="res-why">Saved 3 days ago, still unread</div>
            <div class="res-t">“The Overstory”</div>
            <div class="res-sub">Maya's recommendation. A quiet weekend read for your coast trip?</div>
          </div>
        </div>

        <!-- HANDLED QUIETLY -->
        <div class="db-sec"><span class="l"><span class="ic"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M20 6 9 17l-5-5"/></svg></span>Handled quietly</span></div>
        <div class="handled">
          <div class="handled-row">
            <span class="handled-ic"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg></span>
            <span class="handled-tx"><b>Flight SA 482</b> added to your calendar for Aug 2</span>
          </div>
          <div class="handled-row">
            <span class="handled-ic"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/></svg></span>
            <span class="handled-tx">Check-in reminder set for <b>Aug 1</b></span>
          </div>
        </div>

        <div class="db-end">That's your day.<br/>Everything else is safe in memory.</div>
        </div><!-- /briefFull -->

        <div id="briefEmpty" style="display:none">
          <div class="empty-hero">
            <div class="empty-orb"><span class="empty-ring"></span></div>
            <h2>Nothing needs you today</h2>
            <p>Your day is open and no memory is waiting on you. I'll keep everything safe and speak up the moment something matters.</p>
          </div>
          <div class="empty-reassure">
            <div class="er">
              <span class="ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg></span>
              <span class="num">34</span><span class="lbl">memories held safe</span>
            </div>
            <div class="er">
              <span class="ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/></svg></span>
              <span class="num">0</span><span class="lbl">reminders due</span>
            </div>
          </div>

          <button class="empty-capture">
            <span class="cta-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/></svg></span>
            <span class="cta-tx"><b>Capture a thought</b><span>Drop anything on your mind — I'll hold it for you.</span></span>
          </button>
        </div>

        <div id="briefOverdue" style="display:none">
          <div class="ov-summary">
            <div class="ov-orb"></div>
            <p>A few things slipped past while you were busy. Nothing's lost — I held onto them. Let's clear them together, no rush.</p>
          </div>

          <div class="ov-sec"><span class="ic"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/></svg></span>Waiting on you<span class="count">3 reminders</span></div>

          <div class="ov-card">
            <div class="ov-ic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l10-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="16" cy="16" r="3"/></svg></div>
            <div class="ov-body">
              <div class="ov-when">Due 3 days ago</div>
              <div class="ov-t">Buy Blue Note tickets</div>
              <div class="ov-sub">Show is Jul 18 — a few seats left when you saved this.</div>
              <div class="ov-actions">
                <button class="ov-btn solid">Do it now</button>
                <button class="ov-btn ghost" onclick="snooze(this)">Snooze</button>
                <button class="ov-btn ghost">Done</button>
              </div>
            </div>
          </div>

          <div class="ov-card">
            <div class="ov-ic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v18H6.5A2.5 2.5 0 0 0 4 22.5z"/><path d="M4 4.5v15"/></svg></div>
            <div class="ov-body">
              <div class="ov-when">Due yesterday</div>
              <div class="ov-t">Send John the signed contract</div>
              <div class="ov-sub">Connects to your note from the meeting last week.</div>
              <div class="ov-actions">
                <button class="ov-btn solid">Do it now</button>
                <button class="ov-btn ghost" onclick="snooze(this)">Snooze</button>
                <button class="ov-btn ghost">Done</button>
              </div>
            </div>
          </div>

          <div class="ov-card">
            <div class="ov-ic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M3 5h6l2 3h10v11H3z"/><circle cx="12" cy="13" r="2.5"/></svg></div>
            <div class="ov-body">
              <div class="ov-when">Due 2 days ago</div>
              <div class="ov-t">Reply to Maya about the weekend</div>
              <div class="ov-sub">She asked about the coast trip you were planning.</div>
              <div class="ov-actions">
                <button class="ov-btn solid">Do it now</button>
                <button class="ov-btn ghost" onclick="snooze(this)">Snooze</button>
                <button class="ov-btn ghost">Done</button>
              </div>
            </div>
          </div>

          <button class="ov-clear"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>Clear all — I'll ask again later</button>

          <div class="db-end">Once these are clear,<br/>your day is light again.</div>
        </div>

        <div id="briefFirst" style="display:none">
          <div class="ft-hero">
            <div class="ft-orb"><span class="ft-ring r1"></span><span class="ft-ring r2"></span></div>
            <div class="ft-badge"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M18.4 5.6l-2.1 2.1M7.7 16.3l-2.1 2.1"/></svg>Welcome</div>
            <h2>Hello, Sara.<br/>This is your Brief.</h2>
            <p>Right now it's empty — that's normal. As you capture thoughts, I'll gather what matters each morning and leave the rest in quiet memory.</p>
          </div>

          <div class="ft-steps">
            <div class="ft-step">
              <span class="ft-num"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/></svg></span>
              <div class="ft-tx"><div class="h">Capture anything</div><div class="s">Say it, type it, snap a photo or drop a link. No folders, no filing.</div></div>
            </div>
            <div class="ft-step">
              <span class="ft-num"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="5" r="2.2"/><circle cx="5.5" cy="18" r="2.2"/><circle cx="18.5" cy="18" r="2.2"/><path d="M11 6.8 6.6 15.6M13 6.8l4.4 8.8M7.9 18h8.2"/></svg></span>
              <div class="ft-tx"><div class="h">I connect the dots</div><div class="s">Mira links people, dates and ideas quietly in the background.</div></div>
            </div>
            <div class="ft-step">
              <span class="ft-num"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m8.5 12 2.5 2.5 4.5-5"/></svg></span>
              <div class="ft-tx"><div class="h">Your Brief fills in</div><div class="s">Each morning I bring back what's about to matter — nothing more.</div></div>
            </div>
          </div>

          <button class="ft-cta">
            <span class="cta-ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/></svg></span>
            <span class="cta-tx"><b>Capture your first thought</b><span>Try it now — I'll remember it for you.</span></span>
          </button>
          <div class="ft-reassure"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="10" width="16" height="11" rx="2.5"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg>Private by default. Only you can see your memory.</div>
        </div>
      </div>

      <div class="nav">
        <button class="navitem"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V21h14V9.5"/></svg>Home</button>
        <button class="navitem"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5h11"/><path d="M4 10h11"/><path d="M4 15h7"/><circle cx="18.5" cy="16.5" r="3"/><path d="M20.8 18.8 23 21"/></svg>Library</button>
        <div class="navspacer"></div>
        <button class="navitem"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="5" r="2.4"/><circle cx="5.5" cy="18" r="2.4"/><circle cx="18.5" cy="18" r="2.4"/><path d="M11 7 6.6 15.8"/><path d="M13 7l4.4 8.8"/><path d="M7.9 18h8.2"/></svg>Canvas</button>
        <button class="navitem is-active"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m8.5 12 2.5 2.5 4.5-5"/></svg>Brief</button>
        <button class="navmic" aria-label="Capture"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg></button>
      </div>
<div class="toast" id="toast">
        <span class="toast-ic"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/></svg></span>
        <span class="toast-tx" id="toastTx">Snoozed until <b>tomorrow</b>. I'll bring it back then.</span>
        <button class="toast-undo" onclick="undoSnooze()">Undo</button>
      </div>
`;

function DailyBriefScreen({ go: appGo }) {
  const ref = React.useRef(null);
  React.useEffect(() => {
    const root = ref.current;
    if (!root) return;
    const gid = (id) => root.querySelector('#' + id);
    let toastTimer = null, lastSnoozed = null;

    function showToast() {
      const t = gid('toast'); t.classList.add('show');
      clearTimeout(toastTimer); toastTimer = setTimeout(() => t.classList.remove('show'), 4200);
    }
    function snooze(btn) {
      const card = btn.closest('.ov-card');
      const title = card.querySelector('.ov-t').textContent;
      card.style.transition = 'opacity .3s ease, transform .3s ease, max-height .35s ease, margin .3s ease, padding .3s ease';
      card.style.overflow = 'hidden';
      card.style.maxHeight = card.offsetHeight + 'px';
      requestAnimationFrame(() => {
        card.style.opacity = '0'; card.style.transform = 'translateX(-12px)';
        card.style.maxHeight = '0px'; card.style.marginTop = '0px';
        card.style.paddingTop = '0px'; card.style.paddingBottom = '0px';
      });
      lastSnoozed = card;
      gid('toastTx').innerHTML = 'Snoozed “<b>' + title + '</b>” until tomorrow.';
      showToast();
    }
    function undoSnooze() {
      if (lastSnoozed) {
        const c = lastSnoozed;
        c.style.maxHeight = ''; c.style.opacity = ''; c.style.transform = '';
        c.style.marginTop = ''; c.style.paddingTop = ''; c.style.paddingBottom = ''; c.style.overflow = '';
        lastSnoozed = null;
      }
      gid('toast').classList.remove('show'); clearTimeout(toastTimer);
    }
    function setDay(mode) {
      const full = mode === 'full', empty = mode === 'empty', overdue = mode === 'overdue', first = mode === 'first';
      gid('briefFull').style.display = full ? '' : 'none';
      gid('briefEmpty').style.display = empty ? '' : 'none';
      gid('briefOverdue').style.display = overdue ? '' : 'none';
      gid('briefFirst').style.display = first ? '' : 'none';
      gid('stFull').classList.toggle('on', full);
      gid('stEmpty').classList.toggle('on', empty);
      gid('stOverdue').classList.toggle('on', overdue);
      gid('stFirst').classList.toggle('on', first);
      root.querySelector('.db-title small').textContent = first ? 'Welcome to Mira' : 'Good morning, Sara';
      root.querySelector('.db-eyebrow').textContent = first ? 'Getting started' : 'Monday · July 6';
      root.querySelector('.scroll').scrollTop = 0;
      gid('toast').classList.remove('show');
    }

    // expose for inline handlers (state toggle, snooze, undo)
    const api = { setDay, snooze, undoSnooze, showToast };
    Object.assign(window, api);

    // wire bottom nav + capture CTAs to the app navigator
    const navBtns = root.querySelectorAll('.nav .navitem');
    if (navBtns[0]) navBtns[0].onclick = () => appGo('home');
    if (navBtns[1]) navBtns[1].onclick = () => appGo('library');
    if (navBtns[2]) navBtns[2].onclick = () => appGo('canvas');
    // navBtns[3] is Brief (active) — no-op
    const mic = root.querySelector('.nav .navmic'); if (mic) mic.onclick = () => appGo('capture');
    root.querySelectorAll('.empty-capture, .ft-cta').forEach(b => b.onclick = () => appGo('capture'));
    const gear = root.querySelector('.db-gear'); if (gear) gear.onclick = () => appGo('account');

    setDay('full');
    return () => { clearTimeout(toastTimer); Object.keys(api).forEach(k => { if (window[k] === api[k]) delete window[k]; }); };
  }, []);

  return <div className="mira-screen-body rd-brief" ref={ref} dangerouslySetInnerHTML={{ __html: BRIEF_HTML }} />;
}

Object.assign(window, { DailyBriefScreen });
