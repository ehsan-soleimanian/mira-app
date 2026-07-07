// Mira — Connected apps settings. Sources Mira can weave into your memory graph.

function ConnectedAppsScreen({ go, goBack }) {
  const [conn, setConn] = React.useState({ gmail: false, safari: false, readwise: false, voice: false });
  const connect = (k) => setConn(s => ({ ...s, [k]: true }));

  const Chev = (
    <span className="ac-chev"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m9 6 6 6-6 6" /></svg></span>
  );
  const Tile = ({ bg, children }) => (
    <span className="ca-tile" style={{ background: bg }}>{children}</span>
  );
  const G = ({ d, fill }) => (
    <svg width="21" height="21" viewBox="0 0 24 24" fill={fill ? "currentColor" : "none"} stroke={fill ? "none" : "currentColor"} strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">{d}</svg>
  );

  const ConnectedRow = ({ tile, name, sub }) => (
    <button className="ac-row">
      {tile}
      <span className="ac-rtx">
        <span className="ac-rt">{name}</span>
        <span className="ac-rs"><i className="ca-dot" />{sub}</span>
      </span>
      {Chev}
    </button>
  );
  const AvailableRow = ({ tile, name, sub, k }) => (
    <div className="ac-row ca-avl">
      {tile}
      <span className="ac-rtx">
        <span className="ac-rt">{name}</span>
        <span className="ac-rs">{sub}</span>
      </span>
      {conn[k]
        ? <span className="ca-added"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5" /></svg>Connected</span>
        : <button className="ca-connect" onClick={() => connect(k)}>Connect</button>}
    </div>
  );

  return (
    <div className="mira-screen-body rd-account rd-ca">
      <div className="ac-scroll">
        <div className="ac-top">
          <button className="ac-back" onClick={goBack}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 6-6 6 6 6" /></svg>
            Settings
          </button>
        </div>
        <h1 className="ac-title">Connected apps</h1>
        <p className="nt-intro">Mira quietly weaves these sources into your memory — nothing leaves without your say.</p>

        <div className="ac-sec">
          <div className="ac-label">Connected</div>
          <div className="ac-group">
            <ConnectedRow
              tile={<Tile bg="#E9484820"><G fill d={<path d="M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Zm0 3 8 5 8-5" />} /></Tile>}
              name="Calendar" sub="Synced 2m ago · feeds your Brief" />
            <ConnectedRow
              tile={<Tile bg="#F0B54520"><G d={<><rect x="4" y="3" width="16" height="18" rx="2.5" /><path d="M8 8h8M8 12h8M8 16h5" /></>} /></Tile>}
              name="Notes" sub="Synced 1h ago · 128 notes" />
            <ConnectedRow
              tile={<Tile bg="#5B8DEF20"><G d={<><rect x="3" y="5" width="18" height="14" rx="2.5" /><circle cx="8.5" cy="10" r="1.6" /><path d="m5 18 5-4 3 2 3-3 5 4" /></>} /></Tile>}
              name="Photos" sub="Synced today · screenshots & scans" />
          </div>
        </div>

        <div className="ac-sec">
          <div className="ac-label">Available</div>
          <div className="ac-group">
            <AvailableRow k="gmail"
              tile={<Tile bg="#EA433520"><G d={<><rect x="3" y="5" width="18" height="14" rx="2.5" /><path d="m3 7 9 6 9-6" /></>} /></Tile>}
              name="Gmail" sub="Turn important mail into memories" />
            <AvailableRow k="safari"
              tile={<Tile bg="#2A9DF420"><G d={<><circle cx="12" cy="12" r="9" /><path d="m15.5 8.5-2 5-5 2 2-5 5-2Z" /></>} /></Tile>}
              name="Safari" sub="Save pages & highlights as you browse" />
            <AvailableRow k="readwise"
              tile={<Tile bg="#7C6BEA20"><G d={<><path d="M4 5a2 2 0 0 1 2-2h12v18H6a2 2 0 0 1-2-2Z" /><path d="M18 3v18" /></>} /></Tile>}
              name="Readwise" sub="Import book & article highlights" />
            <AvailableRow k="voice"
              tile={<Tile bg="#E8686820"><G d={<><rect x="9" y="3" width="6" height="11" rx="3" /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></>} /></Tile>}
              name="Voice Memos" sub="Transcribe recordings into your graph" />
          </div>
        </div>

        <div className="ca-privacy">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z" /></svg>
          <span>Mira only reads what you connect, and processes it privately. Disconnect anytime.</span>
        </div>

        <div className="ac-foot">4 sources available to connect</div>
      </div>
    </div>
  );
}

Object.assign(window, { ConnectedAppsScreen });
