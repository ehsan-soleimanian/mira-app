// Mira — Canvas screen. Two modes: Board (freeform) and Map (auto memory graph).

// ── Board view: freeform card board ─────────────────────────────────
function BoardView() {
  const rootRef = React.useRef(null);
  React.useEffect(() => {
    const root = rootRef.current; if (!root) return;
    const q = (s) => root.querySelector(s), qa = (s) => [...root.querySelectorAll(s)];
    const pan = q("#c-pan"), canvas = root;
    let offX = -100, offY = 40, scale = 0.7;
    const applyPan = () => { pan.style.transform = `translate(${offX}px, ${offY}px) scale(${scale})`; q("#c-lvl").textContent = Math.round(scale * 100) + "%"; };
    applyPan();
    const zoomBy = (d) => {
      const cx = canvas.clientWidth / 2, cy = canvas.clientHeight / 2;
      const ns = Math.max(0.4, Math.min(1.4, scale + d));
      offX = cx - (cx - offX) * (ns / scale); offY = cy - (cy - offY) * (ns / scale); scale = ns; applyPan();
    };
    q("#c-zoomout").onclick = () => zoomBy(-0.15);
    q("#c-zoomin").onclick = () => zoomBy(0.15);

    let drag = null;
    const onDown = (e) => {
      if (e.target.closest(".cc") || e.target.closest(".c-tools") || e.target.closest(".c-fit") ||
          e.target.closest(".c-suggest") || e.target.closest(".rd-nav") || e.target.closest(".c-connect-banner") ||
          e.target.closest(".cv-modebar")) return;
      drag = { x: e.clientX, y: e.clientY, ox: offX, oy: offY }; pan.style.transition = "none";
    };
    const onMove = (e) => { if (!drag) return; offX = drag.ox + (e.clientX - drag.x); offY = drag.oy + (e.clientY - drag.y); applyPan(); };
    const onUp = () => { if (drag) { pan.style.transition = ""; drag = null; } };
    canvas.addEventListener("pointerdown", onDown);
    window.addEventListener("pointermove", onMove);
    window.addEventListener("pointerup", onUp);

    // connect mode
    let connecting = false, srcCard = null;
    const banner = q("#c-connectBanner"), ccbTx = q("#c-ccbTx");
    const resetBanner = () => { ccbTx.innerHTML = "<b>Connect mode</b><small>Tap a memory, then another, to link them.</small>"; };
    const clearSrc = () => { if (srcCard) srcCard.classList.remove("src"); srcCard = null; };
    const setMode = (mode) => {
      const on = mode === "connect"; connecting = on;
      canvas.classList.toggle("connecting", on);
      banner.classList.toggle("show", on);
      qa(".c-tools .c-tool").forEach((t, i) => t.classList.toggle("on", on ? i === 3 : i === 0));
      q("#c-suggest").classList.toggle("hide", on);
      clearSrc(); resetBanner();
    };
    const suggestRelation = (a, b) => {
      const t = (a.textContent + " " + b.textContent).toLowerCase();
      if (t.includes("maya")) return "with Maya";
      if (t.includes("overstory") || t.includes("pack")) return "to bring";
      if (t.includes("flight") || t.includes("cabin") || t.includes("coast") || t.includes("big sur")) return "same trip";
      return "related";
    };
    const centerOf = (c) => ({ x: parseFloat(c.style.left) + c.offsetWidth / 2, y: parseFloat(c.style.top) + c.offsetHeight / 2 });
    const drawConnection = (a, b) => {
      const A = centerOf(a), B = centerOf(b), mx = (A.x + B.x) / 2, my = (A.y + B.y) / 2, NS = "http://www.w3.org/2000/svg";
      const path = document.createElementNS(NS, "path");
      path.setAttribute("d", `M${A.x} ${A.y} C ${A.x + (mx - A.x) * 0.6} ${A.y}, ${B.x - (B.x - mx) * 0.6} ${B.y}, ${B.x} ${B.y}`);
      path.setAttribute("class", "edge-new");
      q("#c-edges").appendChild(path);
      const lbl = document.createElement("div");
      lbl.className = "rel-label"; lbl.style.left = mx + "px"; lbl.style.top = my + "px";
      lbl.innerHTML = '<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round"><path d="M20 6 9 17l-5-5"/></svg>' + suggestRelation(a, b);
      pan.appendChild(lbl);
    };
    const tap = (card) => {
      if (!srcCard) { srcCard = card; card.classList.add("src"); ccbTx.innerHTML = "<b>Now tap another memory</b><small>Mira will suggest how they connect.</small>"; }
      else if (card !== srcCard) { drawConnection(srcCard, card); clearSrc(); ccbTx.innerHTML = "<b>Linked \u2713</b><small>Tap another memory to keep connecting.</small>"; }
    };
    q("#c-ccbDone").onclick = () => setMode("board");
    qa("[data-card]").forEach((card) => {
      let cd = null;
      card.addEventListener("pointerdown", (e) => {
        e.stopPropagation(); if (connecting) return;
        cd = { x: e.clientX, y: e.clientY, l: parseFloat(card.style.left), t: parseFloat(card.style.top) };
        card.classList.add("lift"); card.setPointerCapture(e.pointerId);
      });
      card.addEventListener("pointermove", (e) => { if (!cd) return; card.style.left = (cd.l + (e.clientX - cd.x) / scale) + "px"; card.style.top = (cd.t + (e.clientY - cd.y) / scale) + "px"; });
      card.addEventListener("pointerup", () => { if (cd) { card.classList.remove("lift"); cd = null; } });
      card.addEventListener("click", (e) => { if (connecting) { e.stopPropagation(); tap(card); } });
    });
    qa(".c-tools .c-tool").forEach((t, i) => t.addEventListener("click", () => {
      if (i === 3) { setMode("connect"); return; }
      setMode("board"); qa(".c-tools .c-tool").forEach((o) => o.classList.remove("on")); t.classList.add("on");
    }));
    q("#c-suggestDismiss").onclick = () => q("#c-suggest").classList.add("hide");

    return () => { canvas.removeEventListener("pointerdown", onDown); window.removeEventListener("pointermove", onMove); window.removeEventListener("pointerup", onUp); };
  }, []);

  return (
    <div className="c-canvas" id="c-canvas" ref={rootRef}>
      <div className="c-connect-banner" id="c-connectBanner">
        <span className="ccb-orb" />
        <span className="ccb-tx" id="c-ccbTx"><b>Connect mode</b><small>Tap a memory, then another, to link them.</small></span>
        <button className="ccb-done" id="c-ccbDone">Done</button>
      </div>
      <div className="c-pan" id="c-pan">
        <svg className="c-edges" id="c-edges" viewBox="0 0 1200 1200">
          <path d="M250 300 C 300 340, 300 380, 268 430" />
          <path d="M330 300 C 380 330, 420 360, 452 402" />
          <path d="M300 470 C 360 500, 400 520, 452 470" />
          <path d="M250 560 C 300 590, 360 600, 300 640" />
          <path className="dashed" d="M492 452 C 520 520, 470 590, 392 636" />
        </svg>
        <div className="frame" style={{ left: 150, top: 250, width: 360, height: 300 }}>
          <span className="flabel"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 21s-7-5.5-7-11a7 7 0 0 1 14 0c0 5.5-7 11-7 11Z" /><circle cx="12" cy="10" r="2.5" /></svg>Spring · the coast</span>
        </div>
        <div className="cc" style={{ left: 170, top: 200, transform: "rotate(-2deg)" }} data-card>
          <div className="cc-head"><span className="cc-tp note"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M12 20h9" /><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" /></svg>Note</span></div>
          <div className="cc-body"><div className="cc-t">A quiet weekend on the coast</div><div className="cc-s">Somewhere slow, near the water — spring.</div></div>
        </div>
        <div className="cc" style={{ left: 360, top: 196, transform: "rotate(2deg)" }} data-card>
          <div className="cc-photo"><span className="cap">Big Sur · saved photo</span></div>
          <div className="cc-body"><div className="cc-t">Big Sur shoreline</div></div>
        </div>
        <div className="cc" style={{ left: 180, top: 400, transform: "rotate(-1deg)" }} data-card>
          <div className="cc-head"><span className="cc-tp voice"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /></svg>Voice</span></div>
          <div className="cc-body"><div className="cc-t">Flight SA 482 · Aug 2</div><div className="cc-s">Check-in reminder set for Aug 1.</div></div>
        </div>
        <div className="cc" style={{ left: 380, top: 392, transform: "rotate(1.5deg)" }} data-card>
          <div className="cc-head"><span className="cc-tp link"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1" /><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1" /></svg>Link</span></div>
          <div className="cc-body"><div className="cc-t">Cabin by the water</div><div className="cc-s">Airbnb — saved to compare.</div></div>
        </div>
        <div className="cc sticky" style={{ left: 190, top: 596, transform: "rotate(-2.5deg)" }} data-card>
          <div className="cc-body">
            <div className="cc-t">Pack list</div>
            <div className="chk done"><span className="box"><svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3.4" strokeLinecap="round"><path d="m5 12 5 5 9-11" /></svg></span><span>Camera</span></div>
            <div className="chk"><span className="box" /><span>Warm layers</span></div>
            <div className="chk"><span className="box" /><span>The Overstory</span></div>
          </div>
        </div>
        <div className="cc" style={{ left: 470, top: 560, transform: "rotate(2deg)" }} data-card>
          <div className="cc-head"><span className="cc-tp note"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H18v18H6.5A2.5 2.5 0 0 0 4 22.5z" /><path d="M4 4.5v15" /></svg>Book</span></div>
          <div className="cc-body"><div className="cc-t">"The Overstory"</div><div className="cc-s">Maya's rec — a weekend read.</div></div>
        </div>
        <div className="cc person" style={{ left: 560, top: 452, transform: "rotate(-1.5deg)" }} data-card>
          <div className="p-row"><span className="p-av">M</span><div><div className="p-nm">Maya</div><div className="p-sub">joining · maybe</div></div></div>
        </div>
      </div>

      <div className="c-suggest" id="c-suggest">
        <span className="orb" />
        <span className="tx"><b>Blue Note</b> plays near the coast that same weekend. Add it to this board?</span>
        <button className="add">Add</button>
        <button className="dismiss" id="c-suggestDismiss" aria-label="Dismiss"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg></button>
      </div>
      <div className="c-tools">
        <button className="c-tool on" title="Move"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M5 9l-3 3 3 3M9 5l3-3 3 3M15 19l-3 3-3-3M19 9l3 3-3 3M2 12h20M12 2v20" /></svg></button>
        <button className="c-tool" title="Add card"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><rect x="4" y="4" width="16" height="16" rx="3" /><path d="M12 9v6M9 12h6" /></svg></button>
        <button className="c-tool" title="Text"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M5 6h14M12 6v13" /></svg></button>
        <button className="c-tool" title="Connect"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="6" cy="6" r="2.5" /><circle cx="18" cy="18" r="2.5" /><path d="M8 8l8 8" /></svg></button>
      </div>
      <div className="c-fit">
        <button id="c-zoomout" aria-label="Zoom out">−</button>
        <span className="lvl" id="c-lvl">70%</span>
        <button id="c-zoomin" aria-label="Zoom in">+</button>
      </div>
    </div>
  );
}

// ── Map view: Mira's auto memory graph ──────────────────────────────
function MapView() {
  const rootRef = React.useRef(null);
  React.useEffect(() => {
    const root = rootRef.current; if (!root) return;
    const IC = {
      task: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m8.5 12 2.5 2.5 4.5-5"/></svg>',
      event: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>',
      note: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>',
      book: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v18H6.5A2.5 2.5 0 0 0 4 22.5z"/><path d="M4 4.5v15"/></svg>',
      idea: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18h6M10 22h4"/><path d="M12 2a7 7 0 0 0-4 12.7c.6.5 1 1.2 1 2h6c0-.8.4-1.5 1-2A7 7 0 0 0 12 2Z"/></svg>',
      topic: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 9h16M4 15h16M10 3 8 21M16 3l-2 18"/></svg>',
    };
    const person = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6" stroke-linecap="round"/></svg>';
    const nodes = [
      { id: "john", x: 150, y: 250, size: "hub", type: "person", label: "John", initial: "J", typ: "Person", sub: "6 linked memories — mostly the contract and your weekly calls." },
      { id: "contract", x: 92, y: 366, size: "mid", type: "task", label: "Contract", typ: "Task", sub: "Call John before Friday to confirm terms." },
      { id: "meeting", x: 214, y: 384, size: "sm", type: "event", label: "Meeting", typ: "Event", sub: "Tomorrow · 3:00 PM with John." },
      { id: "draft", x: 158, y: 158, size: "sm", type: "note", label: "Draft v2", typ: "Note", sub: "Contract draft — captured 2h ago." },
      { id: "work", x: 236, y: 272, size: "mid", type: "topic", label: "Work", typ: "Topic", sub: "12 memories tagged with work." },
      { id: "maya", x: 300, y: 520, size: "hub", type: "person", label: "Maya", initial: "M", typ: "Person", sub: "Books, jazz, and weekend plans keep coming back to her." },
      { id: "book", x: 336, y: 408, size: "sm", type: "book", label: "The Overstory", typ: "Book", sub: "Recommended by Maya — captured by voice yesterday." },
      { id: "jazz", x: 362, y: 606, size: "mid", type: "topic", label: "Jazz", typ: "Topic", sub: "5 memories about live music." },
      { id: "blue", x: 262, y: 640, size: "sm", type: "event", label: "Blue Note", typ: "Event", sub: "Fri, Jul 18 · 8 PM. From a photo you took." },
      { id: "coast", x: 186, y: 520, size: "sm", type: "idea", label: "Coast weekend", typ: "Idea", sub: "A quiet weekend on the coast in spring." },
    ];
    const edges = [["john", "contract"], ["john", "meeting"], ["john", "draft"], ["contract", "meeting"], ["john", "work"], ["contract", "work"], ["draft", "work"], ["maya", "book"], ["maya", "jazz"], ["maya", "blue"], ["blue", "jazz"], ["maya", "coast"], ["coast", "john"]];
    const adj = {}; nodes.forEach((n) => (adj[n.id] = [])); edges.forEach(([a, b]) => { adj[a].push(b); adj[b].push(a); });
    const byId = Object.fromEntries(nodes.map((n) => [n.id, n]));

    const pan = root.querySelector("#g-pan"), svg = root.querySelector("#g-edges"), NS = "http://www.w3.org/2000/svg";
    edges.forEach(([a, b]) => {
      const l = document.createElementNS(NS, "line"), A = byId[a], B = byId[b];
      l.setAttribute("x1", A.x); l.setAttribute("y1", A.y); l.setAttribute("x2", B.x); l.setAttribute("y2", B.y);
      l.setAttribute("class", "edge"); l.dataset.a = a; l.dataset.b = b; svg.appendChild(l);
    });
    nodes.forEach((n, i) => {
      const el = document.createElement("div");
      el.className = `gnode s-${n.size} t-${n.type}` + (n.type === "person" ? " pulse" : "");
      el.style.left = n.x + "px"; el.style.top = n.y + "px"; el.dataset.id = n.id;
      const sz = n.size === "hub" ? 26 : n.size === "mid" ? 22 : 20;
      const inner = n.type === "person" ? `<span class="initial">${n.initial}</span>` : `<span style="width:${sz}px;height:${sz}px;display:flex">${IC[n.type] || IC.note}</span>`;
      el.innerHTML = `<div class="gnode-inner"><div class="disc">${inner}</div><div class="lbl">${n.label}</div></div>`;
      el.addEventListener("click", (e) => { e.stopPropagation(); select(n.id); });
      el.querySelector(".gnode-inner").style.animation = `floatY ${6 + (i % 4)}s ease-in-out ${i * 0.4}s infinite`;
      pan.appendChild(el);
    });
    const nodeEls = [...pan.querySelectorAll(".gnode")], edgeEls = [...svg.querySelectorAll(".edge")];

    let offX = 30, offY = 96;
    const applyPan = () => { pan.style.transform = `translate(${offX}px, ${offY}px)`; };
    applyPan();

    const detail = root.querySelector("#g-detail");
    function fill(n) {
      const ic = root.querySelector("#gd-ic");
      ic.className = "gd-ic" + (n.type === "person" ? " person" : "");
      ic.innerHTML = n.type === "person" ? `<span class="initial" style="font-size:20px">${n.initial}</span>` : `<span style="width:22px;height:22px;display:flex">${IC[n.type] || IC.note}</span>`;
      root.querySelector("#gd-type").textContent = n.typ;
      root.querySelector("#gd-nm").textContent = n.label;
      root.querySelector("#gd-sub").textContent = n.sub;
      root.querySelector("#gd-lh").textContent = `Connected to ${adj[n.id].length}`;
      const chips = root.querySelector("#gd-chips"); chips.innerHTML = "";
      adj[n.id].forEach((cid) => {
        const c = byId[cid], chip = document.createElement("button"); chip.className = "gd-chip";
        chip.innerHTML = `<span style="width:14px;height:14px;display:flex">${c.type === "person" ? person : IC[c.type] || IC.note}</span>${c.label}`;
        chip.addEventListener("click", (e) => { e.stopPropagation(); select(cid); });
        chips.appendChild(chip);
      });
      detail.classList.add("show");
    }
    function select(id) {
      const n = byId[id], near = new Set([id, ...adj[id]]);
      nodeEls.forEach((el) => { el.classList.toggle("sel", el.dataset.id === id); el.classList.toggle("dim", !near.has(el.dataset.id)); });
      edgeEls.forEach((el) => { const hot = el.dataset.a === id || el.dataset.b === id; el.classList.toggle("hot", hot); el.classList.toggle("dim", !hot); });
      const cw = root.clientWidth;
      offX = cw / 2 - n.x; offY = 220 - n.y; applyPan();
      fill(n); root.querySelector("#g-hint").style.opacity = 0;
    }
    function close() {
      detail.classList.remove("show");
      nodeEls.forEach((el) => el.classList.remove("sel", "dim"));
      edgeEls.forEach((el) => el.classList.remove("hot", "dim"));
      offX = 30; offY = 96; applyPan();
      root.querySelector("#g-hint").style.opacity = 1;
    }
    root.querySelector("#gd-close").onclick = close;
    const cv = root;
    let drag = null;
    const onDown = (e) => { if (e.target.closest(".gnode") || e.target.closest(".g-detail") || e.target.closest(".rd-nav") || e.target.closest(".cv-modebar")) return; drag = { x: e.clientX, y: e.clientY, ox: offX, oy: offY, moved: false }; pan.style.transition = "none"; };
    const onMove = (e) => { if (!drag) return; const dx = e.clientX - drag.x, dy = e.clientY - drag.y; if (Math.abs(dx) + Math.abs(dy) > 4) drag.moved = true; offX = drag.ox + dx; offY = drag.oy + dy; applyPan(); };
    const onUp = () => { if (drag) { const moved = drag.moved; pan.style.transition = ""; drag = null; if (!moved) close(); } };
    cv.addEventListener("pointerdown", onDown);
    window.addEventListener("pointermove", onMove);
    window.addEventListener("pointerup", onUp);
    return () => { cv.removeEventListener("pointerdown", onDown); window.removeEventListener("pointermove", onMove); window.removeEventListener("pointerup", onUp); };
  }, []);

  return (
    <div className="g-canvas" id="g-canvas" ref={rootRef}>
      <div className="g-pan" id="g-pan"><svg className="g-edges" id="g-edges" /></div>
      <div className="g-hint" id="g-hint"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M8 12h8M12 8v8" /><circle cx="12" cy="12" r="9" /></svg>Tap a memory · drag to explore</div>
      <div className="g-detail" id="g-detail">
        <div className="gd-top">
          <div className="gd-ic" id="gd-ic" />
          <div className="gd-tx"><div className="gd-type" id="gd-type" /><div className="gd-nm" id="gd-nm" /></div>
          <button className="gd-close" id="gd-close"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg></button>
        </div>
        <p className="gd-sub" id="gd-sub" />
        <div className="gd-lh" id="gd-lh">Connected to</div>
        <div className="gd-chips" id="gd-chips" />
      </div>
    </div>
  );
}

// ── Canvas shell: mode toggle + shared header + nav ─────────────────
function CanvasScreen({ go }) {
  const [mode, setMode] = React.useState("board");
  const MicIcon = () => (
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round"><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></svg>
  );
  return (
    <div className="mira-screen-body rd-canvas">
      {mode === "board" ? <BoardView /> : <MapView />}

      {/* mode toggle + context */}
      <div className="cv-modebar">
        <div className="cv-seg">
          <button className={mode === "board" ? "on" : ""} onClick={() => setMode("board")}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="7" height="7" rx="1.5" /><rect x="14" y="3" width="7" height="7" rx="1.5" /><rect x="3" y="14" width="7" height="7" rx="1.5" /><rect x="14" y="14" width="7" height="7" rx="1.5" /></svg>
            Board
          </button>
          <button className={mode === "map" ? "on" : ""} onClick={() => setMode("map")}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="5" r="2.2" /><circle cx="5.5" cy="18" r="2.2" /><circle cx="18.5" cy="18" r="2.2" /><path d="M11 6.8 6.6 15.6M13 6.8l4.4 8.8M7.9 18h8.2" /></svg>
            Map
          </button>
        </div>
        <span className="cv-context">{mode === "board" ? "Coast trip · 8 memories" : "Your memory · 34 memories · 61 connections"}</span>
      </div>

      {/* bottom nav */}
      <div className="rd-nav">
        <button className="rd-navitem" onClick={() => go("home")}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M3 10.5 12 3l9 7.5" /><path d="M5 9.5V21h14V9.5" /></svg>
          Home
        </button>
        <button className="rd-navitem" onClick={() => go("library")}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M4 5h11" /><path d="M4 10h11" /><path d="M4 15h7" /><circle cx="18.5" cy="16.5" r="3" /><path d="M20.8 18.8 23 21" /></svg>
          Library
        </button>
        <div className="rd-navspacer" />
        <button className="rd-navitem is-active">
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
    </div>
  );
}

Object.assign(window, { CanvasScreen });
