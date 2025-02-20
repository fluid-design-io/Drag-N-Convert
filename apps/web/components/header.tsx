import {
  Navbar,
  NavbarAuxiliaryContent,
  NavbarContent,
  NavbarLinkItem,
} from "@/components/layout/navbar";
import { ThemeToggle } from "@/components/layout/theme-toggle";
import { StarIcon } from "lucide-react";
import { unstable_cacheLife as cacheLife } from "next/cache";
import { Suspense } from "react";
import LogoIcon from "./icons/logo";

async function GitHubStars() {
  "use cache";
  cacheLife("weeks");

  const response = await fetch(
    "https://api.github.com/repos/fluid-design-io/Drag-N-Convert"
  );
  const data = await response.json();
  return (
    <span className='ml-1.5 text-xs font-medium'>{data.stargazers_count}</span>
  );
}

function Header() {
  return (
    <Navbar>
      <NavbarContent>
        <NavbarLinkItem href='/' className='flex items-center gap-2'>
          <LogoIcon className='size-4' />
          <span className='text-sm font-bold'>Drag-N-Convert</span>
        </NavbarLinkItem>
        <NavbarAuxiliaryContent>
          <ThemeToggle />
          <NavbarLinkItem
            href='https://github.com/fluid-design-io/Drag-N-Convert'
            className='rounded-full bg-accent flex items-center'
          >
            <StarIcon className='size-4' />
            <Suspense fallback={<span className='ml-2 text-xs'>0</span>}>
              <GitHubStars />
            </Suspense>
          </NavbarLinkItem>
        </NavbarAuxiliaryContent>
      </NavbarContent>
    </Navbar>
  );
}

export default Header;
