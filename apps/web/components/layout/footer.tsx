import Link from "next/link";
import FooterCredits from "./footer-credits";

function Footer() {
  const year = new Date().getFullYear();
  const copyright = `© ${year} Oliver Pan`;
  return (
    <div className="mx-auto w-full max-w-[88rem] px-6 lg:px-8">
      <footer className="flex w-full items-center justify-between border-t px-6 py-5 sm:px-8">
        <Link
          href="https://oliverpan.vercel.app"
          target="_blank"
          className="text-sm text-muted-foreground"
        >
          {copyright}
        </Link>
        <FooterCredits />
      </footer>
    </div>
  );
}

export default Footer;
