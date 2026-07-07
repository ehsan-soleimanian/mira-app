// Mira — interactive prototype. Onboarding → Home → Listening → Chat → Daily Brief.

const { useState, useEffect, useRef } = React;

const fmt = (s) => `${String(Math.floor(s / 60)).padStart(2, "0")}:${String(s % 60).padStart(2, "0")}`;

// ── Home (redesign — calm "second memory" + recent memories) ────────
function HomeScreen({ go }) {
  const PencilIcon = (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#B7B8BE" strokeWidth="1.7" strokeLinecap="round"><path d="M12 20h9" /><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" /></svg>
  );
  const MicIcon = ({ stroke = "#fff", sw = 1.8 }) => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth={sw} strokeLinecap="round"><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></svg>
  );
  const NoteMeta = (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M12 20h9" /><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" /></svg>
  );
  const VoiceMeta = (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /></svg>
  );

  return (
    <div className="mira-screen-body rd-home">
      {/* header */}
      <div className="rd-header">
        <div>
          <div className="rd-eyebrow">Good evening</div>
          <div className="rd-name">Sara</div>
        </div>
        <button className="rd-gear" aria-label="Settings" onClick={() => go("account")}>
          <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#6B6C73" strokeWidth="1.7"><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" /></svg>
        </button>
      </div>

      {/* hero */}
      <div className="rd-hero">
        <div className="rd-orb"><span className="rd-orb-ring" /></div>
        <h1 className="rd-title">Your memory is<br />quiet and ready</h1>
      </div>

      {/* capture */}
      <div className="rd-capture">
        <button className="rd-field" onClick={() => go("capture")}>
          {PencilIcon}
          <span className="rd-ph">Type or say anything…</span>
          <span className="rd-mic"><MicIcon /></span>
        </button>
      </div>

      {/* recent memories */}
      <div className="rd-recents">
        <div className="rd-recents-head">
          <div className="rd-label"><span className="rd-dot" />Recently captured</div>
          <button className="rd-see" onClick={() => go("daily")}>See all</button>
        </div>
        <div className="rd-list">
          <button className="rd-item" onClick={() => { localStorage.setItem("mira-mem-kind", "note"); go("memory"); }}>
            <span className="rd-node" />
            <span className="rd-body">
              <span className="rd-rtitle">Contract with John — needs a call to confirm terms</span>
              <span className="rd-meta">
                {NoteMeta} Note <span className="rd-sep" /> 2h ago <span className="rd-sep" />
                <span className="rd-linkc"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="6" cy="12" r="2.5" /><circle cx="18" cy="6" r="2.5" /><circle cx="18" cy="18" r="2.5" /><path d="M8.2 10.8 15.8 7" /><path d="M8.2 13.2 15.8 17" /></svg>3 links</span>
              </span>
            </span>
          </button>
          <button className="rd-item" onClick={() => { localStorage.setItem("mira-mem-kind", "voice"); go("memory"); }}>
            <span className="rd-node" />
            <span className="rd-body">
              <span className="rd-rtitle">Book Maya recommended — “The Overstory”</span>
              <span className="rd-meta">{VoiceMeta} Voice <span className="rd-sep" /> Yesterday</span>
            </span>
          </button>
          <button className="rd-item" onClick={() => { localStorage.setItem("mira-mem-kind", "note"); go("memory"); }}>
            <span className="rd-node" />
            <span className="rd-body">
              <span className="rd-rtitle">Idea — a quiet weekend on the coast in spring</span>
              <span className="rd-meta">{NoteMeta} Note <span className="rd-sep" /> 2 days ago</span>
            </span>
          </button>
        </div>
      </div>

      <div className="rd-spacer" />

      {/* bottom nav */}
      <div className="rd-nav">
        <button className="rd-navitem is-active">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M3 10.5 12 3l9 7.5" /><path d="M5 9.5V21h14V9.5" /></svg>
          Home
        </button>
        <button className="rd-navitem" onClick={() => go("library")}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M4 5h11" /><path d="M4 10h11" /><path d="M4 15h7" /><circle cx="18.5" cy="16.5" r="3" /><path d="M20.8 18.8 23 21" /></svg>
          Library
        </button>
        <div className="rd-navspacer" />
        <button className="rd-navitem" onClick={() => go("canvas")}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="5" r="2.4" /><circle cx="5.5" cy="18" r="2.4" /><circle cx="18.5" cy="18" r="2.4" /><path d="M11 7 6.6 15.8" /><path d="M13 7l4.4 8.8" /><path d="M7.9 18h8.2" /></svg>
          Canvas
        </button>
        <button className="rd-navitem" onClick={() => go("daily")}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9" /><path d="m8.5 12 2.5 2.5 4.5-5" /></svg>
          Brief
        </button>
        <button className="rd-navmic" aria-label="Capture by voice" onClick={() => go("capture")}>
          <MicIcon sw={1.9} />
        </button>
      </div>
    </div>
  );
}

// ── Listening ───────────────────────────────────────────────────────
function ListenScreen({ go, goBack }) {
  const [sec, setSec] = useState(0);
  useEffect(() => {
    setSec(0);
    const id = setInterval(() => setSec((s) => s + 1), 1000);
    return () => clearInterval(id);
  }, []);

  return (
    <div className="mira-screen-body">
      <Header onBack={goBack} onMemory={() => go("daily")} />

      <Orb listening style={{ position: "absolute", left: 124.5, top: 92 }} />

      <h1 className="t-title" style={{ position: "absolute", left: 91, top: 252, width: 212, textAlign: "center", color: "#1A1C29" }}>
        Im listening...
      </h1>
      <p className="t-listen-sub" style={{ position: "absolute", left: 77.5, top: 311, width: 239 }}>
        Speak naturally Mira is taking notes
      </p>

      <button className="mira-stop" style={{ position: "absolute", left: 161, top: 640 }} onClick={() => go("chat")} aria-label="Stop recording">
        <span className="mira-stop-sq" />
      </button>
      <div className="t-timer" style={{ position: "absolute", left: 161, top: 720, width: 72, textAlign: "center" }}>
        {fmt(sec)}
      </div>
      <div className="t-tapstop" style={{ position: "absolute", left: 141, top: 764, width: 112, textAlign: "center" }}>
        Tap to stop
      </div>
    </div>
  );
}

// ── Capture entry sheet (overlays the current screen) ───────────────
function CaptureSheet({ onPick, onClose }) {
  const Mode = ({ mode, icClass, icon, name, hint, wide }) => (
    <button className={"mode" + (wide ? " mode--wide" : "")} onClick={() => onPick(mode)}>
      {icon && <span className={"mode-ic" + (icClass ? " " + icClass : "")}>{icon}</span>}
      <span className="mode-tx"><span className="mode-nm">{name}</span>{hint && <span className="mode-hint">{hint}</span>}</span>
    </button>
  );
  return (
    <div className="sheet-scrim is-active" onClick={onClose}>
      <div className="sheet" onClick={(e) => e.stopPropagation()}>
        <div className="grabber" />
        <h3 className="sheet-title">Capture a memory</h3>
        <p className="sheet-sub">Mira will understand it — you confirm before it's kept</p>
        <div className="mode-grid">
          <Mode mode="voice" icClass="ic-voice" name="Voice" hint="Just speak"
            icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#14328C" strokeWidth="1.8" strokeLinecap="round"><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></svg>} />
          <Mode mode="photo" name="Photo" hint="Snap a scene"
            icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#5b69ad" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="5" width="18" height="14" rx="2.5" /><circle cx="12" cy="12" r="3.2" /></svg>} />
          <Mode mode="screenshot" name="Screenshot" hint="From your library"
            icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#5b69ad" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="4" y="3" width="16" height="14" rx="2" /><path d="M8 21h8" /></svg>} />
          <Mode mode="link" name="Link" hint="Paste a URL"
            icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#5b69ad" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1" /><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1" /></svg>} />
          <Mode mode="type" name="Type it instead" wide />
        </div>
      </div>
    </div>
  );
}

// ── App shell with screen transitions ───────────────────────────────
window.HomeScreen = HomeScreen;

const SCREENS = {
  splash: SplashScreen, login: LoginScreen, invite: InviteScreen, email: EmailCodeScreen,
  details: DetailsScreen, remember: RememberScreen, understood: UnderstoodScreen,
  home: HomeScreen, listen: ListenScreen, chat: (typeof ChatScreen !== "undefined" ? ChatScreen : HomeScreen), daily: DailyBriefScreen,
  canvas: (typeof CanvasScreen !== "undefined" ? CanvasScreen : HomeScreen),
  library: (typeof LibraryScreen !== "undefined" ? LibraryScreen : HomeScreen),
  account: (typeof AccountScreen !== "undefined" ? AccountScreen : HomeScreen),
  notifications: (typeof NotificationsScreen !== "undefined" ? NotificationsScreen : HomeScreen),
  connectedapps: (typeof ConnectedAppsScreen !== "undefined" ? ConnectedAppsScreen : HomeScreen),
  wizard: (typeof SetupWizard !== "undefined" ? SetupWizard : HomeScreen),
  captureflow: (typeof CaptureScreen !== "undefined" ? CaptureScreen : HomeScreen),
  memory: (typeof MemoryScreen !== "undefined" ? MemoryScreen : HomeScreen),
};

// Screens that make up first-run onboarding — completing them flips the
// "mira-onboarded" flag so returning users skip straight to Home.
// Pushed screens live outside the tab bar — they're dismissed, not switched.
// These are the ones a left-edge swipe-back applies to. Tab-rooted screens
// (home/library/canvas/daily) switch via the tab bar instead.
const PUSHED_SCREENS = new Set([
  "memory", "chat", "account", "notifications", "connectedapps",
]);

const ONBOARDING_SCREENS = new Set([
  "splash", "login", "invite", "email", "details", "remember", "understood", "wizard",
]);

// Transient screens are never valid back targets — you don't "return" to a
// recording view or the capture flow. Leaving one of these does not record it,
// so a pushed screen (chat, memory) opened from here backs out to whatever
// stable surface preceded it (usually Home).
const TRANSIENT_SCREENS = new Set([
  "splash", "login", "invite", "email", "details", "remember", "understood",
  "wizard", "listen", "capture", "captureflow",
]);

// Left-edge swipe-to-go-back. The gesture must START within ~26px of the left
// edge (so it never fights vertical scrolling or in-screen horizontal UI), then
// track the finger. Past ~34% of the width — or a quick flick — it commits and
// calls onBack; otherwise the page eases back into place. A soft dimmed edge
// hint fades in under the finger so the motion reads as "peeling back."
function SwipeBack({ enabled, onBack, children }) {
  const { useState, useRef } = React;
  const [dx, setDx] = useState(0);
  const [dragging, setDragging] = useState(false);
  const start = useRef(null);

  const onStart = (e) => {
    if (!enabled) return;
    const t = e.touches ? e.touches[0] : e;
    const rect = e.currentTarget.getBoundingClientRect();
    const localX = t.clientX - rect.left;
    if (localX > 26) return;                    // must begin at the edge
    start.current = { x: t.clientX, y: t.clientY, t: Date.now(), _w: rect.width || 393 };
    setDragging(true);
  };
  const onMove = (e) => {
    if (!start.current) return;
    const t = e.touches ? e.touches[0] : e;
    const mx = t.clientX - start.current.x;
    const my = Math.abs(t.clientY - start.current.y);
    if (my > Math.abs(mx) + 12) { reset(); return; } // it's a vertical scroll
    setDx(Math.max(0, mx));
  };
  const onEnd = () => {
    if (!start.current) return;
    const w = start.current._w || 380;
    const dt = Date.now() - start.current.t;
    const flick = dx > 60 && dt < 260;
    if (dx > w * 0.34 || flick) { reset(); onBack(); return; }
    reset();
  };
  const reset = () => { start.current = null; setDx(0); setDragging(false); };

  const style = dragging
    ? { transform: `translateX(${dx}px)`, transition: dx === 0 ? "transform .26s cubic-bezier(.22,.61,.36,1)" : "none" }
    : { transform: "translateX(0)", transition: "transform .26s cubic-bezier(.22,.61,.36,1)" };
  const hint = Math.min(1, dx / 140);

  return (
    <div
      className="mira-swipeback"
      onPointerDown={onStart} onPointerMove={onMove} onPointerUp={onEnd} onPointerCancel={reset}
      onTouchStart={onStart} onTouchMove={onMove} onTouchEnd={onEnd}
    >
      {enabled && dragging && dx > 4 && (
        <div className="mira-swipeback-hint" style={{ opacity: hint }}>
          <Icons.ArrowLeft size={20} />
        </div>
      )}
      <div className="mira-swipeback-page" style={style}>{children}</div>
    </div>
  );
}

function App() {
  const init = () => {
    const s = localStorage.getItem("mira-screen");
    const onboarded = localStorage.getItem("mira-onboarded") === "1";
    // Fresh / cleared load: skip onboarding if it was already completed.
    if (!s) return onboarded ? "home" : "splash";
    // Honor an explicitly stored screen (lets onboarding be re-viewed on demand).
    return (s === "capture" || s === "captureflow") ? "home" : s;
  };
  const [screen, setScreen] = useState(init);
  const [entering, setEntering] = useState(false);
  const [sheetOpen, setSheetOpen] = useState(false);

  const historyRef = useRef([]);

  const go = (next) => {
    if (next === "capture") { setSheetOpen(true); return; }
    if (next === screen) return;
    setSheetOpen(false);
    // Leaving onboarding for any app screen marks it complete for good.
    if (!ONBOARDING_SCREENS.has(next)) localStorage.setItem("mira-onboarded", "1");
    // Record the screen we're leaving as a one-level back target, unless it's
    // transient (recording, capture, onboarding) — those aren't returnable.
    if (!TRANSIENT_SCREENS.has(screen)) {
      const h = historyRef.current;
      if (h[h.length - 1] !== screen) h.push(screen);
      if (h.length > 24) h.shift();
    }
    setScreen(next);
    localStorage.setItem("mira-screen", next);
    setEntering(true);
  };

  // Return to the screen that opened the current one. Falls back to Home when
  // there's no recorded origin (e.g. after a fresh reload).
  const goBack = () => {
    const h = historyRef.current;
    let prev = h.pop();
    while (prev === screen && h.length) prev = h.pop();
    setSheetOpen(false);
    setScreen(prev || "home");
    localStorage.setItem("mira-screen", prev || "home");
    setEntering(true);
  };

  const pickMode = (mode) => {
    window.__miraCap = mode;
    setSheetOpen(false);
    setScreen("captureflow");
    localStorage.setItem("mira-screen", "captureflow");
    setEntering(true);
  };

  useEffect(() => {
    const id = setTimeout(() => setEntering(false), 30);
    return () => clearTimeout(id);
  }, [screen]);

  const Active = SCREENS[screen] || SplashScreen;

  // Human-readable name for wherever the back chevron will return — the top of
  // the history stack (falls back to Home). Lets pushed screens label their
  // back affordance so “where does back go” is never a guess.
  const BACK_LABELS = {
    home: "Home", library: "Library", canvas: "Canvas", daily: "Brief",
    account: "Settings", notifications: "Settings", connectedapps: "Settings",
    memory: "Memory", chat: "Chat",
  };
  const backTarget = historyRef.current[historyRef.current.length - 1];
  const backLabel = BACK_LABELS[backTarget] || "Home";

  return (
    <Bezel>
      <div key={screen} className={"mira-page" + (entering ? " is-entering" : "")}>
        <SwipeBack enabled={PUSHED_SCREENS.has(screen)} onBack={goBack}>
          <Active go={go} goBack={goBack} backLabel={backLabel} />
        </SwipeBack>
      </div>
      {sheetOpen && (
        <div className="rd-captureflow rd-captureflow--overlay">
          <CaptureSheet onPick={pickMode} onClose={() => setSheetOpen(false)} />
        </div>
      )}
    </Bezel>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(<App />);

// ── device scaling ──────────────────────────────────────────────────
function fit() {
  const stage = document.getElementById("stage");
  if (!stage) return;
  const bezel = stage.querySelector(".mira-bezel");
  if (!bezel) return;
  const pad = 40;
  const bw = bezel.offsetWidth, bh = bezel.offsetHeight;
  const scale = Math.min((window.innerWidth - pad) / bw, (window.innerHeight - pad) / bh, 1.15);
  stage.style.transform = `scale(${scale})`;
}
window.addEventListener("resize", fit);
setTimeout(fit, 60);
setTimeout(fit, 400);
