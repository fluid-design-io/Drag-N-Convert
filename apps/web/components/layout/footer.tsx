import Link from "next/link";
import { Suspense } from "react";
import { CopyrightText } from "./copyright-text";
import FooterCredits from "./footer-credits";

async function Footer() {
  return (
    <div className='mx-auto w-full max-w-[88rem] px-6 lg:px-8'>
      <footer className='flex w-full items-center justify-between border-t px-6 py-5 sm:px-8'>
        <Link
          href='https://oliverpan.vercel.app'
          target='_blank'
          className='text-sm text-muted-foreground'
        >
          <Suspense fallback={<span>© 20xx Oliver Pan</span>}>
            <CopyrightText />
          </Suspense>
        </Link>
        <FooterCredits />
      </footer>
    </div>
  );
}

export default Footer;
