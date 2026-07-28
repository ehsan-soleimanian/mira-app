from pathlib import Path

p = Path("lib/redesign/screens/rd_canvas_screen.dart")
t = p.read_text(encoding="utf-8")

repls = [
    ("sub: 'Tap to edit later.',", "sub: AppLocalizations.of(context)!.rdCanvasNewNoteSub,"),
    ("Text('Edit card',", "Text(AppLocalizations.of(context)!.rdCanvasEditCard,"),
    ("_editField(titleCtl, 'Title',", "_editField(titleCtl, AppLocalizations.of(context)!.rdCanvasEditTitle,"),
    ("_editField(subCtl, 'Note (optional)')", "_editField(subCtl, AppLocalizations.of(context)!.rdCanvasEditNoteOptional)"),
    ("'This board is empty'", "AppLocalizations.of(context)!.rdCanvasBoardEmpty"),
    ("? 'Now tap another card to connect them'", "? AppLocalizations.of(context)!.rdCanvasConnectTapSecond"),
    (": 'Connect mode · tap two cards to link them'", ": AppLocalizations.of(context)!.rdCanvasConnectMode"),
    ("'Add mode · tap anywhere to drop a card'", "AppLocalizations.of(context)!.rdCanvasAddMode"),
    ("'Done'", "AppLocalizations.of(context)!.rdCommonDone"),
    ("Text('Pick the duplicate to fold in — it keeps every connection.',", "Text(AppLocalizations.of(context)!.rdCanvasMergePickDuplicate,"),
    ("Text('Merge into “${current.label}”',", "Text(AppLocalizations.of(context)!.rdCanvasMergeInto(current.label),"),
    ("'Focused on ${_byId[_focus]!.label}'", "AppLocalizations.of(context)!.rdCanvasFocusedOn(_byId[_focus]!.label)"),
    ("'CONNECTED TO ${connected.length}'", "AppLocalizations.of(context)!.rdCanvasConnectedTo(connected.length)"),
    ("'$count ${count == 1 ? 'card' : 'cards'}'", "AppLocalizations.of(context)!.rdCanvasCardCount(count)"),
]

for old, new in repls:
    t = t.replace(old, new)

p.write_text(t, encoding="utf-8")
print("canvas strings fixed")
