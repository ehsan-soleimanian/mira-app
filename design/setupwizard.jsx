// Mira — post-registration setup wizard. Teaches Mira the shape of you before Home.
// Steps: Welcome → Address → Focus → People → Rhythm → Privacy → Sources → Import → Permissions → Weaving → Ready → Tour.

function SetupWizard({ go }) {
  const { useState, useEffect, useRef } = React;

  // ── collected model of the user ──
  const [name, setName] = useState("");
  const [tone, setTone] = useState("calm");
  const [focus, setFocus] = useState([]);          // focus-area ids
  const [people, setPeople] = useState([]);         // names
  const [peopleDraft, setPeopleDraft] = useState("");
  const [briefTime, setBriefTime] = useState("morning");
  const [quiet, setQuiet] = useState(true);
  const [sources, setSources] = useState([]);       // connected source ids
  const [imports, setImports] = useState([]);       // imported app ids
  const [privacy, setPrivacy] = useState({ sync: true, improve: false });
  const [copied, setCopied] = useState(false);
  const [perm, setPerm] = useState({ mic: true, notif: true });

  const STEPS = ["welcome", "address", "focus", "people", "rhythm", "privacy", "sources", "import", "permissions", "weaving", "ready", "tour", "invite"];
  const [i, setI] = useState(0);
  const step = STEPS[i];
  const next = () => setI((n) => Math.min(n + 1, STEPS.length - 1));
  const back = () => (i === 0 ? go("details") : setI((n) => n - 1));
  const finish = () => go("home");

  // progress covers the real input steps (address..permissions)
  const inputSteps = ["address", "focus", "people", "rhythm", "privacy", "sources", "import", "permissions"];
  const progIdx = inputSteps.indexOf(step);

  const toggle = (set, id) =>
    set((list) => list.includes(id) ? list.filter((x) => x !== id) : [...list, id]);

  // auto-advance weaving
  useEffect(() => {
    if (step !== "weaving") return;
    const t = setTimeout(next, 2600);
    return () => clearTimeout(t);
  }, [step]);

  // ── Home tour (coach-marks over the real Home) ──
  const TOUR = [
    { sel: ".rd-field", radius: 18, place: "below", title: "One place to capture", body: "Type, speak, or snap a photo — everything you save starts right here." },
    { sel: ".rd-recents .rd-item", radius: 14, place: "below", title: "Everything lands here", body: "Each capture joins your timeline, already linked to what it relates to." },
    { sel: ".rd-navmic", radius: 50, place: "above", title: "Capture from anywhere", body: "Tap the mic any time — even mid-conversation — to save a thought in a breath." },
    { sel: ".rd-nav", radius: 20, place: "above", title: "Move around calmly", body: "Home, Library, Canvas and your Daily Brief all live down here." },
  ];
  const [tourI, setTourI] = useState(0);
  const tourRef = useRef(null);
  const [spot, setSpot] = useState(null);
  useEffect(() => {
    if (step !== "tour") return;
    const measure = () => {
      const cont = tourRef.current;
      if (!cont) return;
      const stop = TOUR[tourI];
      const el = cont.querySelector(stop.sel);
      if (!el) return;
      const c = cont.getBoundingClientRect();
      const r = el.getBoundingClientRect();
      const pad = 8;
      const h = r.height + pad * 2;
      setSpot({
        top: r.top - c.top - pad, left: r.left - c.left - pad,
        w: r.width + pad * 2, h,
        radius: stop.radius === 50 ? h / 2 : stop.radius,
        place: stop.place, contH: c.height,
      });
    };
    const t = setTimeout(measure, 70);
    window.addEventListener("resize", measure);
    return () => { clearTimeout(t); window.removeEventListener("resize", measure); };
  }, [step, tourI]);

  const FOCI = [
    { id: "work", label: "Work & projects", ic: "M4 7h16v13H4zM8 7V4h8v3" },
    { id: "ideas", label: "Ideas & sparks", ic: "M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10c1 1 1 2 1 3h6c0-1 0-2 1-3a6 6 0 0 0-4-10Z" },
    { id: "people", label: "People", ic: "M16 20v-2a4 4 0 0 0-8 0v2M12 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z" },
    { id: "reading", label: "Reading & links", ic: "M4 5a2 2 0 0 1 2-2h13v17H6a2 2 0 0 1-2-2zM19 3v17" },
    { id: "health", label: "Health", ic: "M20.8 6.6a5 5 0 0 0-8.8-2 5 5 0 0 0-8.8 3.2C3.2 12 12 20 12 20s8.8-8 8.8-13.4Z" },
    { id: "money", label: "Money", ic: "M12 2v20M17 6H10a3 3 0 0 0 0 6h4a3 3 0 0 1 0 6H6" },
    { id: "travel", label: "Travel & places", ic: "M12 21c-4-5-7-8-7-11a7 7 0 0 1 14 0c0 3-3 6-7 11ZM12 12a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5Z" },
    { id: "learning", label: "Learning", ic: "M22 10 12 5 2 10l10 5 10-5ZM6 12v5c0 1 3 3 6 3s6-2 6-3v-5" },
  ];

  const TONES = [
    { id: "calm", label: "Calm", sub: "Gentle, unhurried" },
    { id: "concise", label: "Concise", sub: "Short and clear" },
    { id: "warm", label: "Warm", sub: "Friendly, personal" },
  ];

  const IMPORT_APPS = [
    { id: "apple", label: "Apple Notes", count: 430, bg: "#F2C94C22", d: "M5 3h14a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1ZM8 8h8M8 12h8M8 16h5" },
    { id: "notion", label: "Notion", count: 210, bg: "#8A8A8A22", d: "M5 4h9l5 5v11a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1ZM14 4v5h5" },
    { id: "evernote", label: "Evernote", count: 1240, bg: "#4BAF5022", d: "M12 3a4 4 0 0 0-4 4v2H6a3 3 0 0 0 0 6h1v2a4 4 0 0 0 8 0v-2h1a3 3 0 0 0 0-6h-2V7a4 4 0 0 0-4-4Z" },
    { id: "bear", label: "Bear", count: 180, bg: "#E8686822", d: "M6 6a3 3 0 1 0-1 3M18 6a3 3 0 1 1 1 3M12 21a6 6 0 0 0 6-6c0-3-2.7-6-6-6s-6 3-6 6a6 6 0 0 0 6 6ZM10 15h4" },
    { id: "keep", label: "Google Keep", count: 95, bg: "#F0B54522", d: "M9 3h6l4 6-7 12L5 9l4-6ZM9 3l3 6 3-6M5 9h14" },
    { id: "obsidian", label: "Obsidian", count: 340, bg: "#7C6BEA22", d: "M12 2l7 6-4 14H9L5 8l7-6ZM9 22l3-9 3 9M5 8l7 5 7-5" },
  ];
  const fmtK = (n) => (n >= 1000 ? (n / 1000).toFixed(1).replace(/\.0$/, "") + "k" : String(n));
  const importTotal = imports.reduce((s, id) => s + (IMPORT_APPS.find((a) => a.id === id)?.count || 0), 0);

  const SOURCES = [
    { id: "calendar", label: "Calendar", sub: "Meetings feed your Brief", bg: "#E9484818", d: "M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2ZM2 9h20M8 3v3M16 3v3" },
    { id: "notes", label: "Notes", sub: "Your written thoughts", bg: "#F0B54518", d: "M5 3h14a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1ZM8 8h8M8 12h8M8 16h5" },
    { id: "photos", label: "Photos", sub: "Screenshots & scans", bg: "#5B8DEF18", d: "M3 5h18v14H3zM3 15l5-4 4 3 3-2 6 5" },
    { id: "gmail", label: "Gmail", sub: "Important mail", bg: "#EA433518", d: "M3 5h18v14H3zM3 7l9 6 9-6" },
  ];

  // ── shared chrome ──
  const Chrome = ({ children, cta, ctaLabel = "Continue", skip }) => (
    <div className="mira-screen-body ob wz">
      <div className="wz-top">
        <button className="wz-back" onClick={back} aria-label="Back">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 6-6 6 6 6" /></svg>
        </button>
        {progIdx >= 0 && (
          <div className="wz-prog">
            {inputSteps.map((_, k) => <span key={k} className={"wz-seg" + (k <= progIdx ? " on" : "")} />)}
          </div>
        )}
        {skip ? <button className="wz-skip" onClick={next}>Skip</button> : <span className="wz-skip-ph" />}
      </div>
      <div className="wz-scroll">{children}</div>
      <div className="wz-cta">
        <button className="ob-btn ob-btn--navy" onClick={cta || next}>{ctaLabel}</button>
      </div>
    </div>
  );

  const Orb = ({ size = 96 }) => (
    <div className="wz-orb" style={{ width: size, height: size }}>
      <span className="wz-orb-ring" /><span className="wz-orb-core" />
    </div>
  );

  // ── steps ──
  if (step === "welcome") {
    return (
      <div className="mira-screen-body ob wz">
        <div className="wz-hero">
          <Orb size={112} />
          <h1 className="t-ob-title wz-h1" style={{ marginTop: 30 }}>Let's set up<br />your second mind.</h1>
          <p className="t-ob-desc wz-sub">A few quick questions so Mira remembers the way you do. About two minutes — and you can change any of it later.</p>
        </div>
        <div className="ob-cta ob-cta--stack">
          <button className="ob-btn ob-btn--navy" onClick={next}>Begin setup</button>
          <button className="ob-btn ob-btn--ghost" onClick={finish}>Skip for now</button>
        </div>
      </div>
    );
  }

  if (step === "address") {
    return (
      <Chrome cta={next} ctaLabel="Continue">
        <h2 className="t-ob-title wz-h2">What should Mira<br />call you?</h2>
        <p className="t-ob-desc">This is how your Brief and reminders will greet you.</p>
        <input className="ob-input wz-input" placeholder="Your name" value={name} onChange={(e) => setName(e.target.value)} />
        <div className="wz-fieldlabel">And how should it speak?</div>
        <div className="wz-tones">
          {TONES.map((t) => (
            <button key={t.id} className={"wz-tone" + (tone === t.id ? " on" : "")} onClick={() => setTone(t.id)}>
              <span className="wz-tone-l">{t.label}</span>
              <span className="wz-tone-s">{t.sub}</span>
            </button>
          ))}
        </div>
      </Chrome>
    );
  }

  if (step === "focus") {
    return (
      <Chrome cta={next} ctaLabel={focus.length ? "Continue" : "Pick a few"} skip>
        <h2 className="t-ob-title wz-h2">What matters<br />to you?</h2>
        <p className="t-ob-desc">Mira will cluster your memories around these. Choose any that fit.</p>
        <div className="wz-chips">
          {FOCI.map((f) => {
            const on = focus.includes(f.id);
            return (
              <button key={f.id} className={"wz-chip" + (on ? " on" : "")} onClick={() => toggle(setFocus, f.id)}>
                <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d={f.ic} /></svg>
                {f.label}
              </button>
            );
          })}
        </div>
      </Chrome>
    );
  }

  if (step === "people") {
    const add = () => {
      const v = peopleDraft.trim();
      if (v && !people.includes(v)) setPeople([...people, v]);
      setPeopleDraft("");
    };
    return (
      <Chrome cta={next} ctaLabel={people.length ? "Continue" : "Continue"} skip>
        <h2 className="t-ob-title wz-h2">Who's important<br />to you?</h2>
        <p className="t-ob-desc">Mira links what you capture to the people in your life. Add a few — first names are enough.</p>
        <div className="wz-addrow">
          <input className="ob-input wz-input" style={{ marginTop: 0 }} placeholder="Add a name" value={peopleDraft}
            onChange={(e) => setPeopleDraft(e.target.value)} onKeyDown={(e) => e.key === "Enter" && add()} />
          <button className="wz-add" onClick={add} aria-label="Add">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg>
          </button>
        </div>
        <div className="wz-people">
          {people.map((p) => (
            <span key={p} className="wz-person">
              <span className="wz-avatar">{p[0].toUpperCase()}</span>{p}
              <button className="wz-person-x" onClick={() => setPeople(people.filter((x) => x !== p))} aria-label="Remove">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg>
              </button>
            </span>
          ))}
          {people.length === 0 && <span className="wz-people-empty">No one yet — Mira will still learn as you capture.</span>}
        </div>
      </Chrome>
    );
  }

  if (step === "rhythm") {
    const times = [
      { id: "morning", label: "Morning", sub: "7:00" },
      { id: "midday", label: "Midday", sub: "12:30" },
      { id: "evening", label: "Evening", sub: "18:00" },
    ];
    return (
      <Chrome cta={next} ctaLabel="Continue">
        <h2 className="t-ob-title wz-h2">When should your<br />Brief arrive?</h2>
        <p className="t-ob-desc">A calm once-a-day summary of what needs you — nothing more.</p>
        <div className="wz-times">
          {times.map((t) => (
            <button key={t.id} className={"wz-time" + (briefTime === t.id ? " on" : "")} onClick={() => setBriefTime(t.id)}>
              <span className="wz-time-l">{t.label}</span>
              <span className="wz-time-s">{t.sub}</span>
            </button>
          ))}
        </div>
        <button className={"wz-toggle-row" + (quiet ? " on" : "")} onClick={() => setQuiet(!quiet)}>
          <span className="wz-tr-tx">
            <span className="wz-tr-t">Quiet hours</span>
            <span className="wz-tr-s">No nudges 22:00 – 07:00</span>
          </span>
          <span className={"wz-switch" + (quiet ? " on" : "")}><span className="wz-knob" /></span>
        </button>
      </Chrome>
    );
  }

  if (step === "privacy") {
    const assurances = [
      { bg: "#1F8A5B18", d: "M6 10V8a6 6 0 0 1 12 0v2M5 10h14a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-8a1 1 0 0 1 1-1ZM12 14v3", t: "Processed privately", s: "Your captures are analysed on-device whenever possible." },
      { bg: "#5B8DEF18", d: "M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10ZM9 12l2 2 4-4", t: "Encrypted end-to-end", s: "Only you can read your memories — not even Mira can." },
      { bg: "#E9484818", d: "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18ZM5.6 5.6l12.8 12.8", t: "Never sold, ever", s: "We don't sell or share your data. No ads, no exceptions." },
    ];
    const toggles = [
      { k: "sync", ic: "M4 12a8 8 0 0 1 14-5l2 2M20 12a8 8 0 0 1-14 5l-2-2M18 4v5h-5M6 20v-5h5", t: "Sync across my devices", s: "Encrypted backup so your memory follows you." },
      { k: "improve", ic: "M12 3v3M12 18v3M3 12h3M18 12h3M6 6l2 2M16 16l2 2M6 18l2-2M16 8l2-2", t: "Help improve Mira", s: "Share anonymous, aggregated usage — never your content." },
    ];
    return (
      <Chrome cta={next} ctaLabel="Continue">
        <h2 className="t-ob-title wz-h2">Your memory<br />stays yours.</h2>
        <p className="t-ob-desc">Before you connect anything, here's the promise Mira is built on.</p>
        <div className="wz-sources" style={{ marginTop: 20 }}>
          {assurances.map((a) => (
            <div key={a.t} className="wz-source">
              <span className="wz-src-tile" style={{ background: a.bg }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1C29" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: .85 }}><path d={a.d} /></svg>
              </span>
              <span className="wz-src-tx">
                <span className="wz-src-t">{a.t}</span>
                <span className="wz-src-s">{a.s}</span>
              </span>
            </div>
          ))}
        </div>
        <div className="wz-fieldlabel" style={{ marginTop: 24, marginBottom: 4 }}>Your choices</div>
        {toggles.map((r) => (
          <button key={r.k} className={"wz-toggle-row" + (privacy[r.k] ? " on" : "")} onClick={() => setPrivacy((p) => ({ ...p, [r.k]: !p[r.k] }))}>
            <span className="wz-perm-ic">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d={r.ic} /></svg>
            </span>
            <span className="wz-tr-tx">
              <span className="wz-tr-t">{r.t}</span>
              <span className="wz-tr-s">{r.s}</span>
            </span>
            <span className={"wz-switch" + (privacy[r.k] ? " on" : "")}><span className="wz-knob" /></span>
          </button>
        ))}
        <button className="wz-policy" onClick={(e) => e.preventDefault()}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M14 3v4a1 1 0 0 0 1 1h4M15 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8Z" /></svg>
          Read the full privacy promise
        </button>
      </Chrome>
    );
  }

  if (step === "sources") {
    return (
      <Chrome cta={next} ctaLabel={sources.length ? "Continue" : "Continue"} skip>
        <h2 className="t-ob-title wz-h2">Connect<br />your world.</h2>
        <p className="t-ob-desc">Give Mira a head start. It only reads what you connect, and processes it privately.</p>
        <div className="wz-sources">
          {SOURCES.map((s) => {
            const on = sources.includes(s.id);
            return (
              <div key={s.id} className="wz-source">
                <span className="wz-src-tile" style={{ background: s.bg }}>
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1C29" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: .85 }}><path d={s.d} /></svg>
                </span>
                <span className="wz-src-tx">
                  <span className="wz-src-t">{s.label}</span>
                  <span className="wz-src-s">{s.sub}</span>
                </span>
                <button className={"wz-connect" + (on ? " on" : "")} onClick={() => toggle(setSources, s.id)}>
                  {on
                    ? <><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5" /></svg>Connected</>
                    : "Connect"}
                </button>
              </div>
            );
          })}
        </div>
      </Chrome>
    );
  }

  if (step === "import") {
    return (
      <Chrome cta={next} ctaLabel={imports.length ? `Import ${fmtK(importTotal)} notes` : "Continue"} skip>
        <h2 className="t-ob-title wz-h2">Bring your<br />notes with you.</h2>
        <p className="t-ob-desc">Already keep notes elsewhere? Import them once and Mira will weave them into your graph. Nothing is deleted from the original app.</p>
        <div className="wz-sources">
          {IMPORT_APPS.map((a) => {
            const on = imports.includes(a.id);
            return (
              <button key={a.id} className={"wz-source wz-imp" + (on ? " on" : "")} onClick={() => toggle(setImports, a.id)}>
                <span className="wz-src-tile" style={{ background: a.bg }}>
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1C29" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: .85 }}><path d={a.d} /></svg>
                </span>
                <span className="wz-src-tx">
                  <span className="wz-src-t">{a.label}</span>
                  <span className="wz-src-s">~{fmtK(a.count)} notes found</span>
                </span>
                <span className={"wz-imp-check" + (on ? " on" : "")}>
                  {on && <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5" /></svg>}
                </span>
              </button>
            );
          })}
        </div>
        <div className="wz-imp-note">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M12 8v5M12 16h.01M10.3 3.9 2 18a2 2 0 0 0 1.7 3h16.6a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z" /></svg>
          <span>{imports.length ? `Mira will import in the background — you can start using it right away.` : `You can also import later from Settings.`}</span>
        </div>
      </Chrome>
    );
  }

  if (step === "permissions") {
    const rows = [
      { k: "mic", t: "Microphone", s: "So you can speak a memory anytime", d: "M12 3a3 3 0 0 0-3 3v6a3 3 0 0 0 6 0V6a3 3 0 0 0-3-3ZM5 11a7 7 0 0 0 14 0M12 18v3" },
      { k: "notif", t: "Notifications", s: "Only your Brief and reminders you set", d: "M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0" },
    ];
    return (
      <Chrome cta={next} ctaLabel="Continue">
        <h2 className="t-ob-title wz-h2">Let Mira<br />help quietly.</h2>
        <p className="t-ob-desc">Two permissions, both optional. Turn off anything, anytime.</p>
        <div className="wz-perms">
          {rows.map((r) => (
            <button key={r.k} className={"wz-toggle-row" + (perm[r.k] ? " on" : "")} onClick={() => setPerm((p) => ({ ...p, [r.k]: !p[r.k] }))}>
              <span className="wz-perm-ic">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d={r.d} /></svg>
              </span>
              <span className="wz-tr-tx">
                <span className="wz-tr-t">{r.t}</span>
                <span className="wz-tr-s">{r.s}</span>
              </span>
              <span className={"wz-switch" + (perm[r.k] ? " on" : "")}><span className="wz-knob" /></span>
            </button>
          ))}
        </div>
      </Chrome>
    );
  }

  if (step === "weaving") {
    const echoes = [];
    if (focus.length) echoes.push(`${focus.length} focus ${focus.length === 1 ? "area" : "areas"}`);
    if (people.length) echoes.push(`${people.length} ${people.length === 1 ? "person" : "people"}`);
    if (sources.length) echoes.push(`${sources.length} ${sources.length === 1 ? "source" : "sources"}`);
    if (importTotal) echoes.push(`${fmtK(importTotal)} imported notes`);
    const line = echoes.length ? echoes.join(" · ") : "your preferences";
    return (
      <div className="mira-screen-body ob wz wz-weave">
        <Orb size={128} />
        <h2 className="t-ob-title wz-h1" style={{ marginTop: 30, textAlign: "center" }}>Weaving your<br />memory…</h2>
        <p className="t-ob-desc" style={{ textAlign: "center", maxWidth: 260 }}>Mira is arranging {line} into the shape of your mind.</p>
        <div className="wz-weave-dots"><span /><span /><span /></div>
      </div>
    );
  }

  // ready
  const greet = name ? name.trim().split(" ")[0] : "you";
  if (step === "ready") {
    return (
      <div className="mira-screen-body ob wz wz-ready">
        <div className="wz-hero">
          <div className="wz-check">
            <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5" /></svg>
          </div>
          <h1 className="t-ob-title wz-h1" style={{ marginTop: 26 }}>Your second<br />mind is ready.</h1>
          <p className="t-ob-desc wz-sub">Everything you capture from here, {greet}, has a place to live — and a way back to you.</p>
        </div>
        <div className="ob-cta ob-cta--stack">
          <button className="ob-btn ob-btn--navy" onClick={() => setTourI(0) || setI(STEPS.indexOf("tour"))}>Take a quick tour</button>
          <button className="ob-btn ob-btn--ghost" onClick={() => setI(STEPS.indexOf("invite"))}>Skip the tour</button>
        </div>
      </div>
    );
  }

  // referral invite (final)
  if (step === "invite") {
    const code = "MIRA-7F3K";
    const channels = [
      { t: "Messages", bg: "#1F8A5B18", d: "M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" },
      { t: "Mail", bg: "#5B8DEF18", d: "M4 4h16a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1ZM3 6l9 7 9-7" },
      { t: "Copy link", bg: "#8A6BEF18", d: "M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1" },
    ];
    const copy = () => { try { navigator.clipboard && navigator.clipboard.writeText(code); } catch (e) {} setCopied(true); setTimeout(() => setCopied(false), 1600); };
    return (
      <div className="mira-screen-body ob wz wz-invite">
        <div className="wz-inv-body">
          <div className="wz-inv-gift">
            <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M20 12v8a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-8M2 8h20v4H2zM12 8v13M12 8S9.5 4 7.5 4a2.5 2.5 0 0 0 0 5H12ZM12 8s2.5-4 4.5-4a2.5 2.5 0 0 1 0 5H12" /></svg>
          </div>
          <h1 className="t-ob-title wz-h1" style={{ marginTop: 22 }}>Give someone a<br />calmer mind.</h1>
          <p className="t-ob-desc wz-sub">Mira is better with the people you think alongside. Invite a few — they skip the waitlist, and you both get a month of Plus.</p>

          <div className="wz-inv-code">
            <span className="wz-inv-label">Your invite code</span>
            <div className="wz-inv-coderow">
              <span className="wz-inv-val">{code}</span>
              <button className={"wz-inv-copy" + (copied ? " ok" : "")} onClick={copy}>
                {copied ? (
                  <><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5" /></svg>Copied</>
                ) : (
                  <><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M9 9h10a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V10a1 1 0 0 1 1-1ZM5 15H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v1" /></svg>Copy</>
                )}
              </button>
            </div>
          </div>

          <div className="wz-inv-chans">
            {channels.map((c) => (
              <button key={c.t} className="wz-inv-chan">
                <span className="wz-inv-chic" style={{ background: c.bg }}>
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1C29" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: .85 }}><path d={c.d} /></svg>
                </span>
                <span className="wz-inv-chtx">{c.t}</span>
              </button>
            ))}
          </div>
        </div>
        <div className="ob-cta ob-cta--stack">
          <button className="ob-btn ob-btn--navy" onClick={finish}>Share your invite</button>
          <button className="ob-btn ob-btn--ghost" onClick={finish}>Maybe later</button>
        </div>
      </div>
    );
  }

  // Home tour
  {
    const stop = TOUR[tourI];
    const last = tourI === TOUR.length - 1;
    const Home = window.HomeScreen;
    const cardStyle = spot
      ? (spot.place === "below" ? { top: spot.top + spot.h + 14 } : { bottom: spot.contH - spot.top + 14 })
      : { bottom: 130 };
    return (
      <div className="mira-screen-body ob wz wz-tour" ref={tourRef}>
        <div className="wz-tour-home" aria-hidden="true">{Home && <Home go={() => {}} />}</div>
        <div className="wz-tour-catch" />
        {spot && <div className="wz-tour-ring" style={{ top: spot.top, left: spot.left, width: spot.w, height: spot.h, borderRadius: spot.radius }} />}
        <div className="wz-tour-card" style={cardStyle}>
          <div className="wz-tour-dots">{TOUR.map((_, k) => <span key={k} className={k === tourI ? "on" : ""} />)}</div>
          <div className="wz-tour-title">{stop.title}</div>
          <div className="wz-tour-body">{stop.body}</div>
          <div className="wz-tour-actions">
            {!last && <button className="wz-tour-skip" onClick={() => setI(STEPS.indexOf("invite"))}>Skip tour</button>}
            <button className="wz-tour-next" onClick={() => (last ? setI(STEPS.indexOf("invite")) : setTourI(tourI + 1))}>{last ? "Finish" : "Next"}</button>
          </div>
        </div>
      </div>
    );
  }
}

Object.assign(window, { SetupWizard });
