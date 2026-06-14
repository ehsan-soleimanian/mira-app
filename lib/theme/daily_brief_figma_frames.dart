/// Figma frame mapping — Daily Brief section (single batch export).
///
/// | Node | Frame | Widget |
/// |------|-------|--------|
/// | 564:2520 | Daily Brief screen | [DailyBriefScreen] |
/// | 618:2893 | Task card (unchecked) | [TaskBriefCard] + [TaskBriefCheckbox] |
/// | 652:8417 | Note card | [NoteBriefCard] |
/// | 659:3546 | Image card | [ImageBriefCard] |
/// | 672:7695 | Task card (checked) | [TaskBriefCheckbox] checked state |
abstract final class DailyBriefFigmaFrames {
  static const screen = '564:2520';
  static const taskCard = '618:2893';
  static const noteCard = '652:8417';
  static const imageCard = '659:3546';
  static const taskChecked = '672:7695';
}
