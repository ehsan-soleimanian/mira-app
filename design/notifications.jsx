// Mira — Notifications settings. Calm, opt-in. Reuses .rd-account row/toggle styling.

function NotificationsScreen({ go, goBack }) {
  const [st, setSt] = React.useState({
    brief: true, briefResurface: true,
    timeSensitive: true, nudges: true,
    captureConfirm: true, weekly: false,
    quiet: true, sound: true, haptics: true,
  });
  const t = (k) => setSt(s => ({ ...s, [k]: !s[k] }));

  const Ico = ({ d }) => (
    <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{d}</svg>
  );
  const Chev = (
    <span className="ac-chev"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m9 6 6 6-6 6" /></svg></span>
  );
  const Tog = ({ k }) => (
    <span className={"ac-tog" + (st[k] ? "" : " off")} onClick={(e) => { e.stopPropagation(); t(k); }} />
  );
  const Row = ({ icon, title, sub, tkey, value, chev, onClick }) => (
    <button className="ac-row" onClick={onClick || (tkey ? () => t(tkey) : undefined)}>
      {icon && <span className="ac-ic">{icon}</span>}
      <span className="ac-rtx">
        <span className="ac-rt">{title}</span>
        {sub && <span className="ac-rs">{sub}</span>}
      </span>
      {value && <span className="ac-val">{value}</span>}
      {tkey && <Tog k={tkey} />}
      {chev && Chev}
    </button>
  );

  return (
    <div className="mira-screen-body rd-account rd-notif">
      <div className="ac-scroll">
        <div className="ac-top">
          <button className="ac-back" onClick={goBack}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 6-6 6 6 6" /></svg>
            Settings
          </button>
        </div>
        <h1 className="ac-title">Notifications</h1>
        <p className="nt-intro">Mira stays quiet by default — and only speaks up when it truly helps.</p>

        {/* daily brief */}
        <div className="ac-sec">
          <div className="ac-label">Daily Brief</div>
          <div className="ac-group">
            <Row icon={<Ico d={<><circle cx="12" cy="12" r="5" /><path d="M12 1v2M12 21v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M1 12h2M21 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4" /></>} />} title="Morning brief" sub="A calm summary to start the day" tkey="brief" />
            <Row icon={<Ico d={<><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>} />} title="Brief time" value="8:00 AM" chev />
            <Row icon={<Ico d={<path d="M12 3a9 9 0 1 0 9 9 6 6 0 0 1-9-9Z" />} />} title="Resurface a memory" sub="Occasionally revisit something worth holding" tkey="briefResurface" />
          </div>
        </div>

        {/* reminders */}
        <div className="ac-sec">
          <div className="ac-label">Reminders</div>
          <div className="ac-group">
            <Row icon={<Ico d={<><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.7 21a2 2 0 0 1-3.4 0" /></>} />} title="Time-sensitive reminders" sub="Dates, tickets, and things that expire" tkey="timeSensitive" />
            <Row icon={<Ico d={<><path d="M12 2v4M12 18v4M2 12h4M18 12h4" /><circle cx="12" cy="12" r="4" /></>} />} title="Gentle nudges" sub="Soft prompts for unfinished threads" tkey="nudges" />
          </div>
        </div>

        {/* captures */}
        <div className="ac-sec">
          <div className="ac-label">Captures</div>
          <div className="ac-group">
            <Row icon={<Ico d={<><path d="M20 6 9 17l-5-5" /></>} />} title="Confirm before saving" sub="Ask before adding a capture to your graph" tkey="captureConfirm" />
            <Row icon={<Ico d={<><rect x="3" y="4" width="18" height="17" rx="2.5" /><path d="M16 2v4M8 2v4M3 10h18" /></>} />} title="Weekly recap" sub="A Sunday look back at the week" tkey="weekly" />
          </div>
        </div>

        {/* quiet hours */}
        <div className="ac-sec">
          <div className="ac-label">Quiet hours</div>
          <div className="ac-group">
            <Row icon={<Ico d={<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8Z" />} />} title="Quiet hours" sub="Hold all notifications while you rest" tkey="quiet" />
            <Row icon={<Ico d={<><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>} />} title="Schedule" value="10:00 PM – 7:00 AM" chev />
          </div>
        </div>

        {/* delivery */}
        <div className="ac-sec">
          <div className="ac-label">Delivery</div>
          <div className="ac-group">
            <Row icon={<Ico d={<><path d="M11 5 6 9H2v6h4l5 4V5Z" /><path d="M15.5 8.5a5 5 0 0 1 0 7" /></>} />} title="Sound" tkey="sound" />
            <Row icon={<Ico d={<><rect x="7" y="2" width="10" height="20" rx="3" /><path d="M11 18h2" /></>} />} title="Haptics" tkey="haptics" />
          </div>
        </div>

        <div className="ac-foot">Mira notifies you gently, or not at all.</div>
      </div>
    </div>
  );
}

Object.assign(window, { NotificationsScreen });
