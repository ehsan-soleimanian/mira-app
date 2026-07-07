// Mira — Memory detail. The pushed view you reach by tapping a memory.
// Shows the capture, Mira's understanding, its connections, people & source.
// Calm, single-column, its own back header + action bar (no tab nav).

function MemoryScreen({ go, goBack, backLabel }) {
  const { useState, useEffect, useRef } = React;
  // memory kind: "note" (typed) | "voice" (recorded). Set by whatever opened this detail.
  const kind = (typeof localStorage !== "undefined" && localStorage.getItem("mira-mem-kind")) || "note";
  const isVoice = kind === "voice";

  const [pinned, setPinned] = useState(false);
  const [reminded, setReminded] = useState(true);
  const [menu, setMenu] = useState(false);       // ⋯ action menu
  const [confirm, setConfirm] = useState(false); // delete confirm sheet
  const [phase, setPhase] = useState("");        // "" | deleting
  const [editing, setEditing] = useState(false);
  const [edited, setEdited] = useState(false);
  const [saved, setSaved] = useState(false);     // "re-read" toast

  // voice playback (simulated)
  const CLIP = 34; // seconds
  const [playing, setPlaying] = useState(false);
  const [pos, setPos] = useState(0);             // seconds elapsed
  const [speed, setSpeed] = useState(1);
  const tick = useRef(null);
  useEffect(() => {
    if (!playing) { clearInterval(tick.current); return; }
    tick.current = setInterval(() => {
      setPos((p) => {
        const n = p + 0.1 * speed;
        if (n >= CLIP) { setPlaying(false); return 0; }
        return n;
      });
    }, 100);
    return () => clearInterval(tick.current);
  }, [playing, speed]);
  const fmt = (s) => `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, "0")}`;

  const noteTitle = "Contract with John";
  const noteBody = "Needs a call to confirm the terms before Friday. The signed copy is in the folder from last week's meeting — John wants the partnership scope narrowed to Q3 first.";
  const voiceTitle = "Idea for the Q3 launch";
  const voiceBody = "So the thought is — we lead the Q3 launch with the onboarding story, not the feature list. People connect with the calm, not the checklist. Let's ask design for a quiet hero and pull the three testimonials from last quarter. Circle back with Priya on timing.";

  const [title, setTitle] = useState(isVoice ? voiceTitle : noteTitle);
  const [body, setBody] = useState(isVoice ? voiceBody : noteBody);
  const [dTitle, setDTitle] = useState(title);
  const [dBody, setDBody] = useState(body);
  const bodyRef = useRef(null);
  const [fixed, setFixed] = useState([]);        // resolved flagged-word indices
  // words Mira transcribed with low confidence — tap to jump & correct
  const FLAGS = ["testimonials", "Priya"];
  const jumpToWord = (w, i) => {
    const ta = bodyRef.current; if (!ta) return;
    const idx = ta.value.indexOf(w);
    ta.focus();
    if (idx >= 0) ta.setSelectionRange(idx, idx + w.length);
    setFixed((f) => (f.includes(i) ? f : [...f, i]));
  };

  const startEdit = () => { setDTitle(title); setDBody(body); setFixed([]); setPlaying(false); setEditing(true); };
  const cancelEdit = () => setEditing(false);
  const saveEdit = () => {
    setTitle(dTitle.trim() || title);
    setBody(dBody.trim() || body);
    setEditing(false); setEdited(true); setSaved(true);
    setTimeout(() => setSaved(false), 2800);
  };

  const doDelete = () => {
    setConfirm(false);
    setPhase("deleting");
    // let the card fold away, then leave to the Library
    setTimeout(() => go("library"), 620);
  };

  const Ic = ({ d, w = 20, sw = 1.75, fill = "none" }) => (
    <svg width={w} height={w} viewBox="0 0 24 24" fill={fill} stroke="currentColor" strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">{d}</svg>
  );

  // Edge-swipe to dismiss: drag from the left ~24px, follow the finger, and if
  // pulled past a third of the width (or flicked), pop back. Otherwise settle.
  const [drag, setDrag] = useState(0);
  const [swiping, setSwiping] = useState(false);
  const sw = useRef({ x0: 0, active: false, w: 0 });
  const onTouchStart = (e) => {
    if (editing) return;
    const t = e.touches[0];
    if (t.clientX > 28) return;              // only from the left edge
    sw.current = { x0: t.clientX, active: true, w: e.currentTarget.offsetWidth };
    setSwiping(true);
  };
  const onTouchMove = (e) => {
    if (!sw.current.active) return;
    setDrag(Math.max(0, e.touches[0].clientX - sw.current.x0));
  };
  const onTouchEnd = () => {
    if (!sw.current.active) return;
    const passed = drag > sw.current.w * 0.32;
    sw.current.active = false;
    setSwiping(false);
    if (passed) { setDrag(sw.current.w); setTimeout(goBack, 180); }
    else setDrag(0);
  };

  // connected memories (the graph edges)
  const LINKS = isVoice ? [
    { type: "event", title: "Q3 launch planning", sub: "Next Tuesday · on your calendar", rel: "Related event" },
    { type: "note", title: "Onboarding story draft", sub: "Note · last week", rel: "Builds on" },
    { type: "voice", title: "Priya — timing thoughts", sub: "Voice · 5 days ago", rel: "Same topic" },
  ] : [
    { type: "event", title: "Meeting with John", sub: "Last Thursday · where this came up", rel: "Discussed here" },
    { type: "photo", title: "Signed contract — page 1", sub: "Photo · read by Mira", rel: "Attached" },
    { type: "note", title: "Q3 partnership terms", sub: "Note · 3 days ago", rel: "Related topic" },
  ];

  // static waveform silhouette (36 bars, 0..1)
  const WAVE = [.28,.42,.6,.35,.5,.78,.55,.4,.66,.9,.62,.44,.3,.52,.72,.85,.6,.38,.48,.7,.95,.68,.5,.34,.46,.64,.8,.58,.4,.3,.52,.68,.44,.36,.5,.26];

  const typePath = {
    note: <path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />,
    voice: <><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></>,
    link: <><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1" /><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1" /></>,
    event: <><rect x="3" y="4" width="18" height="17" rx="2.5" /><path d="M16 2v4M8 2v4M3 10h18" /></>,
    photo: <><rect x="3" y="5" width="18" height="14" rx="2.5" /><circle cx="12" cy="12" r="3.2" /></>,
  };

  return (
    <div className={"mira-screen-body rd-memory" + (phase === "deleting" ? " is-deleting" : "")} data-screen-label="Memory detail"
      onTouchStart={onTouchStart} onTouchMove={onTouchMove} onTouchEnd={onTouchEnd}
      style={drag ? { transform: `translateX(${drag}px)`, transition: swiping ? "none" : "transform .18s ease", boxShadow: "-18px 0 40px rgba(20,28,52,.10)" } : undefined}>
      {/* header */}
      <div className="md-head">
        <button className="md-back" aria-label={"Back to " + (backLabel || "Home")} onClick={goBack}>
          <Ic d={<path d="M15 5l-7 7 7 7" />} sw={2} />
          <span className="md-back-label">{backLabel || "Home"}</span>
        </button>
        <div className="md-head-actions">
          <button className={"md-icbtn" + (pinned ? " on" : "")} aria-label="Pin" onClick={() => setPinned(!pinned)}>
            <Ic d={<path d="M12 17v5M9 3h6l-1 7 3 3H7l3-3-1-7Z" />} fill={pinned ? "currentColor" : "none"} />
          </button>
          <div className="md-more-wrap">
            <button className={"md-icbtn" + (menu ? " on" : "")} aria-label="More" onClick={() => setMenu(!menu)}>
              <Ic d={<><circle cx="12" cy="5" r="1.4" /><circle cx="12" cy="12" r="1.4" /><circle cx="12" cy="19" r="1.4" /></>} sw={2} />
            </button>
            {menu && (
              <>
                <div className="md-menu-catch" onClick={() => setMenu(false)} />
                <div className="md-menu" role="menu">
                  <button className="md-menu-item" onClick={() => { setMenu(false); setPinned(!pinned); }}>
                    <Ic d={<path d="M12 17v5M9 3h6l-1 7 3 3H7l3-3-1-7Z" />} w={17} sw={1.8} />
                    {pinned ? "Unpin" : "Pin to top"}
                  </button>
                  <button className="md-menu-item" onClick={() => { setMenu(false); startEdit(); }}>
                    <Ic d={<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />} w={17} sw={1.8} />
                    Edit note
                  </button>
                  <button className="md-menu-item" onClick={() => { setMenu(false); go("library"); }}>
                    <Ic d={<><rect x="3" y="4" width="18" height="16" rx="2.5" /><path d="M3 9h18" /></>} w={17} sw={1.8} />
                    Add to collection
                  </button>
                  <div className="md-menu-sep" />
                  <button className="md-menu-item is-danger" onClick={() => { setMenu(false); setConfirm(true); }}>
                    <Ic d={<><path d="M3 6h18M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2M19 6l-1 14a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1L5 6" /><path d="M10 11v6M14 11v6" /></>} w={17} sw={1.8} />
                    Delete memory
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      </div>

      <div className="md-scroll">
        {/* type + time */}
        <div className="md-typerow">
          <span className="md-type">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">{isVoice ? typePath.voice : typePath.note}</svg>
            {isVoice ? "Voice note · 0:34" : "Note"}
          </span>
          <span className="md-time">{edited ? "Edited just now · today, 4:12 PM" : (isVoice ? "Recorded 2h ago · today, 4:12 PM" : "Captured 2h ago · today, 4:12 PM")}</span>
        </div>

        {editing && (
          <div className="md-editbar">
            <Ic d={<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />} w={15} sw={1.8} />
            {isVoice ? "Editing the transcript — Mira will re-read it and refresh connections when you save." : "Editing note — Mira will re-read it and refresh connections when you save."}
          </div>
        )}

        {/* title */}
        {editing
          ? <input className="md-title-input" value={dTitle} onChange={(e) => setDTitle(e.target.value)} placeholder="Title" />
          : <h1 className="md-title">{title}</h1>}

        {/* voice: audio player */}
        {isVoice && !editing && (
          <div className="md-player">
            <button className="md-play" aria-label={playing ? "Pause" : "Play"} onClick={() => setPlaying(!playing)}>
              {playing
                ? <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="5" width="4" height="14" rx="1.3" /><rect x="14" y="5" width="4" height="14" rx="1.3" /></svg>
                : <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.2v13.6a1 1 0 0 0 1.5.87l11-6.8a1 1 0 0 0 0-1.74l-11-6.8A1 1 0 0 0 8 5.2Z" /></svg>}
            </button>
            <div className="md-wave" onClick={(e) => {
              const r = e.currentTarget.getBoundingClientRect();
              setPos(Math.max(0, Math.min(1, (e.clientX - r.left) / r.width)) * CLIP);
            }}>
              {WAVE.map((h, i) => {
                const done = (i + 0.5) / WAVE.length <= pos / CLIP;
                return <span key={i} className={"md-bar" + (done ? " on" : "")} style={{ height: (18 + h * 30) + "px" }} />;
              })}
            </div>
            <div className="md-player-meta">
              <span className="md-ptime">{fmt(pos)} / {fmt(CLIP)}</span>
              <button className="md-speed" onClick={() => setSpeed(speed === 1 ? 1.5 : speed === 1.5 ? 2 : 1)}>{speed}×</button>
            </div>
          </div>
        )}

        {/* the capture (note body / voice transcript) */}
        {editing
          ? (isVoice
              ? <>
                  <div className="md-vedit-replay">
                    <button className="md-vedit-play" aria-label={playing ? "Pause" : "Replay"} onClick={() => setPlaying(!playing)}>
                      {playing
                        ? <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="5" width="4" height="14" rx="1.3" /><rect x="14" y="5" width="4" height="14" rx="1.3" /></svg>
                        : <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.2v13.6a1 1 0 0 0 1.5.87l11-6.8a1 1 0 0 0 0-1.74l-11-6.8A1 1 0 0 0 8 5.2Z" /></svg>}
                    </button>
                    <div className="md-vedit-wave" onClick={(e) => {
                      const r = e.currentTarget.getBoundingClientRect();
                      setPos(Math.max(0, Math.min(1, (e.clientX - r.left) / r.width)) * CLIP);
                    }}>
                      {WAVE.map((h, i) => {
                        const done = (i + 0.5) / WAVE.length <= pos / CLIP;
                        return <span key={i} className={"md-vedit-bar" + (done ? " on" : "")} style={{ height: (12 + h * 20) + "px" }} />;
                      })}
                    </div>
                    <span className="md-vedit-time">{fmt(pos)}</span>
                  </div>
                  <div className="md-flags">
                    <span className="md-flags-lead">
                      <Ic d={<><path d="M10.3 3.3 1.8 18a1 1 0 0 0 .87 1.5h18.66a1 1 0 0 0 .87-1.5L13.7 3.3a1 1 0 0 0-1.74 0Z" /><path d="M12 9v4M12 17h0" /></>} w={14} sw={1.8} />
                      {fixed.length >= FLAGS.length ? "All checked — thanks" : `${FLAGS.length - fixed.length} word${FLAGS.length - fixed.length === 1 ? "" : "s"} Mira wasn't sure of`}
                    </span>
                    {FLAGS.map((w, i) => (
                      <button key={i} className={"md-flag" + (fixed.includes(i) ? " done" : "")} onClick={() => jumpToWord(w, i)}>{w}</button>
                    ))}
                  </div>
                  <textarea ref={bodyRef} className="md-body-input" value={dBody} onChange={(e) => setDBody(e.target.value)} rows={7} placeholder="Transcript…" />
                  <p className="md-vedit-hint">Tap a flagged word to jump to it, or edit the transcript directly.</p>
                </>
              : <textarea ref={bodyRef} className="md-body-input" value={dBody} onChange={(e) => setDBody(e.target.value)} rows={5} placeholder="Write your note…" />)
          : (isVoice
            ? <div className="md-transcript">
                <span className="md-tr-label">
                  <span className="md-orb md-orb-sm"><span className="md-orb-ring" /></span>
                  Transcribed by Mira
                </span>
                <p className="md-tr-text">{body}</p>
              </div>
            : <div className="md-body">{body}</div>)}

        {/* Mira's understanding */}
        <div className="md-insight">
          <div className="md-insight-top">
            <span className="md-orb"><span className="md-orb-ring" /></span>
            <span className="md-insight-label">Mira noticed</span>
          </div>
          <p className="md-insight-text">
            {isVoice
              ? "You were thinking out loud about the launch. I pulled out three actions — brief design, gather testimonials, check timing with Priya — and linked them to your Q3 plan."
              : "This looks time-sensitive. I linked it to your meeting with John and the signed contract photo, and set a gentle reminder so it doesn't slip."}
          </p>
          <button className={"md-reminder" + (reminded ? " on" : "")} onClick={() => setReminded(!reminded)}>
            <span className="md-rem-ic">
              <Ic d={<><circle cx="12" cy="13" r="8" /><path d="M12 9v4l2.5 2.5M12 2h0M5 4 3 6M19 4l2 2" /></>} w={17} sw={1.8} />
            </span>
            <span className="md-rem-tx">
              <span className="md-rem-t">{isVoice ? "3 actions · added to your list" : "Reminder · Thursday morning"}</span>
              <span className="md-rem-s">{reminded ? (isVoice ? "On — tracked in your Brief" : "On — Mira will bring this up") : "Off — tap to remind me"}</span>
            </span>
            <span className={"md-switch" + (reminded ? " on" : "")}><span className="md-knob" /></span>
          </button>
        </div>

        {/* connections */}
        <div className="md-section">
          <div className="md-sec-head">
            <span className="md-sec-title">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9"><circle cx="6" cy="12" r="2.5" /><circle cx="18" cy="6" r="2.5" /><circle cx="18" cy="18" r="2.5" /><path d="M8.2 10.8 15.8 7" /><path d="M8.2 13.2 15.8 17" /></svg>
              Connected memories
            </span>
            <button className="md-sec-see" onClick={() => go("canvas")}>See in Canvas</button>
          </div>
          <div className="md-links">
            {LINKS.map((l, i) => (
              <button className="md-link" key={i} onClick={() => go("chat")}>
                <span className={"md-link-ic md-ic-" + l.type}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{typePath[l.type]}</svg>
                </span>
                <span className="md-link-tx">
                  <span className="md-link-t">{l.title}</span>
                  <span className="md-link-s">{l.sub}</span>
                </span>
                <span className="md-link-rel">{l.rel}</span>
              </button>
            ))}
          </div>
        </div>

        {/* people + tags */}
        <div className="md-section">
          <div className="md-sec-head"><span className="md-sec-title">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round"><circle cx="12" cy="8" r="4" /><path d="M4 21a8 8 0 0 1 16 0" /></svg>
            People &amp; tags
          </span></div>
          <div className="md-tags">
            {isVoice ? (
              <>
                <span className="md-person"><span className="md-avatar">P</span>Priya Shah</span>
                <span className="md-tag">#q3</span>
                <span className="md-tag">#launch</span>
                <span className="md-tag">#idea</span>
              </>
            ) : (
              <>
                <span className="md-person"><span className="md-avatar">J</span>John Avery</span>
                <span className="md-tag">#contract</span>
                <span className="md-tag">#partnership</span>
                <span className="md-tag">#q3</span>
              </>
            )}
          </div>
        </div>

        {/* source */}
        <div className="md-source">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{isVoice ? typePath.voice : <path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />}</svg>
          {isVoice ? "Recorded on Home · iPhone · not shared" : "Typed on Home · iPhone · not shared"}
        </div>
      </div>

      {/* saved toast */}
      {saved && (
        <div className="md-toast">
          <span className="md-toast-orb" />
          {isVoice ? "Saved — Mira re-read your transcript" : "Saved — Mira re-read this note"}
        </div>
      )}

      {/* action bar */}
      {editing ? (
        <div className="md-actions">
          <button className="md-act-ghost" onClick={cancelEdit}>Cancel</button>
          <button className="md-act-primary" onClick={saveEdit}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5" /></svg>
            Save changes
          </button>
        </div>
      ) : (
        <div className="md-actions">
          <button className="md-act-primary" onClick={() => go("chat")}>
            <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M21 11.5a8.4 8.4 0 0 1-8.5 8.5 8.6 8.6 0 0 1-3.9-.9L3 21l1.9-5.6A8.4 8.4 0 0 1 4 11.5 8.5 8.5 0 0 1 12.5 3 8.4 8.4 0 0 1 21 11.5Z" /></svg>
            Ask Mira about this
          </button>
          <button className="md-act-ic" aria-label="Edit note" onClick={startEdit}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" /></svg>
          </button>
          <button className="md-act-ic" aria-label="Share">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M12 15V3M8 7l4-4 4 4" /><path d="M5 12v7a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-7" /></svg>
          </button>
        </div>
      )}

      {/* delete confirm sheet */}
      {confirm && (
        <div className="md-overlay">
          <div className="md-scrim" onClick={() => setConfirm(false)} />
          <div className="md-sheet" role="dialog" aria-label="Delete memory">
            <span className="md-sheet-grab" />
            <div className="md-sheet-ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2M19 6l-1 14a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1L5 6" /><path d="M10 11v6M14 11v6" /></svg>
            </div>
            <h2 className="md-sheet-title">Delete this memory?</h2>
            <p className="md-sheet-text">
              "{title}" and its <b>3 connections</b> will be removed from your Library.
              This can't be undone.
            </p>
            <button className="md-sheet-danger" onClick={doDelete}>Delete memory</button>
            <button className="md-sheet-cancel" onClick={() => setConfirm(false)}>Keep it</button>
          </div>
        </div>
      )}
    </div>
  );
}

Object.assign(window, { MemoryScreen });
