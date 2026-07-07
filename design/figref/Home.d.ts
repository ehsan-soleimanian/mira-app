import * as React from 'react';
export interface HomeProps {
  className?: string;
  style?: React.CSSProperties;
  style2?: "bold" | "broken" | "bulk" | "linear" | "outline" | "twotone";
}
export declare const Home: React.FC<HomeProps>;
export default Home;
