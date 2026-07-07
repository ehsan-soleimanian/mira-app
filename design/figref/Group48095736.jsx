import { Coffee } from './Coffee.jsx';
import { Home } from './Home.jsx';
import { Microphone } from './Microphone.jsx';

// figma node: 741:4986 Group 48095736
export function Group48095736(_p = {}) {
  const props = _p;
  return (
    <div className={props.className} style={{
      width: 393,
      height: 98,
      position: "relative",
      ...props.style,
    }}>
      <div style={{
        position: "absolute",
        left: 0,
        top: 34,
        width: 393,
        height: 64,
        overflow: "hidden",
        borderRadius: 24,
      }}>
        <div style={{
            position: "absolute",
            left: 291,
            top: 4,
            width: 32,
            height: 32,
          }}>{props.icon1 ?? <Coffee style2={"linear"} style={{ transform: "scale(1.333, 1.333)", transformOrigin: "0 0" }} />}</div>
        <div style={{
          position: "absolute",
          left: 67,
          top: 4,
          width: 270,
          height: 54,
          overflow: "hidden",
        }}>
          <div style={{
              position: "absolute",
              left: 3,
              top: 0,
              width: 32,
              height: 32,
            }}>{props.icon2 ?? <Home style2={"linear"} style={{ transform: "scale(1.333, 1.333)", transformOrigin: "0 0" }} />}</div>
          <span style={{
            position: "absolute",
            left: 0,
            top: 34,
            width: 39,
            height: 20,
            fontFamily: "Dosis, -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif",
            fontWeight: 700,
            fontSize: 16,
            lineHeight: "100%",
            color: "rgb(26,28,41)",
          }}>{props.text1 ?? "Home"}</span>
          <span style={{
            position: "absolute",
            left: 208,
            top: 34,
            width: 62,
            height: 20,
            opacity: 0.5,
            fontFamily: "Dosis, -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif",
            fontWeight: 700,
            fontSize: 16,
            lineHeight: "100%",
            color: "rgb(26,28,41)",
          }}>{props.text2 ?? "Daily Brief"}</span>
        </div>
      </div>
      <svg width={70} height={70} viewBox="0 0 70 70" fill="none" style={{
        position: "absolute",
        left: 158,
        top: 0,
        width: 70,
        height: 70,
        overflow: "hidden",
        borderRadius: 100,
      }}>
        <path d={"M 0 35 C 0 15.67 15.67 0 35 0 L 35 0 C 54.33 0 70 15.67 70 35 L 70 35 C 70 54.33 54.33 70 35 70 L 35 70 C 15.67 70 0 54.33 0 35 L 0 35 Z"} fill="currentColor" fillRule="nonzero" />
        <path d={"M 0 35 M 70 35 M 70 35 M 0 35 M 35 0 M 70 35 M 35 70 M 0 35 M 35 70 L 35 69 C 16.222 69 1 53.778 1 35 L 0 35 L -1 35 C -1 54.882 15.118 71 35 71 L 35 70 Z M 70 35 L 69 35 C 69 53.778 53.778 69 35 69 L 35 70 L 35 71 C 54.882 71 71 54.882 71 35 L 70 35 Z M 35 0 L 35 1 C 53.778 1 69 16.222 69 35 L 70 35 L 71 35 C 71 15.118 54.882 -1 35 -1 L 35 0 Z M 35 0 L 35 -1 C 15.118 -1 -1 15.118 -1 35 L 0 35 L 1 35 C 1 16.222 16.222 1 35 1 L 35 0 Z"} fill="currentColor" fillRule="nonzero" />
      </svg>
      <div style={{
          position: "absolute",
          left: 179,
          top: 21,
          width: 28,
          height: 28,
        }}>{props.icon3 ?? <Microphone style2={"linear"} style={{ transform: "scale(1.167, 1.167)", transformOrigin: "0 0" }} />}</div>
    </div>
  );
}
export default Group48095736;
