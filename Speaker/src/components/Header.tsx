'use client';

import React, { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useCart } from '../context/CartContext';
import { useTheme } from '../context/ThemeContext';
import { useCompare } from '../context/CompareContext';
import { useAudio } from '../context/AudioContext';
import { ShoppingCart, Search, Menu, X, Disc, Phone, Sun, Moon, SlidersHorizontal } from 'lucide-react';

export default function Header() {
  const { cartCount, setCartOpen } = useCart();
  const { theme, toggleTheme } = useTheme();
  const { compareItems, setCompareModalOpen } = useCompare();
  const { isPlaying } = useAudio();
  const pathname = usePathname();
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const headerRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 20);
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Close mobile menu on route change
  useEffect(() => {
    setIsMobileMenuOpen(false);
  }, [pathname]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      router.push(`/catalog?search=${encodeURIComponent(searchQuery.trim())}`);
      setSearchQuery('');
    }
  };

  const navLinks = [
    { name: 'Trang Chủ', href: '/' },
    { name: 'Cửa Hàng', href: '/catalog' },
    { name: 'Quản Trị', href: '/admin' }
  ];

  return (
    <>
      {/* Top utility bar */}
      <div className="hidden md:block bg-stone-900 text-white text-[11px] font-medium tracking-wide">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between py-1.5">
          <div className="flex items-center gap-6">
            <span className="flex items-center gap-1.5">
              <Phone className="w-3 h-3 text-primary" />
              Hotline: <strong className="font-bold text-primary">1900 8080</strong>
            </span>
            <span className="text-stone-400">|</span>
            <span>Miễn phí giao hàng toàn quốc đơn từ 2.000.000₫</span>
          </div>
          <div className="flex items-center gap-4">
            <a href="#" className="hover:text-primary transition-colors">Chính sách bảo hành</a>
            <span className="text-stone-600">|</span>
            <a href="#" className="hover:text-primary transition-colors">Trả góp 0%</a>
          </div>
        </div>
      </div>

      {/* Main navbar */}
      <header 
        ref={headerRef}
        className={`sticky top-0 left-0 right-0 z-40 transition-all duration-300 bg-background/80 backdrop-blur-md border-b ${
          isScrolled 
            ? 'py-3 border-border shadow-lg shadow-black/5 dark:shadow-black/40' 
            : 'py-4 border-border/40'
        }`}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between gap-4">
            
            {/* Brand Logo */}
            <Link href="/" className="flex items-center gap-2.5 group flex-shrink-0">
              <div className="relative">
                <Disc className={`w-8 h-8 text-primary group-hover:scale-110 transition-all ${isPlaying ? 'animate-spin-slow text-amber-500' : ''}`} style={{ animationDuration: '6s' }} />
                <div className="absolute inset-0 rounded-full bg-primary/10 scale-0 group-hover:scale-150 transition-transform duration-500 opacity-0 group-hover:opacity-100" />
              </div>
              <div className="flex flex-col leading-none">
                <span className="text-lg font-black tracking-[0.2em] text-foreground">
                  POYKEN<span className="text-primary">SOUND</span>
                </span>
                <span className="text-[8px] font-bold tracking-[0.3em] text-muted-text uppercase">Premium Audio Systems</span>
              </div>
            </Link>

            {/* Desktop Nav Links */}
            <nav className="hidden md:flex items-center gap-1">
              {navLinks.map((link) => {
                const isActive = pathname === link.href;
                return (
                  <Link
                    key={link.name}
                    href={link.href}
                    className={`text-sm font-semibold tracking-wide transition-all relative px-4 py-2 rounded-lg ${
                      isActive 
                        ? 'text-primary bg-primary/5' 
                        : 'text-muted-text hover:text-foreground hover:bg-card-hover'
                    }`}
                  >
                    {link.name}
                    {isActive && (
                      <span className="absolute bottom-0.5 left-1/2 -translate-x-1/2 w-4 h-[2px] bg-primary rounded-full" />
                    )}
                  </Link>
                );
              })}
            </nav>

            {/* Search Box */}
            <form 
              onSubmit={handleSearchSubmit} 
              className="hidden lg:flex items-center relative w-64 xl:w-80"
            >
              <input
                type="text"
                placeholder="Tìm kiếm loa, thương hiệu..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-input-bg border border-border text-sm text-foreground placeholder-muted-text/70 pl-10 pr-4 py-2.5 rounded-xl focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/10 transition-all"
              />
              <Search className="w-4 h-4 text-muted-text absolute left-3.5" />
            </form>

            {/* Action Buttons */}
            <div className="flex items-center gap-3 flex-shrink-0">
              
              {/* Compare Button */}
              {compareItems.length > 0 && (
                <button
                  type="button"
                  onClick={() => setCompareModalOpen(true)}
                  className="relative p-2.5 bg-primary/10 border border-primary/30 hover:border-primary rounded-xl text-primary font-bold text-xs flex items-center gap-1.5 transition-all active:scale-95 shadow-sm"
                  aria-label="So sánh loa"
                >
                  <SlidersHorizontal className="w-4 h-4" />
                  <span className="hidden sm:inline">So Sánh</span>
                  <span className="bg-primary text-white text-[10px] font-extrabold w-4 h-4 rounded-full flex items-center justify-center">
                    {compareItems.length}
                  </span>
                </button>
              )}

              {/* Theme Toggle Button */}
              <button
                type="button"
                onClick={toggleTheme}
                className="p-2.5 bg-input-bg border border-border hover:border-primary/30 rounded-xl text-muted-text hover:text-primary hover:bg-primary/5 transition-all active:scale-95 shadow-sm"
                aria-label="Đổi giao diện"
              >
                {theme === 'dark' ? (
                  <Sun className="w-5 h-5 transition-transform rotate-0 scale-100 hover:rotate-45 duration-300" />
                ) : (
                  <Moon className="w-5 h-5 transition-transform rotate-0 scale-100 hover:-rotate-12 duration-300" />
                )}
              </button>

              {/* Cart Button */}
              <button
                type="button"
                onClick={() => setCartOpen(true)}
                className="relative p-2.5 bg-input-bg border border-border hover:border-primary/30 rounded-xl text-muted-text hover:text-primary hover:bg-primary/5 transition-all active:scale-95 shadow-sm"
                aria-label="Xem giỏ hàng"
              >
                <ShoppingCart className="w-5 h-5" />
                {cartCount > 0 && (
                  <span className="absolute -top-1.5 -right-1.5 bg-primary text-white text-[10px] font-extrabold min-w-[20px] h-5 rounded-full flex items-center justify-center border-2 border-background shadow-sm px-1">
                    {cartCount}
                  </span>
                )}
              </button>

              {/* Mobile Menu Toggle */}
              <button
                type="button"
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                className="md:hidden p-2.5 bg-input-bg border border-border rounded-xl text-muted-text hover:text-foreground transition-colors shadow-sm"
              >
                {isMobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
              </button>
            </div>

          </div>
        </div>

        {/* Mobile Dropdown Menu */}
        {isMobileMenuOpen && (
          <div className="md:hidden absolute top-full left-0 right-0 bg-card/98 backdrop-blur-xl border-b border-border animate-fade-in py-5 px-4 space-y-4 shadow-lg">
            <form onSubmit={handleSearchSubmit} className="relative w-full">
              <input
                type="text"
                placeholder="Tìm kiếm loa..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-input-bg border border-border text-sm text-foreground placeholder-muted-text/70 pl-10 pr-4 py-2.5 rounded-xl focus:outline-none focus:border-primary"
              />
              <Search className="w-4 h-4 text-muted-text absolute left-3.5 top-3" />
            </form>
            <div className="flex flex-col gap-1">
              {navLinks.map((link) => {
                const isActive = pathname === link.href;
                return (
                  <Link
                    key={link.name}
                    href={link.href}
                    onClick={() => setIsMobileMenuOpen(false)}
                    className={`text-sm font-semibold py-2.5 px-4 rounded-xl transition-colors ${
                      isActive 
                        ? 'bg-primary/10 text-primary' 
                        : 'text-muted-text hover:bg-card-hover hover:text-foreground'
                    }`}
                  >
                    {link.name}
                  </Link>
                );
              })}
            </div>
          </div>
        )}
      </header>
    </>
  );
}
