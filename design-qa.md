# Design QA — My Mira, Home, Capture, Library

Final result: passed

## Evidence

- Approved visual direction: `C:\Users\User\.codex\generated_images\019fdb09-33e9-7c33-8a97-2ae62d7a1068\exec-5b4677ec-569b-447a-987e-9f70588a46f4.png`
- Before audit: `.codex\home-library-capture-audit\01-home-current.png`, `02-capture-entry-current.png`, `03-library-current.png`, `04-capture-review-current.png`
- Final implementation: `.codex\home-library-capture-qa\01-home-final.png`, `02-capture-entry-final.png`, `03-library-final.png`, `04-library-add-anything-final.png`
- Reference comparison: `.codex\home-library-capture-qa\05-reference-comparison.png`
- Screenshot picker fix: `.codex\screenshot-picker-fix\02-system-picker-final.png`
- Primary viewport: 390 × 844
- Responsive widget checks: 320 × 700 and 430 × 932

## Journey review

1. Home
   - My Mira is now the visible model-status surface rather than a disconnected shortcut.
   - Capture has a clear, first-class entry with voice and attachment actions.
   - The three navigation shortcuts use the same vertical icon/label pattern and no longer truncate.
   - The empty recent-memory state is actionable and visually consistent with the card system.
2. Capture
   - The entry sheet states the review/confirmation contract before input.
   - Photo, screenshot, file, link, and meeting are all visible without a hidden horizontal rail.
   - Processing explains what Mira is finding and repeats that no memory is saved before confirmation.
   - Review introduces the editable interpretation, and success offers both return-to-origin and View in Library.
   - Cancel, dismiss, and completion now return to the screen that launched Capture.
3. Library
   - Header hierarchy is simplified; Settings is the only header utility.
   - Add anything opens the complete capture/import hub instead of jumping directly to the file picker.
   - Ask Mira is a named primary action rather than a misleading search icon.
   - Core filters are visible; long-tail types move into a More sheet.
   - Empty state explains provenance/searchability and provides direct actions.
4. Screenshot picker
   - Removed the six hard-coded fake recent thumbnails and the non-functional in-app selection state.
   - The single primary action now delegates to Android's system photo picker through `ImagePicker`.
   - Privacy copy makes it clear that Mira can access only the image the user selects.
   - Cancelling the native picker keeps the user on Screenshot Picker instead of unexpectedly switching to Voice Capture.

## Visual review

- Layout and spacing: warm card surfaces, generous 18–22 px radii, compact section labels, and the central Mira orb follow the approved My Mira direction.
- Typography and color: navy/periwinkle actions, muted metadata, and Dosis/Vazirmatn hierarchy remain within existing `RdTheme` and typography tokens.
- Icons and imagery: the existing Mira orb and existing icon system are reused; no placeholder or handcrafted visual assets were introduced.
- Responsiveness: primary mobile viewport has no clipping; Capture transport wrapping passes 320 px and 430 px widget checks.
- Accessibility: semantic action labels, practical CTA heights, localized English/Persian copy, wrapping, and light/dark theme tokens remain intact.

## Contract and functional review

- `POST /captures` already produces a transient proposal and `POST /captures/{id}/approve` is the durable save boundary.
- `POST /captures/{id}/dismiss` purges transient data, matching the new trust copy.
- Approved captures already project idempotently into Library, so no backend endpoint or schema change is required.
- Flutter static analysis passes with no issues.
- Widget tests pass for My Mira Confirm/Correct and Capture entry at 320, 390, and 430 px widths.
- Screenshot Picker widget coverage verifies there is no fake Recent grid and that the real picker action is invoked at 430 × 825.
