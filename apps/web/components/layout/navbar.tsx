import { cn } from "@workspace/ui/lib/utils";
import Link, { LinkProps } from "next/link";
import { HTMLAttributes } from "react";

interface NavbarProps extends HTMLAttributes<HTMLDivElement> {}

export const Navbar = ({ className, ...props }: NavbarProps) => {
  return (
    <header
      className={cn(
        "fixed left-1/2 top-(--banner-height) z-40 box-content w-full max-w-[88rem] -translate-x-1/2 border-b border-foreground/10 transition-colors lg:mt-2 lg:w-[calc(100%-1rem)] lg:rounded-2xl lg:border",
        "shadow-lg",
        "bg-background/80 backdrop-blur-lg",
        className,
      )}
      {...props}
    />
  );
};

interface NavbarContentProps extends HTMLAttributes<HTMLDivElement> {}

export const NavbarContent = ({ className, ...props }: NavbarContentProps) => {
  return (
    <nav
      className={cn(
        "flex h-14 w-full flex-row items-center px-4 lg:h-12",
        className,
      )}
      {...props}
    />
  );
};

interface NavbarLinkItemProps extends LinkProps {
  children: React.ReactNode;
  className?: string;
}

export const NavbarLinkItem = ({
  href,
  className,
  ...props
}: NavbarLinkItemProps) => {
  return (
    <Link
      href={href}
      className={cn(
        "inline-flex items-center gap-1 p-2 text-muted-foreground transition-colors hover:text-accent-foreground data-[active=true]:text-primary [&_svg]:size-4",
        className,
      )}
      {...props}
    />
  );
};

interface NavbarAuxiliaryContentProps extends HTMLAttributes<HTMLDivElement> {}

export const NavbarAuxiliaryContent = ({
  className,
  ...props
}: NavbarAuxiliaryContentProps) => {
  return (
    <div
      className={cn(
        "flex flex-row items-center justify-end gap-1.5 flex-1",
        className,
      )}
      {...props}
    />
  );
};
