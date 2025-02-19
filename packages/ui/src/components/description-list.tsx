import clsx from "clsx";

export function DescriptionList({
  className,
  ...props
}: React.ComponentPropsWithoutRef<"dl">) {
  return (
    <dl
      {...props}
      className={clsx(
        "grid grid-cols-1 text-base/6 sm:grid-cols-[min(50%,theme(spacing.80))_auto] sm:text-sm/6",
        className,
      )}
    />
  );
}

export function DescriptionTerm({
  className,
  ...props
}: React.ComponentPropsWithoutRef<"dt">) {
  return (
    <dt
      {...props}
      className={clsx(
        "col-start-1 border-t border-foreground/5 pt-3 text-muted-foreground first:border-none sm:border-t sm:border-foreground/5 sm:py-3",
        className,
      )}
    />
  );
}

export function DescriptionDetails({
  className,
  ...props
}: React.ComponentPropsWithoutRef<"dd">) {
  return (
    <dd
      {...props}
      className={clsx(
        "pb-3 pt-1 text-foreground sm:border-t sm:border-foreground/5 sm:py-3 sm:[&:nth-child(2)]:border-none",
        className,
      )}
    />
  );
}
