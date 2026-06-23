import re
from pathlib import Path

svg_path = Path(__file__).resolve().parents[1] / "tmp_onboarding.svg"
s = svg_path.read_text(encoding="utf-8")
img_idx = s.find("<image id")
pre = s[:img_idx]

for i, m in enumerate(re.finditer(r'<(path|rect) ([^>]+)>', pre)):
    tag = m.group(1)
    attrs = m.group(2)
    if tag == "rect":
        x = re.search(r'x="([^"]+)"', attrs)
        y = re.search(r'y="([^"]+)"', attrs)
        w = re.search(r'width="([^"]+)"', attrs)
        h = re.search(r'height="([^"]+)"', attrs)
        fill = re.search(r'fill="([^"]+)"', attrs)
        print(
            i,
            "rect",
            f"x={x.group(1) if x else 0}",
            f"y={y.group(1) if y else 0}",
            f"w={w.group(1) if w else '?'}",
            f"h={h.group(1) if h else '?'}",
            fill.group(1) if fill else "",
        )
        continue

    d_m = re.search(r'd="([^"]+)"', attrs)
    if not d_m:
        continue
    d = d_m.group(1)
    nums = [float(x) for x in re.findall(r"[-]?\d+\.?\d*", d)]
    xs = nums[0::2]
    ys = nums[1::2]
    if xs and ys:
        print(
            i,
            "path",
            f"xmin={min(xs):.1f}",
            f"xmax={max(xs):.1f}",
            f"ymin={min(ys):.1f}",
            f"ymax={max(ys):.1f}",
        )
