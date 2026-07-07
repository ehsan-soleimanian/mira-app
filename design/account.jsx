// Mira — Account settings. Profile, security, plan, memory & data. Calm, grouped rows.

function AccountScreen({ go, goBack }) {
  const [faceId, setFaceId] = React.useState(true);
  const [autoLock, setAutoLock] = React.useState(true);

  const Ico = ({ d, ...p }) => (
    <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" {...p}>{d}</svg>
  );
  const Chev = (
    <span className="ac-chev"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m9 6 6 6-6 6" /></svg></span>
  );

  const Row = ({ icon, title, sub, value, chev = true, danger, onClick, children }) => (
    <button className={"ac-row" + (danger ? " ac-danger" : "")} onClick={onClick}>
      {icon && <span className="ac-ic">{icon}</span>}
      <span className="ac-rtx">
        <span className="ac-rt" style={danger ? { color: "#C0392B" } : null}>{title}</span>
        {sub && <span className="ac-rs">{sub}</span>}
      </span>
      {value && <span className="ac-val">{value}</span>}
      {children}
      {chev && !children && Chev}
    </button>
  );

  return (
    <div className="mira-screen-body rd-account">
      <div className="ac-scroll">
        <div className="ac-top">
          <button className="ac-back" onClick={goBack}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 6-6 6 6 6" /></svg>
            Settings
          </button>
        </div>
        <h1 className="ac-title">Account</h1>

        {/* profile */}
        <div className="ac-profile">
          <div className="ac-avatar">SK</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="ac-pname">Sara Kim</div>
            <div className="ac-pmail">sara.kim@hey.com</div>
            <div className="ac-sync"><span />All memories synced</div>
          </div>
        </div>

        {/* profile fields */}
        <div className="ac-sec">
          <div className="ac-label">Profile</div>
          <div className="ac-group">
            <Row icon={<Ico d={<><circle cx="12" cy="8" r="4" /><path d="M4 21c0-4 4-6 8-6s8 2 8 6" /></>} />} title="Name" value="Sara Kim" />
            <Row icon={<Ico d={<><rect x="3" y="5" width="18" height="14" rx="2.5" /><path d="m4 7 8 6 8-6" /></>} />} title="Email" value="sara.kim@hey.com" />
            <Row icon={<Ico d={<path d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L16 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2Z" />} />} title="Phone" value="+1 (415) •••‑2231" />
          </div>
        </div>

        {/* security */}
        <div className="ac-sec">
          <div className="ac-label">Security</div>
          <div className="ac-group">
            <Row icon={<Ico d={<><rect x="4" y="10" width="16" height="10" rx="2.5" /><path d="M8 10V7a4 4 0 0 1 8 0v3" /></>} />} title="Face ID unlock" sub="Require Face ID to open Mira" chev={false}>
              <span className={"ac-tog" + (faceId ? "" : " off")} onClick={(e) => { e.stopPropagation(); setFaceId(v => !v); }} />
            </Row>
            <Row icon={<Ico d={<><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>} />} title="Auto‑lock" sub="Lock after 5 minutes idle" chev={false}>
              <span className={"ac-tog" + (autoLock ? "" : " off")} onClick={(e) => { e.stopPropagation(); setAutoLock(v => !v); }} />
            </Row>
            <Row icon={<Ico d={<><rect x="3" y="11" width="18" height="10" rx="2" /><path d="M7 11V8a5 5 0 0 1 10 0v3" /></>} />} title="Change password" />
          </div>
        </div>

        {/* plan */}
        <div className="ac-sec">
          <div className="ac-label">Plan</div>
          <div className="ac-group">
            <Row icon={<Ico d={<path d="M3 8l4 3 5-6 5 6 4-3-2 11H5L3 8Z" />} />} title="Mira Plus" sub="Renews Aug 12 · $8 / month" value="Manage" />
          </div>
        </div>

        {/* preferences */}
        <div className="ac-sec">
          <div className="ac-label">Preferences</div>
          <div className="ac-group">
            <Row icon={<Ico d={<><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.7 21a2 2 0 0 1-3.4 0" /></>} />} title="Notifications" sub="Brief, reminders & quiet hours" onClick={() => go("notifications")} />
            <Row icon={<Ico d={<><path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1" /><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1" /></>} />} title="Connected apps" sub="Calendar, Notes, Photos & more" onClick={() => go("connectedapps")} />
          </div>
        </div>

        {/* memory & data */}
        <div className="ac-sec">
          <div className="ac-label">Memory &amp; data</div>
          <div className="ac-group">
            <div className="ac-storage">
              <div className="ac-strow"><span className="n">34 memories</span><span className="s">of 2,000 · plenty of room</span></div>
              <div className="ac-bar"><i /></div>
            </div>
            <Row icon={<Ico d={<><path d="M12 3v12" /><path d="m8 11 4 4 4-4" /><path d="M4 19h16" /></>} />} title="Export my data" sub="Download everything Mira holds" />
            <Row icon={<Ico d={<><path d="M12 3a9 9 0 1 0 9 9" /><path d="M12 7v5l3 2" /></>} />} title="Memory history" sub="See what was captured & when" />
          </div>
        </div>

        {/* account actions */}
        <div className="ac-sec">
          <div className="ac-group">
            <Row icon={<Ico d={<><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" /><path d="m16 17 5-5-5-5" /><path d="M21 12H9" /></>} />} title="Sign out" chev={false} />
            <Row danger icon={<Ico d={<><path d="M3 6h18" /><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" /><path d="M6 6v14a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V6" /></>} />} title="Delete account" chev={false} />
          </div>
        </div>

        <div className="ac-foot">Mira · Version 1.0</div>
      </div>
    </div>
  );
}

Object.assign(window, { AccountScreen });
