import React from 'react';
import Link from 'next/link';
import { Disc, ShieldCheck, ArrowLeft } from 'lucide-react';

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen flex flex-col bg-background text-foreground font-sans">
      {/* Top Admin Header Bar */}
      <header className="sticky top-0 z-40 bg-card/90 backdrop-blur-md border-b border-border py-3 px-4 sm:px-8">
        <div className="max-w-7xl mx-auto flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <Link href="/" className="flex items-center gap-2 group">
              <Disc className="w-6 h-6 text-primary group-hover:rotate-180 transition-transform duration-500" />
              <span className="text-sm font-black tracking-widest text-foreground uppercase">
                POYKEN<span className="text-primary">ADMIN</span>
              </span>
            </Link>
            <span className="text-xs text-muted-text hidden sm:inline">|</span>
            <span className="text-xs text-muted-text font-semibold hidden sm:flex items-center gap-1">
              <ShieldCheck className="w-3.5 h-3.5 text-emerald-500" />
              Secure Dashboard
            </span>
          </div>

          <Link
            href="/"
            className="flex items-center gap-1.5 px-3 py-1.5 bg-input-bg hover:bg-card-hover border border-border rounded-xl text-xs font-bold text-muted-text hover:text-foreground transition-all"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            Về Cửa Hàng
          </Link>
        </div>
      </header>

      {/* Main Admin Content */}
      <main className="flex-1 flex flex-col">
        {children}
      </main>
    </div>
  );
}
