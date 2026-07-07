import * as React from 'react';
export interface CoffeeProps {
  className?: string;
  style?: React.CSSProperties;
  style2?: "bold" | "broken" | "bulk" | "linear" | "outline" | "twotone";
}
export declare const Coffee: React.FC<CoffeeProps>;
export default Coffee;
