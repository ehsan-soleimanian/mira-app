import * as React from 'react';
export interface MicrophoneProps {
  className?: string;
  style?: React.CSSProperties;
  style2?: "bold" | "broken" | "bulk" | "linear" | "outline" | "twotone";
}
export declare const Microphone: React.FC<MicrophoneProps>;
export default Microphone;
