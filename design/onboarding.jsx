// Mira — onboarding flow. Splash → Login → Invite → Email code → Details → Remember → Understood.

const { useState: useS, useEffect: useE, useRef: useR } = React;

// shared bottom CTA wrapper
function Cta({ children }) {
  return <div className="ob-cta">{children}</div>;
}

// ── 1. Splash ───────────────────────────────────────────────────────
function SplashScreen({ go }) {
  return (
    <div className="mira-screen-body ob">
      <div className="ob-splash">
        <span className="t-splash-brand">Mira.</span>
        <h1 className="t-splash-title">Mira. Your<br />second mind.</h1>
        <p className="t-splash-sub">A second mind. For when you don't want to forget anything.</p>
      </div>
      <Cta>
        <button className="ob-btn ob-btn--navy" onClick={() => go("login")}>See how it works</button>
      </Cta>
    </div>
  );
}

// ── 2. Login or sign up ─────────────────────────────────────────────
function LoginScreen({ go }) {
  const [email, setEmail] = useS("");
  return (
    <div className="mira-screen-body ob">
      <TitleHeader title="Login or sign up" onBack={() => go("splash")} />
      <div className="ob-pad" style={{ top: 120 }}>
        <input className="ob-input" placeholder="Enter Your Email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <button className="ob-btn ob-btn--navy" style={{ marginTop: 14 }} onClick={() => go("invite")}>Continue</button>

        <div className="ob-or"><span className="ob-or-line" /><span className="ob-or-text">Or</span><span className="ob-or-line" /></div>

        <button className="ob-btn ob-btn--social" onClick={() => go("invite")}>
          <Icons.Google size={20} /> Continue with Google
        </button>
        <button className="ob-btn ob-btn--social" onClick={() => go("invite")}>
          <Icons.Apple size={20} /> Continue with Apple
        </button>
      </div>
      <p className="ob-terms">If you are creating a new account,<br />Terms &amp; Conditions and Privacy Policy will apply.</p>
    </div>
  );
}

// ── 3. Invite code ──────────────────────────────────────────────────
function InviteScreen({ go }) {
  const [code, setCode] = useS("");
  return (
    <div className="mira-screen-body ob">
      <Header onBack={() => go("login")} showMemory={false} />
      <div className="ob-pad" style={{ top: 130 }}>
        <div className="ob-badge-icon"><Icons.ShieldCheck size={26} stroke="#293D8C" /></div>
        <h2 className="t-ob-title" style={{ marginTop: 18 }}>You need an invite code to join Mira.</h2>
        <p className="t-ob-desc">Enter 6-digit code</p>
        <input className="ob-input" style={{ marginTop: 22 }} placeholder="Code" value={code} onChange={(e) => setCode(e.target.value)} />
      </div>
      <Cta>
        <button className="ob-btn ob-btn--peri" onClick={() => go("email")}>Enter</button>
      </Cta>
    </div>
  );
}

// ── 4. Check your email (OTP) ───────────────────────────────────────
function EmailCodeScreen({ go }) {
  const [digits, setDigits] = useS(["4", "", "", ""]);
  const set = (i, v) => setDigits((d) => d.map((x, j) => (j === i ? v.slice(-1) : x)));
  return (
    <div className="mira-screen-body ob">
      <Header onBack={() => go("invite")} showMemory={false} />
      <div className="ob-pad ob-center" style={{ top: 150 }}>
        <div className="ob-badge-icon"><Icons.Shield size={26} stroke="#293D8C" /></div>
        <h2 className="t-ob-title" style={{ marginTop: 16, textAlign: "center" }}>Check your email</h2>
        <p className="t-ob-desc" style={{ textAlign: "center" }}>We sent you a 6-digit code</p>
        <div className="ob-otp">
          {digits.map((d, i) => (
            <input key={i} className={"ob-otp-box" + (d ? " is-filled" : "")} value={d} maxLength={1}
              onChange={(e) => set(i, e.target.value)} inputMode="numeric" />
          ))}
        </div>
        <button className="ob-resend">Didn't get the code? <b>Resend</b></button>
      </div>
      <Cta>
        <button className="ob-btn ob-btn--peri" onClick={() => go("details")}>Enter</button>
      </Cta>
    </div>
  );
}

// ── 5. Your details ─────────────────────────────────────────────────
function DetailsScreen({ go }) {
  const [name, setName] = useS("");
  return (
    <div className="mira-screen-body ob">
      <Header onBack={() => go("email")} showMemory={false} />
      <div className="ob-pad" style={{ top: 130 }}>
        <div className="ob-badge-icon"><Icons.User size={26} stroke="#293D8C" /></div>
        <h2 className="t-ob-title" style={{ marginTop: 18 }}>Your details</h2>
        <p className="t-ob-desc">Lorem ipsum dolor sit amet, adipiscing elit, sed eiusmod tempor incididunt.</p>
        <input className="ob-input" style={{ marginTop: 22 }} placeholder="your name" value={name} onChange={(e) => setName(e.target.value)} />
      </div>
      <Cta>
        <button className="ob-btn ob-btn--peri" onClick={() => go("wizard")}>Enter</button>
      </Cta>
    </div>
  );
}

// ── 6. What do you want Mira to remember? (record) ──────────────────
function RememberScreen({ go }) {
  const [recording, setRecording] = useS(false);
  const [sec, setSec] = useS(0);
  useE(() => {
    if (!recording) return;
    const id = setInterval(() => setSec((s) => s + 1), 1000);
    return () => clearInterval(id);
  }, [recording]);
  const fmt = (s) => `${String(Math.floor(s / 60)).padStart(2, "0")}:${String(s % 60).padStart(2, "0")}`;

  return (
    <div className="mira-screen-body ob">
      <Header onBack={() => go("details")} showMemory={false} />
      <Orb listening={recording} style={{ position: "absolute", left: 136, top: 92 }} size={120} />
      <h2 className="t-ob-title" style={{ position: "absolute", left: 24, right: 24, top: 232, textAlign: "center" }}>
        What do you want Mira to remember?
      </h2>
      <p className="t-ob-desc" style={{ position: "absolute", left: 40, right: 40, top: 282, textAlign: "center" }}>
        Anything you don't want to forget. An idea. A task. A link. Even a feeling.
      </p>

      {recording ? (
        <>
          <p className="t-ob-hello" style={{ position: "absolute", left: 28, top: 366 }}>HELLO</p>
          <button className="mira-stop" style={{ position: "absolute", left: 161, top: 470 }} onClick={() => { setRecording(false); go("understood"); }}>
            <span className="mira-stop-sq" />
          </button>
          <div className="t-timer" style={{ position: "absolute", left: 161, top: 552, width: 72, textAlign: "center" }}>{fmt(sec)}</div>
          <div className="t-tapstop" style={{ position: "absolute", left: 141, top: 588, width: 112, textAlign: "center" }}>Tap to stop</div>
        </>
      ) : (
        <>
          <p className="t-ob-desc" style={{ position: "absolute", left: 40, right: 40, top: 372, textAlign: "center" }}>
            Press the button and speak or type
          </p>
          <button className="ob-recbtn" style={{ position: "absolute", left: 168, top: 462 }} onClick={() => { setSec(0); setRecording(true); }} aria-label="Record">
            <Icons.AttachMic size={26} stroke="#1A1C29" />
          </button>
        </>
      )}

      <div className="ob-cta ob-cta--stack">
        <button className="ob-btn ob-btn--peri" onClick={() => go("understood")}>Next</button>
        <button className="ob-btn ob-btn--ghost" onClick={() => go("home")}>I'll do it later</button>
      </div>
    </div>
  );
}

// ── 7. Mira understands you ─────────────────────────────────────────
function UnderstoodScreen({ go }) {
  return (
    <div className="mira-screen-body ob">
      <Header onBack={() => go("remember")} showMemory={false} />
      <Orb style={{ position: "absolute", left: 136, top: 92 }} size={120} />
      <h2 className="t-ob-title" style={{ position: "absolute", left: 24, right: 24, top: 232, textAlign: "center", opacity: 0.35 }}>
        What do you want Mira to remember?
      </h2>
      <p className="t-ob-desc" style={{ position: "absolute", left: 40, right: 40, top: 282, textAlign: "center", opacity: 0.35 }}>
        Anything you don't want to forget. An idea. A task. A link. Even a feeling.
      </p>
      <p className="t-ob-hello" style={{ position: "absolute", left: 28, top: 366, opacity: 0.4 }}>HELLO</p>
      <h3 className="t-understand" style={{ position: "absolute", left: 24, right: 24, top: 400, textAlign: "center" }}>
        MIRA understand you
      </h3>
      <div className="ob-cta ob-cta--stack">
        <button className="ob-btn ob-btn--navy" onClick={() => go("home")}>Next</button>
        <button className="ob-btn ob-btn--ghost" onClick={() => go("home")}>I'll do it later</button>
      </div>
    </div>
  );
}

Object.assign(window, { SplashScreen, LoginScreen, InviteScreen, EmailCodeScreen, DetailsScreen, RememberScreen, UnderstoodScreen });
