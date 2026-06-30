// Shared dark two-column auth shell, used by BOTH the Stack Auth handler
// (/handler/[...stack], cloud) and the local/OSS auth pages (/auth/login,
// /auth/signup). LEFT (lg+): brand/value panel. RIGHT: centered auth form card.

import type { ReactNode } from "react";

import { BrandLogo } from "@/components/BrandLogo";

const HIGHLIGHTS = [
  "Voice agents",
  "Real-time calls",
  "Workflow builder",
];

export function AuthShell({ children }: { children: ReactNode }) {
  return (
    <div className="app-blue-shell grid min-h-screen w-full lg:grid-cols-[45%_55%]">
      <aside className="auth-brand-panel relative hidden flex-col justify-between overflow-hidden border-r p-10 text-white lg:flex xl:p-14">
        <div className="relative">
          <BrandLogo inverse className="text-xl text-white" />
        </div>

        <div className="relative max-w-md space-y-5">
          <h1 className="text-3xl font-semibold leading-tight tracking-tight text-white xl:text-4xl">
            Build and deploy voice AI agents at scale.
          </h1>
          <ul className="flex flex-wrap gap-2">
            {HIGHLIGHTS.map((point) => (
              <li
                key={point}
                className="rounded-full border border-white/20 bg-white/10 px-3 py-1 text-xs font-medium text-white/90"
              >
                {point}
              </li>
            ))}
          </ul>
        </div>

        <div className="relative mb-12 max-w-md xl:mb-16">
          <p className="text-sm text-white/75">
            Sign in to manage agents, campaigns, telephony, and call analytics from one dashboard.
          </p>
        </div>
      </aside>

      <main className="flex min-h-screen flex-col overflow-y-auto">
        <div className="flex min-h-full items-center justify-center p-6 sm:p-10">
          <div className="w-full max-w-md space-y-6 rounded-2xl border border-border/60 bg-card p-6 shadow-lg sm:p-8">
            <div className="lg:hidden">
              <BrandLogo className="text-lg" />
            </div>
            {children}
          </div>
        </div>
      </main>
    </div>
  );
}
