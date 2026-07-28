import re
from pathlib import Path

p = Path("lib/redesign/screens/rd_setup_wizard.dart")
t = p.read_text(encoding="utf-8")
t = re.sub(
    r"Text\(\s*\n\s*'Let.s set up\\nyour second mind\.',\s*\n\s*textAlign: TextAlign\.center,",
    "Text(\n                    l10n.rdSetupWelcomeTitle,\n                    textAlign: TextAlign.center,",
    t,
    count=1,
)
p.write_text(t, encoding="utf-8")
print("fixed welcome")
