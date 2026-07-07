// Mira — shared UI primitives (icons, orb, device bezel, navbar)
// Faithful to the Figma file. Colors and metrics lifted directly.

// ── Iconsax-style line icons (24×24 viewBox) ────────────────────────
function Icon({ d, size = 24, stroke = "#1A1C29", sw = 1.5, fill = "none", children, vb = 24, style, opacity }) {
  return (
    <svg width={size} height={size} viewBox={`0 0 ${vb} ${vb}`} fill={fill} style={{ opacity, ...style }}
      stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
      {d ? <path d={d} /> : children}
    </svg>
  );
}

const Icons = {
  ArrowLeft: (p) => <Icon {...p} d="M9.57 5.93 3.5 12l6.07 6.07M20.5 12H3.67" />,
  ArrowUp: (p) => <Icon {...p} d="M12 19V6M6 11.5 12 5.5l6 6" />,
  ChevronDown: (p) => <Icon {...p} sw={1.6} d="M5 8.5 12 15.5 19 8.5" />,
  ChevronRight: (p) => <Icon {...p} sw={1.6} d="M9 5.5 15.5 12 9 18.5" />,
  Plus: (p) => <Icon {...p} sw={1.7} d="M12 6.2v11.6M6.2 12h11.6" />,
  Brain: (p) => (
    <Icon {...p}>
      <path d="M12 5.2a2.9 2.9 0 0 0-5.6-1.05A2.7 2.7 0 0 0 4.2 9a2.45 2.45 0 0 0 .45 4.45A2.45 2.45 0 0 0 8.1 15.7 2.45 2.45 0 0 0 12 18.4Z" />
      <path d="M12 5.2a2.9 2.9 0 0 1 5.6-1.05A2.7 2.7 0 0 1 19.8 9a2.45 2.45 0 0 1-.45 4.45 2.45 2.45 0 0 1-3.45 2.25A2.45 2.45 0 0 1 12 18.4Z" />
      <path d="M12 5.2v13.2" />
    </Icon>
  ),
  // microphone-2 linear (iconsax)
  Mic: (p) => (
    <Icon {...p}>
      <path d="M12 15.6a3.6 3.6 0 0 0 3.6-3.6V6.1a3.6 3.6 0 1 0-7.2 0V12a3.6 3.6 0 0 0 3.6 3.6Z" />
      <path d="M5.35 10.4V12a6.65 6.65 0 0 0 13.3 0v-1.6" />
      <path d="M10.1 7.6a5.6 5.6 0 0 1 3.8 0M10.55 9.95a4 4 0 0 1 2.9 0" />
    </Icon>
  ),
  // home-2 linear (pentagon house)
  Home: (p) => (
    <Icon {...p}>
      <path d="M9.07 2.82 3.14 7.45c-.99.77-1.79 2.4-1.58 3.63l1.14 6.82c.3 1.78 2 3.22 3.81 3.22h10.98c1.79 0 3.51-1.47 3.81-3.23l1.14-6.82c.19-1.23-.61-2.93-1.6-3.62l-5.93-4.61c-1.38-1.08-3.59-1.07-4.86-.02Z" />
      <path d="M12 18.1v-3" />
    </Icon>
  ),
  // coffee linear (iconsax)
  Coffee: (p) => (
    <Icon {...p}>
      <path d="M4 12.26V6.26h12v6c0 2.32-1.89 4.21-4.21 4.21H8.2A4.2 4.2 0 0 1 4 12.26Z" />
      <path d="M16 8.21h1.79a2.6 2.6 0 0 1 0 5.21H16" />
      <path d="M5.5 4.1c-.9-.9-.9-1.9 0-2.8M9 4.1c-.9-.9-.9-1.9 0-2.8M12.5 4.1c-.9-.9-.9-1.9 0-2.8" />
    </Icon>
  ),
  Setting: (p) => (
    <Icon {...p} sw={1.5}>
      <path d="M3 13.3v-2.6c0-1.53 1.25-2.79 2.79-2.79 2.65 0 3.74-1.88 2.41-4.18-.76-1.32-.31-3.03 1.02-3.79l2.55-1.46c1.15-.68 2.64-.27 3.32.88l.16.28c1.32 2.3 3.5 2.3 4.83 0l.16-.28c.68-1.15 2.17-1.56 3.32-.88M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
    </Icon>
  ),
  // simplified, reliable gear
  Gear: (p) => (
    <Icon {...p} sw={1.5}>
      <circle cx="12" cy="12" r="3" />
      <path d="M19.4 13c.04-.32.06-.66.06-1s-.02-.68-.06-1l1.7-1.3a.5.5 0 0 0 .12-.62l-1.6-2.78a.5.5 0 0 0-.6-.22l-2 .8a6.6 6.6 0 0 0-1.73-1l-.3-2.12a.5.5 0 0 0-.5-.42h-3.2a.5.5 0 0 0-.5.42l-.3 2.12a6.6 6.6 0 0 0-1.73 1l-2-.8a.5.5 0 0 0-.6.22L2.36 9.08a.5.5 0 0 0 .12.62L4.18 11c-.04.32-.06.66-.06 1s.02.68.06 1l-1.7 1.3a.5.5 0 0 0-.12.62l1.6 2.78a.5.5 0 0 0 .6.22l2-.8c.52.4 1.1.74 1.73 1l.3 2.12a.5.5 0 0 0 .5.42h3.2a.5.5 0 0 0 .5-.42l.3-2.12c.63-.26 1.21-.6 1.73-1l2 .8a.5.5 0 0 0 .6-.22l1.6-2.78a.5.5 0 0 0-.12-.62L19.4 13Z" />
    </Icon>
  ),
  Clock: (p) => (
    <Icon {...p}>
      <circle cx="12" cy="12" r="9.2" />
      <path d="M15.7 14.35 12.4 12.4V7.95" />
    </Icon>
  ),
  // note-2 linear (iconsax) — document with smile lines
  Note: (p) => (
    <Icon {...p}>
      <path d="M8 2v3M16 2v3" />
      <path d="M8.5 13.4h7M8.5 17.4h4.5" />
      <path d="M16 3.5C19.33 3.68 21 4.95 21 9.65v6.16C21 19.93 20 22 15 22H9c-5 0-6-2.07-6-6.19V9.65c0-4.7 1.67-5.98 5-6.15h8Z" />
    </Icon>
  ),
  Verify: (p) => (
    <Icon {...p}>
      <path d="M9.05 2.53c.81-.69 2.1-.69 2.92 0l.93.8c.35.3.99.54 1.45.54h1c1.25 0 2.28 1.03 2.28 2.28v1c0 .46.24 1.1.54 1.45l.8.93c.69.81.69 2.1 0 2.92l-.8.93c-.3.35-.54.99-.54 1.45v1c0 1.25-1.03 2.28-2.28 2.28h-1c-.46 0-1.1.24-1.45.54l-.93.8c-.81.69-2.1.69-2.92 0l-.93-.8c-.35-.3-.99-.54-1.45-.54h-1c-1.25 0-2.28-1.03-2.28-2.28v-1c0-.46-.24-1.1-.54-1.45l-.8-.93c-.69-.81-.69-2.1 0-2.92l.8-.93c.3-.35.54-.99.54-1.45v-1c0-1.25 1.03-2.28 2.28-2.28h1c.46 0 1.1-.24 1.45-.54Z" />
      <path d="M8.7 12.1l2.2 2.2 4.4-4.6" />
    </Icon>
  ),
  // empty rounded checkbox (square)
  Square: (p) => (
    <Icon {...p} sw={1.5}>
      <rect x="3" y="3" width="18" height="18" rx="6" />
    </Icon>
  ),
  // checked task: rounded square + tick
  CheckSquare: (p) => (
    <Icon {...p} sw={1.5}>
      <rect x="3" y="3" width="18" height="18" rx="6" />
      <path d="M8 12.2l2.6 2.6L16 9" />
    </Icon>
  ),
  Shield: (p) => (
    <Icon {...p}>
      <path d="M10.49 2.23 5.5 4.1C4.35 4.53 3.41 5.89 3.41 7.11v7.43c0 1.18.78 2.73 1.73 3.44l4.3 3.21c1.41 1.06 3.73 1.06 5.14 0l4.3-3.21c.95-.71 1.73-2.26 1.73-3.44V7.11c0-1.23-.94-2.59-2.09-3.02l-4.99-1.86c-.85-.31-2.21-.31-3.04 0Z" />
    </Icon>
  ),
  ShieldCheck: (p) => (
    <Icon {...p}>
      <path d="M10.49 2.23 5.5 4.1C4.35 4.53 3.41 5.89 3.41 7.11v7.43c0 1.18.78 2.73 1.73 3.44l4.3 3.21c1.41 1.06 3.73 1.06 5.14 0l4.3-3.21c.95-.71 1.73-2.26 1.73-3.44V7.11c0-1.23-.94-2.59-2.09-3.02l-4.99-1.86c-.85-.31-2.21-.31-3.04 0Z" />
      <path d="M9.05 11.87 11 13.82l4-4" />
    </Icon>
  ),
  User: (p) => (
    <Icon {...p}>
      <circle cx="12" cy="6.5" r="3.7" />
      <path d="M5.4 19.6c0-3.16 2.95-5.72 6.6-5.72s6.6 2.56 6.6 5.72" />
    </Icon>
  ),
  Bell: (p) => (
    <Icon {...p}>
      <path d="M12 2.2a5.6 5.6 0 0 0-5.6 5.6v2.7c0 .57-.24 1.43-.53 1.91l-1.07 1.78c-.66 1.1-.2 2.32 1 2.72a19.5 19.5 0 0 0 12.4 0c1.12-.37 1.62-1.69 1-2.72l-1.07-1.78c-.29-.48-.53-1.34-.53-1.91V7.8A5.62 5.62 0 0 0 12 2.2Z" />
      <path d="M9.5 19.5a2.6 2.6 0 0 0 5 0" />
    </Icon>
  ),
  Copy: (p) => (
    <Icon {...p}>
      <rect x="8.5" y="8.5" width="12" height="12" rx="3" />
      <path d="M6.2 15.5H5.5A2 2 0 0 1 3.5 13.5V5.5a2 2 0 0 1 2-2H13.5a2 2 0 0 1 2 2v.7" />
    </Icon>
  ),
  Link: (p) => (
    <Icon {...p}>
      <path d="M9.5 14.5 14.5 9.5" />
      <path d="M8 11 6.5 12.5a3.18 3.18 0 0 0 0 4.5v0a3.18 3.18 0 0 0 4.5 0L12.5 15.5" />
      <path d="M11.5 8.5 13 7a3.18 3.18 0 0 1 4.5 0v0a3.18 3.18 0 0 1 0 4.5L16 13" />
    </Icon>
  ),
  Invite: (p) => (
    <Icon {...p}>
      <circle cx="9" cy="6.5" r="3.3" />
      <path d="M3 19.5c0-2.9 2.69-5.25 6-5.25 1.2 0 2.32.31 3.25.84" />
      <path d="M17.5 14v5M20 16.5h-5" />
    </Icon>
  ),
  // paperclip / attach mic compound (input trailing)
  AttachMic: (p) => (
    <Icon {...p}>
      <path d="M12 14.4a2.5 2.5 0 0 0 2.5-2.5V6.5a2.5 2.5 0 1 0-5 0v5.4a2.5 2.5 0 0 0 2.5 2.5Z" />
      <path d="M7.5 10.8v1.1a4.5 4.5 0 0 0 9 0v-1.1" />
    </Icon>
  ),
  Google: (p) => (
    <svg width={p.size || 20} height={p.size || 20} viewBox="0 0 24 24" style={p.style}>
      <path fill="#4285F4" d="M22.5 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.9a5.05 5.05 0 0 1-2.19 3.31v2.77h3.55c2.08-1.92 3.24-4.74 3.24-8.09Z" />
      <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.55-2.77c-.98.66-2.24 1.06-3.73 1.06-2.87 0-5.3-1.94-6.16-4.55H2.18v2.86A11 11 0 0 0 12 23Z" />
      <path fill="#FBBC05" d="M5.84 14.08a6.6 6.6 0 0 1 0-4.16V7.06H2.18a11 11 0 0 0 0 9.88l3.66-2.86Z" />
      <path fill="#EA4335" d="M12 4.95c1.62 0 3.07.56 4.21 1.65l3.15-3.15C17.45 1.7 14.97.7 12 .7A11 11 0 0 0 2.18 7.06l3.66 2.86C6.7 7.31 9.13 4.95 12 4.95Z" />
    </svg>
  ),
  Apple: (p) => (
    <svg width={p.size || 20} height={p.size || 20} viewBox="0 0 24 24" style={p.style} fill="#1A1A1A">
      <path d="M17.05 12.7c-.03-2.6 2.12-3.85 2.22-3.91-1.21-1.77-3.1-2.01-3.77-2.04-1.6-.16-3.13.94-3.94.94-.81 0-2.07-.92-3.4-.9-1.75.03-3.36 1.02-4.26 2.58-1.82 3.15-.47 7.82 1.3 10.38.86 1.25 1.89 2.66 3.23 2.61 1.3-.05 1.79-.84 3.36-.84 1.57 0 2.01.84 3.38.81 1.4-.02 2.28-1.28 3.13-2.54.99-1.45 1.4-2.86 1.42-2.93-.03-.01-2.72-1.05-2.75-4.15M14.5 5.13c.71-.87 1.2-2.07 1.06-3.28-1.03.04-2.27.69-3.01 1.55-.66.76-1.24 1.99-1.09 3.16 1.15.09 2.32-.58 3.04-1.43" />
    </svg>
  ),
};

// ── The signature orb (rendered PNG from the Figma) ─────────────────
function Orb({ size = 145, listening = false, style }) {
  const s = size / 145; // the png crop is authored for a 145 window
  return (
    <div className={"mira-orb" + (listening ? " is-listening" : "")} style={{ width: size, height: size, ...style }}>
      <div className="mira-orb-clip" style={{ width: size, height: size, borderRadius: size }}>
        <div className="mira-orb-img" style={{
          backgroundImage: "url(assets/orb.png)",
          backgroundRepeat: "no-repeat",
          backgroundSize: `${222 * s}px ${222 * s}px`,
          backgroundPosition: `${-38.5 * s}px ${-39 * s}px`,
        }} />
        <div className="mira-orb-blob mira-orb-blob--a" />
        <div className="mira-orb-blob mira-orb-blob--b" />
        <div className="mira-orb-blob mira-orb-blob--c" />
      </div>
    </div>
  );
}

// ── Bottom navigation — uses the exact navbar PNG from the design ───
// The image already contains the bar, icons, labels and the centre mic.
// We overlay three transparent hotspots for navigation.
function TabBar({ onHome, onMic, onDaily }) {
  return (
    <div className="mira-tabwrap">
      <img className="mira-navimg" src="assets/navbar.png" alt="" aria-hidden="true" draggable="false" />
      <button className="mira-nav-hit mira-nav-hit--home" onClick={onHome} aria-label="Home" />
      <button className="mira-nav-hit mira-nav-hit--mic" onClick={onMic} aria-label="Talk to Mira" />
      <button className="mira-nav-hit mira-nav-hit--daily" onClick={onDaily} aria-label="Daily Brief" />
    </div>
  );
}

// ── Badge (Task / Note / Image) ─────────────────────────────────────
function Badge({ children }) {
  return <span className="mira-badge">{children}</span>;
}

// ── iOS status bar (compact, sits in the top safe area) ─────────────
function StatusBar({ dark = false }) {
  const c = dark ? "#fff" : "#1a1a1a";
  return (
    <div className="mira-statusbar">
      <span className="mira-clock" style={{ color: c }}>9:41</span>
      <div className="mira-status-icons">
        <svg width="18" height="11" viewBox="0 0 18 11" fill={c}>
          <rect x="0" y="7" width="3" height="4" rx="0.7" />
          <rect x="4.5" y="4.6" width="3" height="6.4" rx="0.7" />
          <rect x="9" y="2.3" width="3" height="8.7" rx="0.7" />
          <rect x="13.5" y="0" width="3" height="11" rx="0.7" />
        </svg>
        <svg width="16" height="11" viewBox="0 0 16 11" fill={c}>
          <path d="M8 2.9c2.1 0 4 .8 5.4 2.2l1-1A9 9 0 0 0 8 1.3 9 9 0 0 0 1.6 4.1l1 1A7.5 7.5 0 0 1 8 2.9Z" />
          <path d="M8 6.3c1.2 0 2.3.5 3.1 1.3l1-1A6 6 0 0 0 8 4.7a6 6 0 0 0-4.1 1.9l1 1A4.4 4.4 0 0 1 8 6.3Z" />
          <circle cx="8" cy="9.6" r="1.3" />
        </svg>
        <svg width="25" height="12" viewBox="0 0 25 12">
          <rect x="0.5" y="0.5" width="21" height="11" rx="3" stroke={c} strokeOpacity="0.35" fill="none" />
          <rect x="2" y="2" width="18" height="8" rx="1.7" fill={c} />
          <path d="M23 4v4c.7-.3 1.2-1 1.2-2S23.7 4.3 23 4Z" fill={c} fillOpacity="0.4" />
        </svg>
      </div>
    </div>
  );
}

// ── Device bezel — titanium frame + dynamic island + home indicator ─
function Bezel({ children, bg = "#F5F5F5", darkStatus = false }) {
  return (
    <div className="mira-bezel">
      <div className="mira-screen" style={{ background: bg }}>
        <div className="mira-island" />
        <StatusBar dark={darkStatus} />
        {children}
        <div className="mira-home-indicator" />
      </div>
    </div>
  );
}

// ── App header (back + memory brain, or custom title) ───────────────
function Header({ dot = false, onBack, onMemory, showMemory = true }) {
  return (
    <div className="mira-header">
      <button className="mira-iconbtn mira-iconbtn--ring" aria-label="Back" onClick={onBack}>
        <Icons.ArrowLeft size={22} />
      </button>
      {showMemory && (
        <button className="mira-iconbtn" aria-label="Memory" onClick={onMemory} style={{ position: "relative" }}>
          <Icons.Brain size={23} />
          {dot && <span className="mira-header-dot" />}
        </button>
      )}
    </div>
  );
}

// Title header used on Daily Brief / Setting style screens
function TitleHeader({ title, subtitle, onBack, right }) {
  return (
    <div className="mira-titlehead">
      <button className="mira-iconbtn mira-iconbtn--ring" aria-label="Back" onClick={onBack}>
        <Icons.ArrowLeft size={22} />
      </button>
      <div className="mira-titlehead-c">
        <span className="t-headtitle">{title}</span>
        {subtitle && <span className="t-headsub">{subtitle}</span>}
      </div>
      <div className="mira-titlehead-r">{right}</div>
    </div>
  );
}

Object.assign(window, { Icons, Orb, TabBar, Badge, StatusBar, Bezel, Header, TitleHeader });
