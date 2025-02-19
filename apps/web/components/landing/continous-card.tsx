import { FC, SVGProps } from "react";

export const ContinousCardDesktop: FC<SVGProps<SVGSVGElement>> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 672 672"
    fill="none"
    {...props}
  >
    <defs>
      <mask id="cardMaskDesktop">
        <path
          fill="white"
          d="M0 204.8C0 133.113 0 97.27 13.951 69.89A128 128 0 0 1 69.89 13.95C97.27 0 133.113 0 204.8 0h262.4c71.687 0 107.53 0 134.911 13.951a128 128 0 0 1 55.938 55.938C672 97.27 672 133.113 672 204.8v262.4c0 71.687 0 107.53-13.951 134.911a128 128 0 0 1-55.938 55.938C574.73 672 538.887 672 467.2 672H204.8c-71.687 0-107.53 0-134.91-13.951a128 128 0 0 1-55.939-55.938C0 574.73 0 538.887 0 467.2V204.8Z"
        />
      </mask>
    </defs>
  </svg>
);
