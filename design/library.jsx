// Mira — Library screen. Browse captured memories: search, filters, collections, time-grouped list.

function LibraryScreen({ go }) {
  const rootRef = React.useRef(null);
  const [filter, setFilter] = React.useState("all");
  const [query, setQuery] = React.useState("");
  const [selecting, setSelecting] = React.useState(false);
  const [selected, setSelected] = React.useState(() => new Set());
  const pressTimer = React.useRef(null);
  const suppressClick = React.useRef(false);

  const FILTERS = [
    { f: "all", label: "All", ic: null },
    { f: "note", label: "Notes", ic: <path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" /> },
    { f: "voice", label: "Voice", ic: <><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /></> },
    { f: "photo", label: "Photos", ic: <><rect x="3" y="5" width="18" height="14" rx="2.5" /><circle cx="12" cy="12" r="3.2" /></> },
    { f: "link", label: "Links", ic: <><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1" /><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1" /></> },
    { f: "event", label: "Events", ic: <><rect x="3" y="4" width="18" height="17" rx="2.5" /><path d="M16 2v4M8 2v4M3 10h18" /></> },
  ];

  const MEMS = [
    { id: "m0", day: "Today", type: "note", title: "Contract with John", sub: "Needs a call to confirm the terms before Friday. Connects to the meeting note from last week.", meta: ["Note", "2h ago"], links: 3, text: "contract with john call confirm terms" },
    { id: "m1", day: "Today", type: "voice", title: "Book Maya recommended", sub: "“The Overstory” — a quiet weekend read for the coast trip.", meta: ["Voice · 0:12", "Today, 8:30 AM"], text: "book maya recommended the overstory" },
    { id: "m2", day: "This week", type: "event", title: "Blue Note — live jazz", sub: "Fri, Jul 18 · 8 PM at The Corner Room. From a photo you took.", meta: ["Event", "Tue"], links: 2, text: "blue note live jazz corner room tickets" },
    { id: "m3", day: "This week", type: "link", title: "On calm technology", sub: "Saved article about designing tools that ask for less attention.", meta: ["Link", "Mon"], text: "article calm technology second brain design" },
    { id: "m4", day: "This week", type: "photo", title: "Whiteboard sketch", sub: "Roadmap from the studio session — Mira read the three phases.", meta: ["Photo", "Mon"], text: "whiteboard sketch product roadmap studio" },
    { id: "m5", day: "Earlier", type: "note", title: "A quiet weekend on the coast", sub: "Idea for spring — somewhere slow, near the water.", meta: ["Note", "Jun 28"], text: "idea quiet weekend coast spring" },
    { id: "m6", day: "Earlier", type: "voice", title: "Flight SA 482 booked", sub: "Aug 2 departure. Check-in reminder set for the day before.", meta: ["Voice · 0:08", "Jun 24"], text: "flight sa 482 august trip booking" },
  ];

  const TypeIc = ({ type }) => {
    const paths = {
      note: <path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />,
      voice: <><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></>,
      link: <><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1" /><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1" /></>,
      event: <><rect x="3" y="4" width="18" height="17" rx="2.5" /><path d="M16 2v4M8 2v4M3 10h18" /></>,
      photo: <><rect x="3" y="5" width="18" height="14" rx="2.5" /><circle cx="12" cy="12" r="3.2" /></>,
    };
    return <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{paths[type]}</svg>;
  };

  const q = query.trim().toLowerCase();
  const searching = q.length > 0 || filter !== "all";
  const visible = MEMS.filter((m) => (filter === "all" || m.type === filter) && (!q || m.text.includes(q) || m.title.toLowerCase().includes(q)));
  const days = [...new Set(visible.map((m) => m.day))];

  const highlight = (title) => {
    if (!q) return title;
    const i = title.toLowerCase().indexOf(q);
    if (i < 0) return title;
    return (<>{title.slice(0, i)}<span className="hl">{title.slice(i, i + q.length)}</span>{title.slice(i + q.length)}</>);
  };

  const MicIcon = ({ w = 26, sw = 2 }) => (
    <svg width={w} height={w} viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth={sw} strokeLinecap="round"><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></svg>
  );

  // selection helpers
  const toggle = (id) => setSelected((prev) => { const n = new Set(prev); n.has(id) ? n.delete(id) : n.add(id); return n; });
  const enterWith = (id) => { setSelecting(true); setSelected(new Set([id])); };
  const exitSelect = () => { setSelecting(false); setSelected(new Set()); };
  const visibleIds = visible.map((m) => m.id);
  const allSelected = visibleIds.length > 0 && visibleIds.every((id) => selected.has(id));
  const toggleAll = () => setSelected(allSelected ? new Set() : new Set(visibleIds));
  const startPress = (id) => { suppressClick.current = false; pressTimer.current = setTimeout(() => { suppressClick.current = true; enterWith(id); }, 420); };
  const cancelPress = () => { clearTimeout(pressTimer.current); };
  const onMemClick = (id) => {
    if (suppressClick.current) { suppressClick.current = false; return; }
    if (selecting) { toggle(id); return; }
    const m = MEMS.find((x) => x.id === id);
    localStorage.setItem("mira-mem-kind", m && m.type === "voice" ? "voice" : "note");
    go("memory");
  };

  return (
    <div className={"mira-screen-body rd-library" + (selecting ? " selecting" : "")} ref={rootRef}>
      {selecting && (
        <div className="sel-bar">
          <button className="sel-x" onClick={exitSelect} aria-label="Cancel"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#1B1C24" strokeWidth="2.1" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg></button>
          <div className="sel-count">{selected.size === 0 ? "Select memories" : selected.size + " selected"}</div>
          <button className="sel-all" onClick={toggleAll}>{allSelected ? "Deselect all" : "Select all"}</button>
        </div>
      )}
      <div className="lb-scroll">
        {/* header */}
        <div className="lb-head">
          <div className="lb-eyebrow">Your memory</div>
          <div className="lb-titlerow">
            <div className="lb-title">Library<small>342 memories, all held safe</small></div>
            <button className="lb-gear" aria-label="Settings" onClick={() => go("account")}>
              <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#6B6C73" strokeWidth="1.7"><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" /></svg>
            </button>
          </div>
        </div>

        {/* search */}
        <div className="lb-search" onClick={(e) => e.currentTarget.querySelector("input").focus()}>
          <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="#B7B8BE" strokeWidth="2" strokeLinecap="round"><circle cx="11" cy="11" r="7" /><path d="m21 21-4.3-4.3" /></svg>
          <input placeholder="Search your memory…" value={query} onChange={(e) => setQuery(e.target.value)} />
          <button className="voice" aria-label="Search by voice"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round"><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></svg></button>
        </div>

        {/* filter chips */}
        <div className="lb-filters">
          {FILTERS.map((c) => (
            <button key={c.f} className={"chip" + (filter === c.f ? " on" : "")} onClick={() => setFilter(c.f)}>
              {c.ic && <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#8A8B92" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">{c.ic}</svg>}
              {c.label}
            </button>
          ))}
        </div>

        {/* search summary OR collections */}
        {searching ? (
          <div className="sr-head">
            <div className="sr-count">
              {visible.length === 0 ? <>No matches{q && <> for “<b>{query.trim()}</b>”</>}</>
                : <><b>{visible.length}</b> {visible.length === 1 ? "memory" : "memories"}{q && <> for “<b>{query.trim()}</b>”</>}</>}
            </div>
            <button className="sr-clear" onClick={() => { setQuery(""); setFilter("all"); }}>Clear</button>
          </div>
        ) : (
          <>
            <div className="lb-seclabel">
              <span className="l"><span className="ic"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h6a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /></svg></span>Mira grouped for you</span>
              <button className="see">See all</button>
            </div>
            <div className="coll-row">
              <div className="coll c1"><div className="coll-ic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><circle cx="12" cy="8" r="4" /><path d="M4 21c0-4 4-6 8-6s8 2 8 6" strokeLinecap="round" /></svg></div><div className="coll-nm">People</div><div className="coll-ct">28 memories · 9 people</div></div>
              <div className="coll c2"><div className="coll-ic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M12 21s-7-5.5-7-11a7 7 0 0 1 14 0c0 5.5-7 11-7 11Z" /><circle cx="12" cy="10" r="2.5" /></svg></div><div className="coll-nm">Coast trip</div><div className="coll-ct">14 memories · planning</div></div>
              <div className="coll c3"><div className="coll-ic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="4" width="18" height="16" rx="2.5" /><path d="M3 9h18M8 4v5" /></svg></div><div className="coll-nm">Work</div><div className="coll-ct">41 memories · 3 projects</div></div>
            </div>
          </>
        )}

        {/* memory list, grouped by day */}
        {visible.length === 0 ? (
          <div className="empty-hint">Nothing here under this filter.<br />Everything you capture will settle in quietly.</div>
        ) : (
          days.map((day) => (
            <React.Fragment key={day}>
              <div className="day-label">{day}</div>
              {visible.filter((m) => m.day === day).map((m) => (
                <button className={"mem" + (selected.has(m.id) ? " sel" : "")} key={m.id}
                  onClick={() => onMemClick(m.id)}
                  onPointerDown={() => startPress(m.id)} onPointerMove={cancelPress}
                  onPointerUp={cancelPress} onPointerLeave={cancelPress}
                  onContextMenu={(e) => e.preventDefault()}>
                  <span className="mem-check"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="m5 12 5 5 9-11" /></svg></span>
                  <span className={"mem-ic " + m.type}><TypeIc type={m.type} /></span>
                  <span className="mem-body">
                    <span className="mem-t">{highlight(m.title)}</span>
                    <span className="mem-s">{m.sub}</span>
                    <span className="mem-meta">
                      <span className="mem-tp">{m.meta[0]}</span>
                      <span className="mem-time">{m.meta[1]}</span>
                      {m.links && <><span className="mem-sep" /><span className="mem-links"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="6" cy="12" r="2.5" /><circle cx="18" cy="6" r="2.5" /><circle cx="18" cy="18" r="2.5" /><path d="M8.2 10.8 15.8 7" /><path d="M8.2 13.2 15.8 17" /></svg>{m.links} links</span></>}
                    </span>
                  </span>
                </button>
              ))}
            </React.Fragment>
          ))
        )}

        {!searching && <div className="lb-end">You've kept 342 memories.<br />Mira holds them so you don't have to.</div>}
      </div>

      {/* bottom nav — or selection action bar */}
      {selecting ? (
        <div className="sel-actions">
          <button className="sa" disabled={selected.size === 0}><span className="saic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h6a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /></svg></span>Collection</button>
          <button className="sa" disabled={selected.size === 0}><span className="saic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><path d="M12 17v5M9 3h6l-1 6 3 3H7l3-3-1-6Z" /></svg></span>Pin</button>
          <button className="sa" disabled={selected.size === 0}><span className="saic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="4" width="18" height="4" rx="1" /><path d="M5 8v11a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V8M10 12h4" /></svg></span>Archive</button>
          <button className="sa danger" disabled={selected.size === 0}><span className="saic"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><path d="M4 7h16M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13" /></svg></span>Delete</button>
        </div>
      ) : (
      <div className="rd-nav">
        <button className="rd-navitem" onClick={() => go("home")}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M3 10.5 12 3l9 7.5" /><path d="M5 9.5V21h14V9.5" /></svg>
          Home
        </button>
        <button className="rd-navitem is-active">
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
        <button className="rd-navmic" aria-label="Capture by voice" onClick={() => go("listen")}>
          <MicIcon />
        </button>
      </div>
      )}
    </div>
  );
}

Object.assign(window, { LibraryScreen });
