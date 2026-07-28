# Mira input UX audit

## Verdict

The current input flow is visually clean but makes users classify input before
they can start. Mira should use one universal composer: direct typing, one-tap
voice, and a single add button for inferred attachment types.

## Steps

1. Home — needs simplification
   - Composer, three shortcuts, and the persistent center microphone duplicate
     the same capture action.
   - The shortcuts add a decision before the user has expressed anything.

2. Capture chooser — structurally sound, but too early
   - Large targets and clear labels are usable.
   - Six equal choices turn a quick capture into a classification task.
   - Text is demoted to “Type it instead” even though it is a primary input.

## Recommended flow

1. Tap composer and type immediately.
2. Tap microphone to start voice immediately.
3. Tap plus to open a compact attachment sheet:
   Camera, Photos/files, Meeting, and Link.
4. Infer input type from the selected asset or pasted content.
5. Show the existing approval/review step after extraction.

## Accessibility risks

- Several secondary labels have low contrast on the warm background.
- Shortcut height is 42px, slightly below the usual 44–48px touch target.
- Icon-only microphone and add controls need explicit semantic labels.

## Evidence limits

The audit covers the Home and capture-chooser states at 513 × 920. It does not
claim full accessibility compliance or assess device microphone permission
dialogs.
