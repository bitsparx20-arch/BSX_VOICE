import { cn } from "@/lib/utils";

const BRAND_NAME = "BSX VOICE";
const BRAND_MARK = "BV";

// Text wordmark used across the app sidebar and auth screens.
export function BrandLogo({
  className,
  inverse = false,
  mark = false,
}: {
  className?: string;
  inverse?: boolean;
  mark?: boolean;
}) {
  return (
    <span
      className={cn(
        "select-none font-bold tracking-wide",
        mark ? "text-sm" : "text-base",
        inverse ? "text-white" : "text-foreground",
        className
      )}
    >
      {mark ? BRAND_MARK : BRAND_NAME}
    </span>
  );
}
