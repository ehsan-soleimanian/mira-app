// Mira — Ask Mira chat. A calm, memory-grounded conversation.
// Reached from "Ask Mira about this" (memory detail) and elsewhere.
// Mira answers by drawing on connected memories, cited inline as small cards.

function ChatScreen({ go, goBack }) {
  const { useState, useEffect, useRef } = React;

  const typePath = {
    note: <path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />,
    voice: <><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></>,
    event: <><rect x="3" y="4" width="18" height="17" rx="2.5" /><path d="M16 2v4M8 2v4M3 10h18" /></>,
    photo: <><rect x="3" y="5" width="18" height="14" rx="2.5" /><circle cx="12" cy="12" r="3.2" /></>,
  };
  const Cite = ({ c }) => (
    <button className="ch-cite" onClick={() => go("memory")}>
      <span className={"ch-cite-ic ch-ic-" + c.type}>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.85" strokeLinecap="round" strokeLinejoin="round">{typePath[c.type]}</svg>
      </span>
      <span className="ch-cite-tx"><span className="ch-cite-t">{c.title}</span><span className="ch-cite-s">{c.sub}</span></span>
    </button>
  );

  // The chat adapts to whichever memory opened it. Whatever taps into a memory
  // sets mira-mem-kind; we ground the whole conversation in that memory's graph.
  const kind = (typeof localStorage !== "undefined" && localStorage.getItem("mira-mem-kind")) || "note";

  const CONTEXTS = {
    // ── Typed note: "Contract with John" ──
    note: {
      anchor: "Contract with John",
      anchorType: "note",
      opening: "This one's about the partnership contract with John. Ask me anything — what's open, how it connects, or I can draft something for you.",
      firstQ: "What's still open before Friday?",
      starters: ["When did we last talk?", "What's the Q3 scope?", "Draft a reminder"],
      answers: {
        "What's still open before Friday?": {
          text: "Two things. Confirm the narrowed Q3 scope with John, and send the signed copy back. The signed PDF is already in your Library from last week's meeting — so really it's just the call.",
          cites: [
            { type: "event", title: "Meeting with John", sub: "Last Thursday" },
            { type: "photo", title: "Signed contract — page 1", sub: "Photo · read by Mira" },
          ],
        },
        "When did we last talk?": {
          text: "Last Thursday, in your 2pm meeting. That's where the partnership scope first came up — you noted John wanted it narrowed to Q3 before signing.",
          cites: [{ type: "event", title: "Meeting with John", sub: "Thu · 2:00 PM" }],
        },
        "Draft a reminder": {
          text: "Here's a gentle one:  “Call John to confirm the Q3 scope — before Friday.”  I can add it to Thursday morning so it surfaces in your Brief. Want me to set it?",
          cites: [],
          action: "reminder",
        },
        "What's the Q3 scope?": {
          text: "From your notes: the partnership narrows to Q3 deliverables only — onboarding and the launch story — with the feature roadmap deferred. John asked to keep it tight before committing.",
          cites: [
            { type: "note", title: "Q3 partnership terms", sub: "Note · 3 days ago" },
            { type: "voice", title: "Idea for the Q3 launch", sub: "Voice · 2h ago" },
          ],
        },
      },
    },
    // ── Voice note: "Idea for the Q3 launch" ──
    voice: {
      anchor: "Idea for the Q3 launch",
      anchorType: "voice",
      opening: "This is your voice note about the Q3 launch. Ask me anything — I can pull the thread back, draft the design ask, or remind you to loop in Priya.",
      firstQ: "What did I decide?",
      starters: ["Draft the design ask", "Remind me about Priya", "What's the Q3 scope?"],
      answers: {
        "What did I decide?": {
          text: "To lead the Q3 launch with the onboarding story, not the feature list — “people connect with the calm, not the checklist.” You wanted a quiet hero from design and the three testimonials from last quarter pulled in.",
          cites: [
            { type: "note", title: "Q3 partnership terms", sub: "Note · 3 days ago" },
            { type: "photo", title: "Last quarter testimonials", sub: "Photo · read by Mira" },
          ],
        },
        "Draft the design ask": {
          text: "Here's a start:  “For the Q3 launch — a quiet hero that leads with the onboarding story over the feature list. Calm over checklist. Pull in three testimonials from last quarter.”  Want me to send it to your notes?",
          cites: [],
          action: "reminder",
        },
        "Remind me about Priya": {
          text: "You wanted to circle back with Priya on timing. I can set a gentle nudge for tomorrow morning so it lands in your Brief before the standup.",
          cites: [{ type: "event", title: "Standup with Priya", sub: "Tomorrow · 9:30 AM" }],
          action: "reminder",
        },
        "What's the Q3 scope?": {
          text: "From your notes: the partnership narrows to Q3 deliverables only — onboarding and the launch story — with the feature roadmap deferred. This voice note is where the launch angle first came up.",
          cites: [
            { type: "note", title: "Contract with John", sub: "Note · today" },
            { type: "note", title: "Q3 partnership terms", sub: "Note · 3 days ago" },
          ],
        },
      },
    },
  };

  const ctx = CONTEXTS[kind] || CONTEXTS.note;
  const ANSWERS = ctx.answers;
  const STARTERS = ctx.starters;

  const [msgs, setMsgs] = useState([
    { who: "mira", text: ctx.opening, cites: [] },
    { who: "me", text: ctx.firstQ },
    { who: "mira", ...ANSWERS[ctx.firstQ] },
  ]);
  const [typing, setTyping] = useState(false);
  const [remSet, setRemSet] = useState(false);
  const [draft, setDraft] = useState("");
  const scrollRef = useRef(null);
  const asked = useRef(new Set([ctx.firstQ]));

  useEffect(() => {
    const el = scrollRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [msgs, typing]);

  const ask = (q) => {
    const key = Object.keys(ANSWERS).find((k) => k.toLowerCase() === q.toLowerCase());
    const ans = key ? ANSWERS[key] : {
      text: "I don't have anything on that yet — but the moment you capture it, I'll connect it here. For now, this memory links to the rest of your “" + ctx.anchor + "” thread.",
      cites: [Object.values(ANSWERS).find((a) => a.cites && a.cites.length)?.cites[0]].filter(Boolean),
    };
    if (key) asked.current.add(key);
    setMsgs((m) => [...m, { who: "me", text: q }]);
    setTyping(true);
    setDraft("");
    setTimeout(() => {
      setTyping(false);
      setMsgs((m) => [...m, { who: "mira", ...ans }]);
    }, 1150);
  };

  const remaining = STARTERS.filter((s) => !asked.current.has(s));
  const lastIsMira = msgs.length && msgs[msgs.length - 1].who === "mira" && !typing;

  return (
    <div className="mira-screen-body rd-chat" data-screen-label="Ask Mira">
      {/* header */}
      <div className="ch-head">
        <button className="ch-icbtn" aria-label="Back" onClick={goBack}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 5l-7 7 7 7" /></svg>
        </button>
        <div className="ch-head-tx">
          <span className="ch-head-t">Ask Mira</span>
          <span className="ch-head-s">
            <span className="ch-ctx-ic">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">{typePath[ctx.anchorType] || typePath.note}</svg>
            </span>
            About “{ctx.anchor}”
          </span>
        </div>
        <button className="ch-icbtn" aria-label="See in Canvas" onClick={() => go("canvas")}>
          <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><circle cx="6" cy="12" r="2.4" /><circle cx="18" cy="6" r="2.4" /><circle cx="18" cy="18" r="2.4" /><path d="M8.2 10.9 15.8 7" /><path d="M8.2 13.1 15.8 17" /></svg>
        </button>
      </div>

      {/* thread */}
      <div className="ch-scroll" ref={scrollRef}>
        {msgs.map((m, i) => m.who === "me" ? (
          <div className="ch-row ch-row-me" key={i}><div className="ch-me">{m.text}</div></div>
        ) : (
          <div className="ch-row ch-row-mira" key={i}>
            <span className="ch-orb"><span className="ch-orb-ring" /></span>
            <div className="ch-mira">
              <p className="ch-mira-tx">{m.text}</p>
              {m.cites && m.cites.length > 0 && (
                <div className="ch-cites">
                  <span className="ch-cites-lead">From your memories</span>
                  {m.cites.map((c, j) => <Cite c={c} key={j} />)}
                </div>
              )}
              {m.action === "reminder" && (
                <button className={"ch-remind" + (remSet ? " done" : "")} onClick={() => setRemSet(true)}>
                  {remSet
                    ? <><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.1" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5" /></svg>Added to Thursday morning</>
                    : <><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="13" r="8" /><path d="M12 9v4l2.5 2.5" /></svg>Set this reminder</>}
                </button>
              )}
            </div>
          </div>
        ))}

        {typing && (
          <div className="ch-row ch-row-mira">
            <span className="ch-orb"><span className="ch-orb-ring" /></span>
            <div className="ch-mira ch-typing"><span></span><span></span><span></span></div>
          </div>
        )}

        {/* suggested follow-ups */}
        {lastIsMira && remaining.length > 0 && (
          <div className="ch-suggest">
            {remaining.map((s, i) => (
              <button className="ch-chip" key={i} onClick={() => ask(s)}>{s}</button>
            ))}
          </div>
        )}
      </div>

      {/* compose */}
      <div className="ch-compose">
        <input
          className="ch-input"
          placeholder="Ask about your memories…"
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter" && draft.trim()) ask(draft.trim()); }}
        />
        {draft.trim()
          ? <button className="ch-send" aria-label="Send" onClick={() => ask(draft.trim())}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6" /></svg>
            </button>
          : <button className="ch-mic" aria-label="Speak" onClick={() => go("capture")}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.85" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="2" width="6" height="12" rx="3" /><path d="M5 10a7 7 0 0 0 14 0" /><path d="M12 19v3" /></svg>
            </button>}
      </div>
    </div>
  );
}

Object.assign(window, { ChatScreen });
