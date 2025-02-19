import { SVGProps } from "react";
const LogoIcon = (props: SVGProps<SVGSVGElement>) => (
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='none'
    {...props}
  >
    <path
      fill='currentColor'
      fillRule='evenodd'
      d='M23 15c0-6.075-4.925-11-11-11S1 8.925 1 15c0 1.351.244 2.645.69 3.84.167.452.543.85 1.023.815.632-.046 1.358-.837 2.808-2.42L6.838 15.8l.17-.154c1.37-1.188 3.123-1.186 4.505.019l.165.15L13.863 18a.478.478 0 0 0 .675 0l.17-.154c1.37-1.188 3.123-1.186 4.505.019l.165.15c.674.773 1.01 1.16 1.263 1.297.253.137.524.198.79.194.455-.009.785-.394.938-.824A10.98 10.98 0 0 0 23 15Zm-4.5-3.212a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0Z'
      clipRule='evenodd'
    />
  </svg>
);
export default LogoIcon;
