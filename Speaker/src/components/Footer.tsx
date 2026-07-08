'use client';

import React from 'react';
import Link from 'next/link';
import { Disc, Mail, Phone, MapPin, ChevronRight, CreditCard, ShieldCheck, Truck as TruckIcon } from 'lucide-react';

export default function Footer() {
  const currentYear = new Date().getFullYear();

  const categories = [
    { name: 'Loa Bookshelf', href: '/catalog?type=Bookshelf' },
    { name: 'Loa Cột Xem Phim', href: '/catalog?type=Floorstanding' },
    { name: 'Loa Bluetooth Di Động', href: '/catalog?type=Bluetooth' },
    { name: 'Loa Soundbar Cao Cấp', href: '/catalog?type=Soundbar' },
    { name: 'Loa Kiểm Âm Phòng Thu', href: '/catalog?type=Monitor' }
  ];

  const supportLinks = [
    { name: 'Chính sách bảo hành 2 năm', href: '#' },
    { name: 'Giao hàng tận nơi miễn phí', href: '#' },
    { name: 'Chính sách đổi trả 30 ngày', href: '#' },
    { name: 'Hướng dẫn mua hàng trả góp', href: '#' }
  ];

  const trustBadges = [
    { icon: ShieldCheck, text: 'Chính hãng 100%' },
    { icon: TruckIcon, text: 'Giao hàng miễn phí' },
    { icon: CreditCard, text: 'Trả góp 0% lãi suất' },
  ];

  return (
    <footer className="bg-card border-t border-border text-muted-text text-left">
      
      {/* Trust badges bar */}
      <div className="border-b border-border bg-muted-bg/30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
            {trustBadges.map((badge, idx) => (
              <div key={idx} className="flex items-center gap-3 justify-center sm:justify-start">
                <div className="p-2.5 bg-input-bg rounded-xl border border-border/80 shadow-sm flex-shrink-0">
                  <badge.icon className="w-5 h-5 text-primary" />
                </div>
                <span className="text-sm font-extrabold text-foreground tracking-wide">{badge.text}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Main footer content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-14 pb-8">
        
        {/* Top Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-14">
          
          {/* Brand Info */}
          <div className="space-y-5">
            <Link href="/" className="flex items-center gap-2.5 group">
              <Disc className="w-7 h-7 text-primary" />
              <div className="flex flex-col leading-none">
                <span className="text-lg font-black tracking-[0.2em] text-foreground">
                  POYKEN<span className="text-primary">SOUND</span>
                </span>
                <span className="text-[8px] font-bold tracking-[0.3em] text-muted-text uppercase">Premium Audio Systems</span>
              </div>
            </Link>
            <p className="text-sm leading-relaxed text-muted-text">
              Nhà cung cấp giải pháp âm thanh và loa Hi-Fi chính hãng hàng đầu Việt Nam. Mang lại trải nghiệm nghe nhạc sống động chân thực chuẩn Studio tại gia đình bạn.
            </p>
            
            {/* Social Links */}
            <div className="flex items-center gap-3 pt-1">
              <a href="#" className="p-2.5 bg-input-bg border border-border text-muted-text hover:bg-primary hover:border-primary hover:text-white rounded-xl transition-all shadow-sm" aria-label="Facebook">
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M22 12c0-5.52-4.48-10-10-10S2 6.48 2 12c0 4.84 3.44 8.87 8 9.8V15H8v-3h2V9.5C10 7.57 11.57 6 13.5 6H16v3h-2c-.55 0-1 .45-1 1v2h3v3h-3v6.95c4.56-.93 8-4.96 8-9.75z"/>
                </svg>
              </a>
              <a href="#" className="p-2.5 bg-input-bg border border-border text-muted-text hover:bg-primary hover:border-primary hover:text-white rounded-xl transition-all shadow-sm" aria-label="Youtube">
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M23.498 6.163a3.003 3.003 0 0 0-2.11-2.11C19.517 3.545 12 3.545 12 3.545s-7.517 0-9.388.508a3.003 3.003 0 0 0-2.11 2.11C0 8.033 0 12 0 12s0 3.967.502 5.837a3.003 3.003 0 0 0 2.11 2.11c1.871.508 9.388.508 9.388.508s7.517 0 9.388-.508a3.003 3.003 0 0 0 2.11-2.11C24 15.967 24 12 24 12s0-3.967-.502-5.837zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
                </svg>
              </a>
              <a href="#" className="p-2.5 bg-input-bg border border-border text-muted-text hover:bg-primary hover:border-primary hover:text-white rounded-xl transition-all shadow-sm" aria-label="Instagram">
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect>
                  <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path>
                  <line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line>
                </svg>
              </a>
              <a href="#" className="p-2.5 bg-input-bg border border-border text-muted-text hover:bg-primary hover:border-primary hover:text-white rounded-xl transition-all shadow-sm" aria-label="TikTok">
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M19.59 6.69a4.83 4.83 0 0 1-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 0 1-2.88 2.5 2.89 2.89 0 0 1-2.88-2.88 2.89 2.89 0 0 1 2.88-2.88c.28 0 .55.04.81.1v-3.5a6.35 6.35 0 0 0-.81-.05A6.34 6.34 0 0 0 3.15 15.2a6.34 6.34 0 0 0 6.34 6.34 6.34 6.34 6.34 0 0 0 6.34-6.34V9.14a8.18 8.18 0 0 0 4.76 1.52V7.21a4.85 4.85 0 0 1-1-.52z"/>
                </svg>
              </a>
            </div>
          </div>

          {/* Categories */}
          <div>
            <h3 className="text-sm font-bold text-foreground uppercase tracking-wider mb-5 flex items-center gap-2">
              <span className="w-6 h-0.5 bg-primary rounded-full"></span>
              Dòng Sản Phẩm
            </h3>
            <ul className="space-y-3">
              {categories.map((cat) => (
                <li key={cat.name}>
                  <Link 
                    href={cat.href}
                    className="text-sm hover:text-primary flex items-center gap-2 group transition-colors text-muted-text hover:translate-x-1"
                  >
                    <ChevronRight className="w-3.5 h-3.5 text-muted-text/75 group-hover:text-primary transition-colors" />
                    {cat.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Support */}
          <div>
            <h3 className="text-sm font-bold text-foreground uppercase tracking-wider mb-5 flex items-center gap-2">
              <span className="w-6 h-0.5 bg-primary rounded-full"></span>
              Chính Sách & Hỗ Trợ
            </h3>
            <ul className="space-y-3">
              {supportLinks.map((link) => (
                <li key={link.name}>
                  <a 
                    href={link.href}
                    className="text-sm hover:text-primary flex items-center gap-2 group transition-colors text-muted-text hover:translate-x-1"
                  >
                    <ChevronRight className="w-3.5 h-3.5 text-muted-text/75 group-hover:text-primary transition-colors" />
                    {link.name}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact */}
          <div className="space-y-5">
            <h3 className="text-sm font-bold text-foreground uppercase tracking-wider flex items-center gap-2">
              <span className="w-6 h-0.5 bg-primary rounded-full"></span>
              Liên Hệ
            </h3>
            <ul className="space-y-4 text-sm text-muted-text">
              <li className="flex items-start gap-3">
                <div className="p-1.5 bg-input-bg border border-border rounded-lg shadow-sm mt-0.5">
                  <MapPin className="w-4 h-4 text-primary" />
                </div>
                <span>Số 18, Đường 3/2, Quận 10, TP. Hồ Chí Minh</span>
              </li>
              <li className="flex items-center gap-3">
                <div className="p-1.5 bg-input-bg border border-border rounded-lg shadow-sm">
                  <Phone className="w-4 h-4 text-primary" />
                </div>
                <span>1900 8080 <span className="text-muted-text/70 font-semibold">(08:00 - 21:00)</span></span>
              </li>
              <li className="flex items-center gap-3">
                <div className="p-1.5 bg-input-bg border border-border rounded-lg shadow-sm">
                  <Mail className="w-4 h-4 text-primary" />
                </div>
                <span>support@poykensound.vn</span>
              </li>
            </ul>

            <div className="pt-2">
              <h4 className="text-xs font-bold text-foreground uppercase mb-3">Nhận ưu đãi qua email</h4>
              <div className="flex gap-2">
                <input
                  type="email"
                  placeholder="Email của bạn..."
                  className="bg-input-bg border border-border rounded-xl px-4 py-2.5 text-xs text-foreground placeholder-muted-text/70 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 flex-1 shadow-sm"
                />
                <button className="bg-primary hover:bg-orange-700 text-white text-xs font-bold px-4 py-2.5 rounded-xl transition-colors btn-premium shadow-md shadow-primary/10">
                  Gửi
                </button>
              </div>
            </div>
          </div>

        </div>

        {/* Bottom Bar */}
        <div className="border-t border-border pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-xs text-muted-text">
          <p>© {currentYear} POYKEN SOUND. Đã đăng ký bản quyền. GPKD: 0316XXXXXX</p>
          <div className="flex gap-6">
            <a href="#" className="hover:text-foreground transition-colors">Điều khoản dịch vụ</a>
            <a href="#" className="hover:text-foreground transition-colors">Chính sách bảo mật</a>
            <a href="#" className="hover:text-foreground transition-colors">Sitemap</a>
          </div>
        </div>

      </div>
    </footer>
  );
}
