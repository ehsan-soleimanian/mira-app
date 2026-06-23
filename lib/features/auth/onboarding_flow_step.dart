/// Top-level onboarding flow — Figma frames 1–7.
enum OnboardingFlowStep {
  /// 1 — Splash / intro (`724:4804`).
  welcome(1),

  /// 2 — Login or sign up (email).
  authEmail(2),

  /// 3 — Invite code (conditional).
  authInvite(3),

  /// 4 — Email OTP verification.
  authEmailCode(4),

  /// 5 — Your details (display name).
  yourDetails(5),

  /// 6 — First memory prompt.
  firstCapture(6),

  /// 7 — Blur + «MIRA understands you» → submit profile → home.
  processing(7);

  const OnboardingFlowStep(this.number);

  final int number;

  static const int total = 7;

  /// Post-email profile steps (for optional UI labels).
  static const postAuthSteps = 2;

  /// @deprecated Use [yourDetails].
  static const profile = yourDetails;

  /// @deprecated Profile wizard removed — use [processing].
  static const profileWizard = processing;
}
