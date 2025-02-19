import {
  Navbar,
  NavbarAuxiliaryContent,
  NavbarContent,
  NavbarLinkItem,
} from "@/components/layout/navbar";
import { ThemeToggle } from "@/components/layout/theme-toggle";
import GithubIcon from "./icons/github";
import LogoIcon from "./icons/logo";

function Header() {
  return (
    <Navbar>
      <NavbarContent>
        <NavbarLinkItem href="/" className="flex items-center gap-2">
          <LogoIcon className="size-4" />
          <span className="text-sm font-bold">Drag-N-Convert</span>
        </NavbarLinkItem>
        <NavbarAuxiliaryContent>
          <ThemeToggle />
          <NavbarLinkItem
            href="https://github.com/fluid-design-io/Drag-N-Convert"
            className="rounded-full bg-accent"
          >
            <GithubIcon className="size-4" />
          </NavbarLinkItem>
        </NavbarAuxiliaryContent>
      </NavbarContent>
    </Navbar>
  );
}

export default Header;
